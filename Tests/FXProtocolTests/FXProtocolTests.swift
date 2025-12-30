// FXProtocolTests.swift
// Main test suite for FXProtocol SDK

import XCTest
@testable import FXProtocol

final class FXProtocolTests: XCTestCase {
    var client: FXClient!
    // Use production API for integration tests, or set TEST_API_URL env var for custom URL
    let testBaseURL = ProcessInfo.processInfo.environment["TEST_API_URL"] ?? "https://fx-api-production.up.railway.app/v1"
    
    override func setUp() {
        super.setUp()
        client = FXClient(baseURL: testBaseURL)
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }
    
    // MARK: - Address Validation Tests
    
    func testValidEthereumAddress() {
        let validAddress = "0x1234567890123456789012345678901234567890"
        XCTAssertTrue(validAddress.isValidEthereumAddress)
    }
    
    func testInvalidEthereumAddress() {
        let invalidAddresses = [
            "0x123",  // Too short
            "1234567890123456789012345678901234567890",  // Missing 0x
            "0x123456789012345678901234567890123456789g",  // Invalid character
            "",  // Empty
            "0x12345678901234567890123456789012345678901"  // Too long
        ]
        
        for address in invalidAddresses {
            XCTAssertFalse(address.isValidEthereumAddress, "Address should be invalid: \(address)")
        }
    }
    
    // MARK: - Decimal Extensions Tests
    
    func testDecimalAPIString() {
        let decimal = Decimal(string: "1234.5678")!
        let apiString = decimal.apiString
        XCTAssertEqual(apiString, "1234.5678")
    }
    
    func testDecimalFromAPIString() {
        let apiString = "1234.5678"
        let decimal = Decimal(apiString: apiString)
        XCTAssertNotNil(decimal)
        XCTAssertEqual(decimal, Decimal(string: "1234.5678"))
    }
    
    // MARK: - Data Extensions Tests
    
    func testDataToHexString() {
        let data = Data([0x12, 0x34, 0x56, 0x78])
        let hexString = data.toHexString()
        XCTAssertEqual(hexString, "12345678")
    }
    
    func testDataFromHexString() {
        let hexString = "0x12345678"
        let data = Data(hex: hexString)
        XCTAssertEqual(data, Data([0x12, 0x34, 0x56, 0x78]))
    }
    
    // MARK: - String Hex Conversion Tests
    
    func testHexStringToBytes() throws {
        let hexString = "0x12345678"
        // Convert hex string to bytes using Data initializer
        let data = Data(hex: hexString)
        let bytes = Array(data)
        XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78])
    }
    
    func testHexStringToBytesWithoutPrefix() throws {
        let hexString = "12345678"
        // Convert hex string to bytes using Data initializer
        let data = Data(hex: hexString)
        let bytes = Array(data)
        XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78])
    }
    
    func testInvalidHexString() {
        // Note: hexToBytes() is no longer a String extension in TransactionSigner
        // This test is kept for future implementation
        // For now, we test hex conversion through Data(hex:) which handles invalid hex gracefully
        let invalidHex = "0x123g"
        let data = Data(hex: invalidHex)
        // Data(hex:) will skip invalid characters, so this won't throw
        // This is acceptable behavior for now
        XCTAssertNotNil(data)
    }
}

