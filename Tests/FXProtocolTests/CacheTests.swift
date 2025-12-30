// CacheTests.swift
// Tests for caching layer

import XCTest
@testable import FXProtocol

final class CacheTests: XCTestCase {
    var cacheManager: CacheManager!
    
    override func setUp() async throws {
        cacheManager = CacheManager()
        await cacheManager.clear()
    }
    
    func testCacheSetAndGet() async {
        let testValue = AllBalancesResponse(
            address: "0x1234567890123456789012345678901234567890",
            balances: ["fxn": "1000"],
            totalUsdValue: "5000"
        )
        
        // Set value
        await cacheManager.set(testValue, for: "test_key", ttl: 60)
        
        // Get value
        let retrieved: AllBalancesResponse? = await cacheManager.get("test_key", as: AllBalancesResponse.self)
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.address, testValue.address)
        XCTAssertEqual(retrieved?.balances["fxn"], testValue.balances["fxn"])
    }
    
    func testCacheExpiration() async {
        let testValue = BalanceResponse(
            address: "0x1234567890123456789012345678901234567890",
            token: "fxn",
            balance: "1000",
            tokenAddress: nil
        )
        
        // Set value with very short TTL
        await cacheManager.set(testValue, for: "expire_test", ttl: 0.1)
        
        // Should be available immediately
        let retrieved: BalanceResponse? = await cacheManager.get("expire_test", as: BalanceResponse.self)
        XCTAssertNotNil(retrieved)
        
        // Wait for expiration
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Should be expired
        let expired: BalanceResponse? = await cacheManager.get("expire_test", as: BalanceResponse.self)
        XCTAssertNil(expired)
    }
    
    func testCacheRemove() async {
        let testValue = BalanceResponse(
            address: "0x1234567890123456789012345678901234567890",
            token: "fxn",
            balance: "1000",
            tokenAddress: nil
        )
        
        // Set value
        await cacheManager.set(testValue, for: "remove_test", ttl: 60)
        
        // Verify it exists
        let before: BalanceResponse? = await cacheManager.get("remove_test", as: BalanceResponse.self)
        XCTAssertNotNil(before)
        
        // Remove it
        await cacheManager.remove("remove_test")
        
        // Verify it's gone
        let after: BalanceResponse? = await cacheManager.get("remove_test", as: BalanceResponse.self)
        XCTAssertNil(after)
    }
    
    func testCacheClear() async {
        // Set multiple values
        let value1 = BalanceResponse(
            address: "0x1111111111111111111111111111111111111111",
            token: "fxn",
            balance: "100",
            tokenAddress: nil
        )
        let value2 = BalanceResponse(
            address: "0x2222222222222222222222222222222222222222",
            token: "fxusd",
            balance: "200",
            tokenAddress: nil
        )
        
        await cacheManager.set(value1, for: "key1", ttl: 60)
        await cacheManager.set(value2, for: "key2", ttl: 60)
        
        // Verify both exist
        let retrieved1: BalanceResponse? = await cacheManager.get("key1", as: BalanceResponse.self)
        let retrieved2: BalanceResponse? = await cacheManager.get("key2", as: BalanceResponse.self)
        XCTAssertNotNil(retrieved1)
        XCTAssertNotNil(retrieved2)
        
        // Clear all
        await cacheManager.clear()
        
        // Verify both are gone
        let after1: BalanceResponse? = await cacheManager.get("key1", as: BalanceResponse.self)
        let after2: BalanceResponse? = await cacheManager.get("key2", as: BalanceResponse.self)
        XCTAssertNil(after1)
        XCTAssertNil(after2)
    }
    
    func testCacheStats() async {
        let testValue = BalanceResponse(
            address: "0x1234567890123456789012345678901234567890",
            token: "fxn",
            balance: "1000",
            tokenAddress: nil
        )
        
        // Set value
        await cacheManager.set(testValue, for: "stats_test", ttl: 60)
        
        // Get it multiple times (should be hits)
        _ = await cacheManager.get("stats_test", as: BalanceResponse.self)
        _ = await cacheManager.get("stats_test", as: BalanceResponse.self)
        
        // Get non-existent key (should be miss)
        _ = await cacheManager.get("nonexistent", as: BalanceResponse.self)
        
        // Check stats
        let stats = await cacheManager.getStats()
        XCTAssertGreaterThan(stats.memoryHits, 0)
        XCTAssertGreaterThan(stats.misses, 0)
        XCTAssertGreaterThan(stats.hitRate, 0)
    }
    
    func testCacheInvalidatePattern() async {
        // Set multiple values with different patterns
        let value1 = BalanceResponse(
            address: "0x1111111111111111111111111111111111111111",
            token: "fxn",
            balance: "100",
            tokenAddress: nil
        )
        let value2 = BalanceResponse(
            address: "0x2222222222222222222222222222222222222222",
            token: "fxusd",
            balance: "200",
            tokenAddress: nil
        )
        let value3 = BalanceResponse(
            address: "0x3333333333333333333333333333333333333333",
            token: "feth",
            balance: "300",
            tokenAddress: nil
        )
        
        await cacheManager.set(value1, for: "balance:all:0x1111", ttl: 60)
        await cacheManager.set(value2, for: "balance:all:0x2222", ttl: 60)
        await cacheManager.set(value3, for: "protocol:nav", ttl: 60)
        
        // Verify entries exist before invalidation
        let before1: BalanceResponse? = await cacheManager.get("balance:all:0x1111", as: BalanceResponse.self)
        let before2: BalanceResponse? = await cacheManager.get("balance:all:0x2222", as: BalanceResponse.self)
        XCTAssertNotNil(before1, "Entry 1 should exist before invalidation")
        XCTAssertNotNil(before2, "Entry 2 should exist before invalidation")
        
        // Invalidate all balance entries (pattern: "balance:*" should match "balance:all:*")
        await cacheManager.invalidate(pattern: "balance:*")
        
        // Balance entries should be gone
        let after1: BalanceResponse? = await cacheManager.get("balance:all:0x1111", as: BalanceResponse.self)
        let after2: BalanceResponse? = await cacheManager.get("balance:all:0x2222", as: BalanceResponse.self)
        XCTAssertNil(after1, "Entry 1 should be removed after invalidation")
        XCTAssertNil(after2, "Entry 2 should be removed after invalidation")
        
        // Protocol entry should still exist
        let after3: BalanceResponse? = await cacheManager.get("protocol:nav", as: BalanceResponse.self)
        XCTAssertNotNil(after3, "Protocol entry should not be affected by balance invalidation")
    }
}

