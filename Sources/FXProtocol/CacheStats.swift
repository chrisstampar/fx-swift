// CacheStats.swift
// Cache statistics for monitoring

import Foundation

/// Statistics about cache performance
public struct CacheStats: Codable {
    public var memoryHits: Int = 0
    public var diskHits: Int = 0
    public var misses: Int = 0
    
    public var totalRequests: Int {
        memoryHits + diskHits + misses
    }
    
    public var hitRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(memoryHits + diskHits) / Double(totalRequests)
    }
    
    public var memoryHitRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(memoryHits) / Double(totalRequests)
    }
    
    public init() {}
}

