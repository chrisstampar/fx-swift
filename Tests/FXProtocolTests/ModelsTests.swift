// ModelsTests.swift
// Tests for data models

import XCTest
@testable import FXProtocol

final class ModelsTests: XCTestCase {
    
    // MARK: - BalanceResponse Tests
    
    func testBalanceResponseDecoding() throws {
        let json = """
        {
            "address": "0x1234567890123456789012345678901234567890",
            "token": "fxusd",
            "balance": "1000.50",
            "token_address": "0x085780639CC2cACd35E474e71f4d000e2405d8f6"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(BalanceResponse.self, from: data)
        
        XCTAssertEqual(response.address, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(response.token, "fxusd")
        XCTAssertEqual(response.balance, "1000.50")
        XCTAssertEqual(response.tokenAddress, "0x085780639CC2cACd35E474e71f4d000e2405d8f6")
    }
    
    // MARK: - AllBalancesResponse Tests
    
    func testAllBalancesResponseDecoding() throws {
        let json = """
        {
            "address": "0x1234567890123456789012345678901234567890",
            "balances": {
                "fxusd": "1000.50",
                "fxn": "500.25",
                "feth": "10.75"
            },
            "total_usd_value": "15234.56"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(AllBalancesResponse.self, from: data)
        
        XCTAssertEqual(response.address, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(response.balances["fxusd"], "1000.50")
        XCTAssertEqual(response.balances["fxn"], "500.25")
        XCTAssertEqual(response.balances["feth"], "10.75")
        XCTAssertEqual(response.totalUsdValue, "15234.56")
    }
    
    // MARK: - ProtocolInfoResponse Tests
    
    func testProtocolInfoResponseDecoding() throws {
        let json = """
        {
            "base_nav": "2500.50",
            "f_nav": "2400.25",
            "x_nav": "2600.75",
            "source": "treasury",
            "note": "NAV calculated from stETH treasury"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ProtocolInfoResponse.self, from: data)
        
        XCTAssertEqual(response.baseNav, "2500.50")
        XCTAssertEqual(response.fNav, "2400.25")
        XCTAssertEqual(response.xNav, "2600.75")
        XCTAssertEqual(response.source, "treasury")
        XCTAssertEqual(response.note, "NAV calculated from stETH treasury")
    }
    
    // MARK: - TransactionDataResponse Tests
    
    func testTransactionDataResponseDecoding() throws {
        let json = """
        {
            "to": "0x1234567890123456789012345678901234567890",
            "data": "0x095ea7b3...",
            "value": "0",
            "gas": 65000,
            "gasPrice": "20000000000",
            "nonce": 42,
            "chainId": 1,
            "estimated_gas": 65000,
            "estimated_gas_cost_wei": "1300000000000000"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(TransactionDataResponse.self, from: data)
        
        XCTAssertEqual(response.to, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(response.data, "0x095ea7b3...")
        XCTAssertEqual(response.value, "0")
        XCTAssertEqual(response.gas, 65000)
        XCTAssertEqual(response.gasPrice, "20000000000")
        XCTAssertEqual(response.nonce, 42)
        XCTAssertEqual(response.chainId, 1)
        XCTAssertEqual(response.estimatedGas, 65000)
    }
    
    // MARK: - ErrorResponse Tests
    
    func testErrorResponseDecoding() throws {
        let json = """
        {
            "error": true,
            "code": "INVALID_ADDRESS",
            "message": "Invalid Ethereum address format",
            "details": {
                "address": "0x123"
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ErrorResponse.self, from: data)
        
        XCTAssertTrue(response.error)
        XCTAssertEqual(response.code, "INVALID_ADDRESS")
        XCTAssertEqual(response.message, "Invalid Ethereum address format")
        XCTAssertNotNil(response.details)
    }
    
    // MARK: - HealthResponse Tests
    
    func testHealthResponseDecoding() throws {
        let json = """
        {
            "status": "healthy",
            "version": "v1"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(HealthResponse.self, from: data)
        
        XCTAssertEqual(response.status, "healthy")
        XCTAssertEqual(response.version, "v1")
    }
}

