// FXClientTests.swift
// Tests for FXClient main interface

import XCTest
@testable import FXProtocol

final class FXClientTests: XCTestCase {
    var client: FXClient!
    // Use production API for integration tests, or set TEST_API_URL env var for custom URL
    let testBaseURL = ProcessInfo.processInfo.environment["TEST_API_URL"] ?? "https://fx-api-production.up.railway.app/v1"
    let testAddress = "0x1234567890123456789012345678901234567890"
    let testPrivateKey = "0x" + String(repeating: "1", count: 64)
    
    override func setUp() {
        super.setUp()
        client = FXClient(baseURL: testBaseURL)
    }
    
    override func tearDown() {
        // Clean up test wallet
        try? client.importWallet(privateKey: testPrivateKey, address: testAddress)
        client = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testClientInitialization() {
        let client = FXClient()
        XCTAssertNotNil(client)
    }
    
    func testClientInitializationWithCustomURL() {
        let client = FXClient(baseURL: "https://custom.api.com/v1")
        XCTAssertNotNil(client)
    }
    
    func testClientInitializationWithAPIKey() {
        let client = FXClient(baseURL: testBaseURL, apiKey: "test-api-key")
        XCTAssertNotNil(client)
    }
    
    // MARK: - Wallet Management Tests
    
    func testImportWallet() throws {
        XCTAssertNoThrow(try client.importWallet(privateKey: testPrivateKey, address: testAddress))
    }
    
    func testImportWalletWithInvalidKey() {
        let invalidKey = "0x123"  // Too short
        XCTAssertThrowsError(try client.importWallet(privateKey: invalidKey, address: testAddress)) { error in
            XCTAssertTrue(error is FXError)
        }
    }
    
    // MARK: - Address Validation Tests
    
    func testGetBalanceWithInvalidAddress() async {
        let invalidAddress = "invalid"
        do {
            let _ = try await client.getAllBalances(address: invalidAddress)
            XCTFail("Should have thrown invalidAddress error")
        } catch let error as FXError {
            if case .invalidAddress = error {
                // Expected
            } else {
                XCTFail("Expected invalidAddress error, got: \(error)")
            }
        } catch {
            XCTFail("Expected FXError, got: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorDescriptions() {
        let errors: [FXError] = [
            .walletNotFound,
            .invalidAddress("0x123"),
            .transactionFailed("Test error"),
            .networkError(404, "Not found"),
            .invalidResponse("Invalid JSON"),
            .apiError("ERROR_CODE", "Error message"),
            .encodingError("Encoding failed"),
            .decodingError("Decoding failed"),
            .keychainError("Keychain failed"),
            .signingError("Signing failed")
        ]
        
        for error in errors {
            let description = error.errorDescription
            XCTAssertNotNil(description)
            XCTAssertFalse(description!.isEmpty)
        }
    }
}

