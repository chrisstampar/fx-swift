// TransactionFlowTests.swift
// Tests for transaction preparation, signing, and broadcasting flow

import XCTest
@testable import FXProtocol

final class TransactionFlowTests: XCTestCase {
    var client: FXClient!
    // Use production API for integration tests, or set TEST_API_URL env var for custom URL
    let testBaseURL = ProcessInfo.processInfo.environment["TEST_API_URL"] ?? "https://fx-api-production.up.railway.app/v1"
    let testWalletAddress = "0x1234567890123456789012345678901234567890"
    let testPrivateKey = "0x" + String(repeating: "1", count: 64)
    
    override func setUp() {
        super.setUp()
        client = FXClient(baseURL: testBaseURL)
        try? client.importWallet(privateKey: testPrivateKey, address: testWalletAddress)
    }
    
    override func tearDown() {
        try? client.importWallet(privateKey: testPrivateKey, address: testWalletAddress)
        client = nil
        super.tearDown()
    }
    
    // MARK: - Transaction Data Response Tests
    
    func testTransactionDataResponseDecoding() throws {
        let json = """
        {
            "to": "0x1234567890123456789012345678901234567890",
            "data": "0x095ea7b3000000000000000000000000...",
            "value": "0",
            "gas": 65000,
            "gasPrice": "20000000000",
            "maxFeePerGas": "30000000000",
            "maxPriorityFeePerGas": "2000000000",
            "nonce": 42,
            "chainId": 1,
            "estimated_gas": 65000,
            "estimated_gas_cost_wei": "1300000000000000"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(TransactionDataResponse.self, from: data)
        
        XCTAssertEqual(response.to, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(response.data, "0x095ea7b3000000000000000000000000...")
        XCTAssertEqual(response.value, "0")
        XCTAssertEqual(response.gas, 65000)
        XCTAssertEqual(response.gasPrice, "20000000000")
        XCTAssertEqual(response.maxFeePerGas, "30000000000")
        XCTAssertEqual(response.maxPriorityFeePerGas, "2000000000")
        XCTAssertEqual(response.nonce, 42)
        XCTAssertEqual(response.chainId, 1)
        XCTAssertEqual(response.estimatedGas, 65000)
        XCTAssertEqual(response.estimatedGasCostWei, "1300000000000000")
    }
    
    func testTransactionDataResponseLegacyGas() throws {
        let json = """
        {
            "to": "0x1234567890123456789012345678901234567890",
            "data": "0x",
            "value": "1000000000000000000",
            "gas": 21000,
            "gasPrice": "20000000000",
            "nonce": 0,
            "chainId": 1
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(TransactionDataResponse.self, from: data)
        
        XCTAssertEqual(response.gasPrice, "20000000000")
        XCTAssertNil(response.maxFeePerGas)
        XCTAssertNil(response.maxPriorityFeePerGas)
    }
    
    func testTransactionResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "transaction_hash": "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
            "status": "pending",
            "gas_estimate": 65000,
            "block_number": null
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(TransactionResponse.self, from: data)
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.transactionHash, "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890")
        XCTAssertEqual(response.status, "pending")
        XCTAssertEqual(response.gasEstimate, 65000)
        XCTAssertNil(response.blockNumber)
    }
    
    func testTransactionStatusResponseDecoding() throws {
        let json = """
        {
            "transaction_hash": "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
            "status": "confirmed",
            "block_number": 19000000,
            "confirmations": 12,
            "gas_used": 65000,
            "effective_gas_price": "20000000000",
            "error": null
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(TransactionStatusResponse.self, from: data)
        
        XCTAssertEqual(response.transactionHash, "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890")
        XCTAssertEqual(response.status, "confirmed")
        XCTAssertEqual(response.blockNumber, 19000000)
        XCTAssertEqual(response.confirmations, 12)
        XCTAssertEqual(response.gasUsed, 65000)
        XCTAssertEqual(response.effectiveGasPrice, "20000000000")
        XCTAssertNil(response.error)
    }
    
    func testTransactionStatusResponseFailed() throws {
        let json = """
        {
            "transaction_hash": "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
            "status": "failed",
            "block_number": null,
            "confirmations": null,
            "gas_used": null,
            "effective_gas_price": null,
            "error": "execution reverted"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(TransactionStatusResponse.self, from: data)
        
        XCTAssertEqual(response.status, "failed")
        XCTAssertEqual(response.error, "execution reverted")
    }
    
    // MARK: - Prepared Transactions Response Tests
    
    func testPreparedTransactionsResponseDecoding() throws {
        let json = """
        {
            "transactions": [
                {
                    "to": "0x1234567890123456789012345678901234567890",
                    "data": "0x",
                    "value": "0",
                    "gas": 21000,
                    "nonce": 0,
                    "chainId": 1
                },
                {
                    "to": "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12",
                    "data": "0x1234",
                    "value": "0",
                    "gas": 30000,
                    "nonce": 1,
                    "chainId": 1
                }
            ],
            "count": 2
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(PreparedTransactionsResponse.self, from: data)
        
        XCTAssertEqual(response.count, 2)
        XCTAssertEqual(response.transactions.count, 2)
        XCTAssertEqual(response.transactions[0].to, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(response.transactions[1].to, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
    }
    
    // MARK: - Broadcast Transaction Request Tests
    
    func testBroadcastTransactionRequestEncoding() throws {
        let request = BroadcastTransactionRequest(
            rawTransaction: "0x02f8..."
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["rawTransaction"] as? String, "0x02f8...")
    }
}

