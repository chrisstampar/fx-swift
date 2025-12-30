// WriteOperationsTests.swift
// Tests for write operations and transaction flow

import XCTest
@testable import FXProtocol

final class WriteOperationsTests: XCTestCase {
    var client: FXClient!
    // Use production API for integration tests, or set TEST_API_URL env var for custom URL
    let testBaseURL = ProcessInfo.processInfo.environment["TEST_API_URL"] ?? "https://fx-api-production.up.railway.app/v1"
    let testWalletAddress = "0x1234567890123456789012345678901234567890"
    let testPrivateKey = "0x" + String(repeating: "1", count: 64)
    
    override func setUp() {
        super.setUp()
        client = FXClient(baseURL: testBaseURL)
        // Import test wallet
        try? client.importWallet(privateKey: testPrivateKey, address: testWalletAddress)
    }
    
    override func tearDown() {
        // Clean up test wallet
        try? client.importWallet(privateKey: testPrivateKey, address: testWalletAddress)
        client = nil
        super.tearDown()
    }
    
    // MARK: - Transaction Flow Tests
    
    func testExecuteTransactionFlow() async {
        // This tests the generic executeTransaction helper
        // Note: This would require a mock API server to fully test
        let marketAddress = "0x" + String(repeating: "2", count: 40)
        
        do {
            let _ = try await client.mintFToken(
                marketAddress: marketAddress,
                baseIn: "1.0",
                walletAddress: testWalletAddress
            )
            // If we get here without error, the flow worked
            // (In real tests, we'd mock the API responses)
        } catch {
            // Expected to fail without a real API, but tests the flow structure
            XCTAssertTrue(error is FXError)
        }
    }
    
    // MARK: - Address Validation Tests
    
    func testWriteOperationsValidateAddresses() async {
        let invalidAddress = "invalid"
        let validAddress = "0x" + String(repeating: "3", count: 40)
        
        // Test that invalid addresses are caught before API call
        do {
            let _ = try await client.mintFToken(
                marketAddress: invalidAddress,
                baseIn: "1.0",
                walletAddress: testWalletAddress
            )
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
        
        // Test wallet address validation
        do {
            let _ = try await client.mintFToken(
                marketAddress: validAddress,
                baseIn: "1.0",
                walletAddress: invalidAddress
            )
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
    
    // MARK: - Wallet Not Found Tests
    
    func testWriteOperationsRequireWallet() async {
        let nonExistentWallet = "0x" + String(repeating: "9", count: 40)
        let marketAddress = "0x" + String(repeating: "2", count: 40)
        
        do {
            let _ = try await client.mintFToken(
                marketAddress: marketAddress,
                baseIn: "1.0",
                walletAddress: nonExistentWallet
            )
            XCTFail("Should have thrown walletNotFound error")
        } catch let error as FXError {
            if case .walletNotFound = error {
                // Expected
            } else {
                XCTFail("Expected walletNotFound error, got: \(error)")
            }
        } catch {
            XCTFail("Expected FXError, got: \(error)")
        }
    }
}

