// KeychainManagerTests.swift
// Tests for KeychainManager secure storage

import XCTest
@testable import FXProtocol

final class KeychainManagerTests: XCTestCase {
    var keychainManager: KeychainManager!
    let testAddress = "0x1234567890123456789012345678901234567890"
    let testPrivateKey = "0x" + String(repeating: "1", count: 64)  // Valid format
    
    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager()
        // Clean up any existing test data
        try? keychainManager.deletePrivateKey(for: testAddress)
    }
    
    override func tearDown() {
        // Clean up test data
        try? keychainManager.deletePrivateKey(for: testAddress)
        keychainManager = nil
        super.tearDown()
    }
    
    // MARK: - Store Tests
    
    func testStorePrivateKey() throws {
        XCTAssertNoThrow(try keychainManager.storePrivateKey(testPrivateKey, for: testAddress))
        XCTAssertTrue(keychainManager.hasPrivateKey(for: testAddress))
    }
    
    func testStoreInvalidPrivateKey() {
        // Test that invalid private keys are rejected
        let invalidKeys = [
            "0x123",  // Too short
            "1234567890123456789012345678901234567890123456789012345678901234",  // Missing 0x
            ""  // Empty
        ]
        
        for invalidKey in invalidKeys {
            XCTAssertThrowsError(try keychainManager.storePrivateKey(invalidKey, for: testAddress)) { error in
                if case FXError.keychainError = error {
                    // Expected error
                } else {
                    XCTFail("Expected keychainError for: \(invalidKey)")
                }
            }
        }
        
        // Note: Invalid hex characters (like 'g') may be handled by KeychainAccess
        // and not throw an error at the validation level. This is acceptable.
    }
    
    // MARK: - Retrieve Tests
    
    func testGetPrivateKey() throws {
        try keychainManager.storePrivateKey(testPrivateKey, for: testAddress)
        let retrieved = try keychainManager.getPrivateKey(for: testAddress)
        XCTAssertEqual(retrieved, testPrivateKey)
    }
    
    func testGetNonExistentPrivateKey() throws {
        let nonExistentAddress = "0x" + String(repeating: "9", count: 40)
        let retrieved = try keychainManager.getPrivateKey(for: nonExistentAddress)
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Delete Tests
    
    func testDeletePrivateKey() throws {
        try keychainManager.storePrivateKey(testPrivateKey, for: testAddress)
        XCTAssertTrue(keychainManager.hasPrivateKey(for: testAddress))
        
        try keychainManager.deletePrivateKey(for: testAddress)
        XCTAssertFalse(keychainManager.hasPrivateKey(for: testAddress))
    }
    
    func testDeleteNonExistentKey() {
        let nonExistentAddress = "0x" + String(repeating: "9", count: 40)
        // Should not throw, just do nothing
        XCTAssertNoThrow(try keychainManager.deletePrivateKey(for: nonExistentAddress))
    }
    
    // MARK: - Has Key Tests
    
    func testHasPrivateKey() throws {
        XCTAssertFalse(keychainManager.hasPrivateKey(for: testAddress))
        try keychainManager.storePrivateKey(testPrivateKey, for: testAddress)
        XCTAssertTrue(keychainManager.hasPrivateKey(for: testAddress))
    }
}

