// CacheEntry.swift
// Cache entry with TTL support

import Foundation

/// Represents a cached value with expiration
internal struct CacheEntry<T: Codable>: Codable {
    let value: T
    let timestamp: Date
    let ttl: TimeInterval
    let key: String
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
    
    init(value: T, ttl: TimeInterval, key: String) {
        self.value = value
        self.timestamp = Date()
        self.ttl = ttl
        self.key = key
    }
    
    func get() -> T? {
        if isExpired {
            return nil
        }
        return value
    }
}

/// Type-erased cache entry wrapper for storing different types in memory cache
internal struct CacheEntryWrapper: Codable {
    let data: Data
    let timestamp: Date
    let ttl: TimeInterval
    let key: String
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
    
    init<T: Codable>(entry: CacheEntry<T>) throws {
        self.data = try JSONEncoder().encode(entry.value)
        self.timestamp = entry.timestamp
        self.ttl = entry.ttl
        self.key = entry.key
    }
    
    func decode<T: Codable>(as type: T.Type) throws -> T {
        return try JSONDecoder().decode(type, from: data)
    }
}
