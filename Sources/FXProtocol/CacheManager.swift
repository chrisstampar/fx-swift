// CacheManager.swift
// Multi-tier cache manager with memory and disk storage

import Foundation

/// Manages caching with memory and disk tiers
public actor CacheManager {
    // Memory cache (actor-isolated for thread safety)
    // Using wrapper for type erasure
    private var memoryCache: [String: CacheEntryWrapper] = [:]
    
    // Disk cache storage
    private let diskCache: DiskCacheProtocol
    
    // Configuration
    private let defaultMemoryTTL: TimeInterval = 60 // 1 minute
    private let defaultDiskTTL: TimeInterval = 300 // 5 minutes
    
    // Statistics
    private var stats = CacheStats()
    
    // Maximum memory cache size (approximate, in entries)
    private let maxMemoryEntries = 100
    
    public init(diskCache: DiskCacheProtocol = UserDefaultsDiskCache()) {
        self.diskCache = diskCache
    }
    
    /// Get value from cache (checks memory first, then disk)
    public func get<T: Codable>(_ key: String, as type: T.Type) async -> T? {
        // Check memory cache first
        if let memoryWrapper = memoryCache[key] {
            if !memoryWrapper.isExpired {
                stats.memoryHits += 1
                if let value = try? memoryWrapper.decode(as: type) {
                    return value
                }
            } else {
                // Expired, remove from memory
                memoryCache.removeValue(forKey: key)
            }
        }
        
        // Check disk cache
        if let diskEntry = try? await diskCache.get(key, as: CacheEntry<T>.self) {
            if !diskEntry.isExpired {
                stats.diskHits += 1
                // Promote to memory cache
                if let wrapper = try? CacheEntryWrapper(entry: diskEntry) {
                    memoryCache[key] = wrapper
                    evictIfNeeded()
                }
                return diskEntry.get()
            } else {
                // Expired, remove from disk
                try? await diskCache.remove(key)
            }
        }
        
        stats.misses += 1
        return nil
    }
    
    /// Set value in both memory and disk caches
    public func set<T: Codable>(_ value: T, for key: String, ttl: TimeInterval? = nil) async {
        let memoryTTL = ttl ?? defaultMemoryTTL
        let diskTTL = ttl ?? defaultDiskTTL
        
        // Create cache entry
        let entry = CacheEntry(
            value: value,
            ttl: memoryTTL,
            key: key
        )
        
        // Store in memory (as wrapper)
        if let wrapper = try? CacheEntryWrapper(entry: entry) {
            memoryCache[key] = wrapper
            evictIfNeeded()
        }
        
        // Store on disk (with longer TTL)
        let diskEntry = CacheEntry(
            value: value,
            ttl: diskTTL,
            key: key
        )
        try? await diskCache.set(diskEntry, for: key)
    }
    
    /// Remove value from both caches
    public func remove(_ key: String) async {
        memoryCache.removeValue(forKey: key)
        try? await diskCache.remove(key)
    }
    
    /// Clear all caches
    public func clear() async {
        memoryCache.removeAll()
        try? await diskCache.clear()
        stats = CacheStats()
    }
    
    /// Get cache statistics
    public func getStats() async -> CacheStats {
        return stats
    }
    
    /// Invalidate entries matching a pattern
    /// Pattern format: "category:*" or "category:*:identifier"
    public func invalidate(pattern: String) async {
        let patternParts = pattern.split(separator: ":")
        
        // Get all keys (both memory and disk need to be checked)
        var allKeys = Set(memoryCache.keys)
        
        // Also check disk cache keys (we'll need to get them from UserDefaults)
        // For now, we'll match against memory cache keys and remove from disk if they match
        
        // Simple pattern matching
        for key in allKeys {
            if matchesPattern(key, pattern: pattern, patternParts: patternParts) {
                memoryCache.removeValue(forKey: key)
                try? await diskCache.remove(key)
            }
        }
    }
    
    /// Invalidate all entries
    public func invalidateAll() async {
        await clear()
    }
    
    // MARK: - Private Helpers
    
    /// Evict least recently used entries if cache is too large
    private func evictIfNeeded() {
        guard memoryCache.count > maxMemoryEntries else { return }
        
        // Simple eviction: remove expired entries first
        let expiredKeys = memoryCache.keys.filter { key in
            (memoryCache[key]?.isExpired) == true
        }
        
        for key in expiredKeys {
            memoryCache.removeValue(forKey: key)
        }
        
        // If still too large, remove oldest entries
        if memoryCache.count > maxMemoryEntries {
            let sortedEntries = memoryCache.sorted { $0.value.timestamp < $1.value.timestamp }
            let toRemove = sortedEntries.prefix(memoryCache.count - maxMemoryEntries)
            for (key, _) in toRemove {
                memoryCache.removeValue(forKey: key)
            }
        }
    }
    
    /// Check if a key matches a pattern
    private func matchesPattern(_ key: String, pattern: String, patternParts: [Substring]) -> Bool {
        let keyParts = key.split(separator: ":")
        
        // Handle case where pattern has fewer parts (e.g., "balance:*" should match "balance:all:0x1111")
        // If pattern ends with "*", it should match any number of remaining parts
        if patternParts.last == "*" && keyParts.count >= patternParts.count {
            // Check that all non-wildcard parts match
            for i in 0..<(patternParts.count - 1) {
                if patternParts[i] != "*" && keyParts[i] != patternParts[i] {
                    return false
                }
            }
            return true
        }
        
        // Exact match required
        guard keyParts.count == patternParts.count else { return false }
        
        for (keyPart, patternPart) in zip(keyParts, patternParts) {
            if patternPart == "*" {
                continue // Wildcard matches anything
            }
            if keyPart != patternPart {
                return false
            }
        }
        
        return true
    }
}
