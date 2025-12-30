// CacheTTL.swift
// Default TTL configuration for different data types

import Foundation

/// Default Time-To-Live values for different cache categories
internal struct CacheTTL {
    /// Balance queries (1 minute)
    static let balance: TimeInterval = 60
    
    /// Protocol information (5 minutes)
    static let protocolInfo: TimeInterval = 300
    
    /// Pool information (3 minutes)
    static let poolInfo: TimeInterval = 180
    
    /// Vault information (3 minutes)
    static let vaultInfo: TimeInterval = 180
    
    /// Gauge information (2 minutes)
    static let gaugeInfo: TimeInterval = 120
    
    /// Transaction data (30 seconds)
    static let transaction: TimeInterval = 30
    
    /// Price data (1 minute)
    static let price: TimeInterval = 60
    
    /// Default TTL for unknown types (1 minute)
    static let `default`: TimeInterval = 60
}

