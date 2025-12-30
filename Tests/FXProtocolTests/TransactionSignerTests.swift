// TransactionSignerTests.swift
// Tests for transaction signing (structure tests)

import XCTest
@testable import FXProtocol

final class TransactionSignerTests: XCTestCase {
    var signer: TransactionSigner!
    
    override func setUp() {
        super.setUp()
        signer = TransactionSigner()
    }
    
    override func tearDown() {
        signer = nil
        super.tearDown()
    }
    
    // MARK: - Private Key Validation Tests
    
    func testInvalidPrivateKeyFormat() {
        let invalidKeys = [
            "0x123",  // Too short
            "1234567890123456789012345678901234567890123456789012345678901234",  // Missing 0x
            "",  // Empty
            "0x" + String(repeating: "g", count: 64)  // Invalid hex
        ]
        
        let transaction = TransactionDataResponse(
            to: "0x1234567890123456789012345678901234567890",
            data: "0x",
            value: "0",
            gas: 21000,
            gasPrice: "20000000000",
            maxFeePerGas: nil,
            maxPriorityFeePerGas: nil,
            nonce: 0,
            chainId: 1,
            estimatedGas: nil,
            estimatedGasCostWei: nil
        )
        
        for invalidKey in invalidKeys {
            XCTAssertThrowsError(try signer.signTransaction(transaction, privateKey: invalidKey)) { error in
                if case FXError.signingError = error {
                    // Expected error
                } else {
                    XCTFail("Expected signingError for: \(invalidKey)")
                }
            }
        }
    }
    
    // Note: Full transaction signing tests require Web3.swift integration
    // and would test actual signing functionality
}

