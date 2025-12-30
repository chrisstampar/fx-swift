// RequestModelsTests.swift
// Tests for request model encoding

import XCTest
@testable import FXProtocol

// Note: These tests verify the internal request models are properly encoded.
// In a real scenario, these would be tested through the public API methods.
// For now, we test the encoding structure to ensure correctness.

final class RequestModelsTests: XCTestCase {
    
    // MARK: - Token Operation Request Tests
    
    func testMintFTokenRequestEncoding() throws {
        let request = MintFTokenRequest(
            marketAddress: "0x1234567890123456789012345678901234567890",
            baseIn: "1.5",
            recipient: "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12",
            minFTokenOut: "1.4"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["market_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["base_in"] as? String, "1.5")
        XCTAssertEqual(json["recipient"] as? String, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
        XCTAssertEqual(json["min_f_token_out"] as? String, "1.4")
    }
    
    func testMintXTokenRequestEncoding() throws {
        let request = MintXTokenRequest(
            marketAddress: "0x1234567890123456789012345678901234567890",
            baseIn: "2.0",
            recipient: nil,
            minXTokenOut: "1.9"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["market_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["base_in"] as? String, "2.0")
        XCTAssertNil(json["recipient"])
        XCTAssertEqual(json["min_x_token_out"] as? String, "1.9")
    }
    
    func testMintBothTokensRequestEncoding() throws {
        let request = MintBothTokensRequest(
            marketAddress: "0x1234567890123456789012345678901234567890",
            baseIn: "3.0",
            recipient: nil,
            minFTokenOut: "1.4",
            minXTokenOut: "1.5"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["base_in"] as? String, "3.0")
        XCTAssertEqual(json["min_f_token_out"] as? String, "1.4")
        XCTAssertEqual(json["min_x_token_out"] as? String, "1.5")
    }
    
    func testApproveRequestEncoding() throws {
        let request = ApproveRequest(
            tokenAddress: "0x1234567890123456789012345678901234567890",
            spenderAddress: "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12",
            amount: "1000.0"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["token_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["spender_address"] as? String, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
        XCTAssertEqual(json["amount"] as? String, "1000.0")
    }
    
    func testTransferRequestEncoding() throws {
        let request = TransferRequest(
            tokenAddress: "0x1234567890123456789012345678901234567890",
            recipientAddress: "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12",
            amount: "500.0"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["token_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["recipient_address"] as? String, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
        XCTAssertEqual(json["amount"] as? String, "500.0")
    }
    
    func testRedeemRequestEncoding() throws {
        let request = RedeemRequest(
            marketAddress: "0x1234567890123456789012345678901234567890",
            fTokenIn: "1.0",
            xTokenIn: "0.5",
            recipient: nil,
            minBaseOut: "1.4"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["market_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["f_token_in"] as? String, "1.0")
        XCTAssertEqual(json["x_token_in"] as? String, "0.5")
        XCTAssertEqual(json["min_base_out"] as? String, "1.4")
    }
    
    // MARK: - V1 Operation Request Tests
    
    func testRebalancePoolDepositRequestEncoding() throws {
        let request = RebalancePoolDepositRequest(
            amount: "100.0",
            recipient: "0x1234567890123456789012345678901234567890"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "100.0")
        XCTAssertEqual(json["recipient"] as? String, "0x1234567890123456789012345678901234567890")
    }
    
    func testRebalancePoolWithdrawRequestEncoding() throws {
        let request = RebalancePoolWithdrawRequest(claimRewards: true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["claim_rewards"] as? Bool, true)
    }
    
    func testRebalancePoolUnlockRequestEncoding() throws {
        let request = RebalancePoolUnlockRequest(amount: "50.0")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "50.0")
    }
    
    func testRebalancePoolClaimRequestEncoding() throws {
        let tokens = [
            "0x1234567890123456789012345678901234567890",
            "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12"
        ]
        let request = RebalancePoolClaimRequest(tokens: tokens)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let jsonTokens = json["tokens"] as! [String]
        XCTAssertEqual(jsonTokens.count, 2)
        XCTAssertEqual(jsonTokens[0], tokens[0])
        XCTAssertEqual(jsonTokens[1], tokens[1])
    }
    
    // MARK: - Savings & Stability Pool Request Tests
    
    func testSavingsDepositRequestEncoding() throws {
        let request = SavingsDepositRequest(amount: "1000.0")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "1000.0")
    }
    
    func testSavingsRedeemRequestEncoding() throws {
        let request = SavingsRedeemRequest(amount: "500.0")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "500.0")
    }
    
    func testStabilityPoolDepositRequestEncoding() throws {
        let request = StabilityPoolDepositRequest(amount: "2000.0")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "2000.0")
    }
    
    func testStabilityPoolWithdrawRequestEncoding() throws {
        let request = StabilityPoolWithdrawRequest(amount: "1000.0")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "1000.0")
    }
    
    // MARK: - V2 Operation Request Tests
    
    func testOperatePositionRequestEncoding() throws {
        let request = OperatePositionRequest(
            poolAddress: "0x1234567890123456789012345678901234567890",
            newCollateral: "10.0",
            newDebt: "5.0"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["pool_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["new_collateral"] as? String, "10.0")
        XCTAssertEqual(json["new_debt"] as? String, "5.0")
    }
    
    func testRebalancePositionRequestEncoding() throws {
        let request = RebalancePositionRequest(
            poolAddress: "0x1234567890123456789012345678901234567890",
            receiver: "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["pool_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["receiver"] as? String, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
    }
    
    func testLiquidatePositionRequestEncoding() throws {
        let request = LiquidatePositionRequest(
            poolAddress: "0x1234567890123456789012345678901234567890",
            receiver: nil
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["pool_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertNil(json["receiver"])
    }
    
    // MARK: - Governance Request Tests
    
    func testGaugeVoteRequestEncoding() throws {
        let request = GaugeVoteRequest(weight: "0.5")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["weight"] as? String, "0.5")
    }
    
    func testGaugeClaimRequestEncoding() throws {
        let request = GaugeClaimRequest(tokenAddress: "0x1234567890123456789012345678901234567890")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["token_address"] as? String, "0x1234567890123456789012345678901234567890")
    }
    
    func testGaugeClaimRequestWithoutTokenEncoding() throws {
        let request = GaugeClaimRequest(tokenAddress: nil)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertNil(json["token_address"])
    }
    
    func testVeFxnDepositRequestEncoding() throws {
        let unlockTime = Int(Date().timeIntervalSince1970) + 86400 * 365 // 1 year from now
        let request = VeFxnDepositRequest(amount: "1000.0", unlockTime: unlockTime)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount"] as? String, "1000.0")
        XCTAssertEqual(json["unlock_time"] as? Int, unlockTime)
    }
    
    // MARK: - Advanced Operation Request Tests
    
    func testRequestBonusRequestEncoding() throws {
        let request = RequestBonusRequest(
            tokenAddress: "0x1234567890123456789012345678901234567890",
            amount: "100.0",
            recipient: "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["token_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["amount"] as? String, "100.0")
        XCTAssertEqual(json["recipient"] as? String, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
    }
    
    func testMintViaTreasuryRequestEncoding() throws {
        let request = MintViaTreasuryRequest(
            baseIn: "5.0",
            recipient: "0x1234567890123456789012345678901234567890",
            option: 1
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["base_in"] as? String, "5.0")
        XCTAssertEqual(json["recipient"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["option"] as? Int, 1)
    }
    
    func testMintViaGatewayRequestEncoding() throws {
        let request = MintViaGatewayRequest(
            amountEth: "1.0",
            minTokenOut: "0.95",
            tokenType: "f"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["amount_eth"] as? String, "1.0")
        XCTAssertEqual(json["min_token_out"] as? String, "0.95")
        XCTAssertEqual(json["token_type"] as? String, "f")
    }
    
    func testSwapRequestEncoding() throws {
        let request = SwapRequest(
            tokenIn: "0x1234567890123456789012345678901234567890",
            amountIn: "100.0",
            encoding: 1,
            routes: [1, 2, 3]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["token_in"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["amount_in"] as? String, "100.0")
        XCTAssertEqual(json["encoding"] as? Int, 1)
        let jsonRoutes = json["routes"] as! [Int]
        XCTAssertEqual(jsonRoutes, [1, 2, 3])
    }
    
    func testFlashLoanRequestEncoding() throws {
        let request = FlashLoanRequest(
            tokenAddress: "0x1234567890123456789012345678901234567890",
            amount: "10000.0",
            receiver: "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12",
            data: "0x1234"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["token_address"] as? String, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(json["amount"] as? String, "10000.0")
        XCTAssertEqual(json["receiver"] as? String, "0xAbCdEf1234567890AbCdEf1234567890AbCdEf12")
        XCTAssertEqual(json["data"] as? String, "0x1234")
    }
}

