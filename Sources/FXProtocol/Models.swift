// Models.swift
// Data models for API requests and responses

import Foundation

// MARK: - Balance Models

/// Response for all token balances
public struct AllBalancesResponse: Codable {
    public let address: String
    public let balances: [String: String]  // token_name -> balance (as string)
    public let totalUsdValue: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case balances
        case totalUsdValue = "total_usd_value"
    }
}

/// Response for single token balance
public struct BalanceResponse: Codable {
    public let address: String
    public let token: String
    public let balance: String  // Decimal as string
    public let tokenAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case token
        case balance
        case tokenAddress = "token_address"
    }
}

// MARK: - Protocol Models

/// Protocol NAV response
public struct ProtocolInfoResponse: Codable {
    public let baseNav: String
    public let fNav: String
    public let xNav: String
    public let source: String
    public let note: String?
    
    enum CodingKeys: String, CodingKey {
        case baseNav = "base_nav"
        case fNav = "f_nav"
        case xNav = "x_nav"
        case source
        case note
    }
}

/// Token NAV response
public struct TokenNavResponse: Codable {
    public let token: String
    public let nav: String
    public let source: String
    public let note: String?
}

// MARK: - Health Models

/// Health check response
public struct HealthResponse: Codable {
    public let status: String
    public let version: String
}

/// Detailed status response
public struct StatusResponse: Codable {
    public let status: String
    public let version: String
    public let environment: String
    public let rpcConnected: Bool
    public let components: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case version
        case environment
        case rpcConnected = "rpc_connected"
        case components
    }
}

// MARK: - Transaction Models

/// Unsigned transaction data from API
public struct TransactionDataResponse: Codable {
    public let to: String
    public let data: String
    public let value: String
    public let gas: Int
    public let gasPrice: String?
    public let maxFeePerGas: String?
    public let maxPriorityFeePerGas: String?
    public let nonce: Int
    public let chainId: Int
    public let estimatedGas: Int?
    public let estimatedGasCostWei: String?
    
    enum CodingKeys: String, CodingKey {
        case to
        case data
        case value
        case gas
        case gasPrice
        case maxFeePerGas
        case maxPriorityFeePerGas
        case nonce
        case chainId
        case estimatedGas = "estimated_gas"
        case estimatedGasCostWei = "estimated_gas_cost_wei"
    }
}

/// Signed transaction for broadcasting
public struct BroadcastTransactionRequest: Codable {
    public let rawTransaction: String
    
    enum CodingKeys: String, CodingKey {
        case rawTransaction
    }
}

/// Transaction response after broadcasting
public struct TransactionResponse: Codable {
    public let success: Bool
    public let transactionHash: String
    public let status: String
    public let gasEstimate: Int?
    public let blockNumber: Int?
    
    enum CodingKeys: String, CodingKey {
        case success
        case transactionHash = "transaction_hash"
        case status
        case gasEstimate = "gas_estimate"
        case blockNumber = "block_number"
    }
}

/// Transaction status response
public struct TransactionStatusResponse: Codable {
    public let transactionHash: String
    public let status: String
    public let blockNumber: Int?
    public let confirmations: Int?
    public let gasUsed: Int?
    public let effectiveGasPrice: String?
    public let error: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case status
        case blockNumber = "block_number"
        case confirmations
        case gasUsed = "gas_used"
        case effectiveGasPrice = "effective_gas_price"
        case error
    }
}

// MARK: - Request Models

internal struct MintFTokenRequest: Codable {
    let marketAddress: String
    let baseIn: String
    let recipient: String?
    let minFTokenOut: String
    
    enum CodingKeys: String, CodingKey {
        case marketAddress = "market_address"
        case baseIn = "base_in"
        case recipient
        case minFTokenOut = "min_f_token_out"
    }
}

internal struct MintXTokenRequest: Codable {
    let marketAddress: String
    let baseIn: String
    let recipient: String?
    let minXTokenOut: String
    
    enum CodingKeys: String, CodingKey {
        case marketAddress = "market_address"
        case baseIn = "base_in"
        case recipient
        case minXTokenOut = "min_x_token_out"
    }
}

internal struct MintBothTokensRequest: Codable {
    let marketAddress: String
    let baseIn: String
    let recipient: String?
    let minFTokenOut: String
    let minXTokenOut: String
    
    enum CodingKeys: String, CodingKey {
        case marketAddress = "market_address"
        case baseIn = "base_in"
        case recipient
        case minFTokenOut = "min_f_token_out"
        case minXTokenOut = "min_x_token_out"
    }
}

internal struct ApproveRequest: Codable {
    let tokenAddress: String
    let spenderAddress: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case spenderAddress = "spender_address"
        case amount
    }
}

internal struct TransferRequest: Codable {
    let tokenAddress: String
    let recipientAddress: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case recipientAddress = "recipient_address"
        case amount
    }
}

internal struct RedeemRequest: Codable {
    let marketAddress: String
    let fTokenIn: String
    let xTokenIn: String
    let recipient: String?
    let minBaseOut: String
    
    enum CodingKeys: String, CodingKey {
        case marketAddress = "market_address"
        case fTokenIn = "f_token_in"
        case xTokenIn = "x_token_in"
        case recipient
        case minBaseOut = "min_base_out"
    }
}

internal struct RedeemViaTreasuryRequest: Codable {
    let fTokenIn: String
    let xTokenIn: String
    let owner: String?
    
    enum CodingKeys: String, CodingKey {
        case fTokenIn = "f_token_in"
        case xTokenIn = "x_token_in"
        case owner
    }
}

// MARK: - V1 Request Models

internal struct RebalancePoolDepositRequest: Codable {
    let amount: String
    let recipient: String?
}

internal struct RebalancePoolWithdrawRequest: Codable {
    let claimRewards: Bool
    
    enum CodingKeys: String, CodingKey {
        case claimRewards = "claim_rewards"
    }
}

internal struct RebalancePoolUnlockRequest: Codable {
    let amount: String
}

internal struct RebalancePoolClaimRequest: Codable {
    let tokens: [String]
}

// MARK: - Savings & Stability Pool Request Models

internal struct SavingsDepositRequest: Codable {
    let amount: String
}

internal struct SavingsRedeemRequest: Codable {
    let amount: String
}

internal struct StabilityPoolDepositRequest: Codable {
    let amount: String
}

internal struct StabilityPoolWithdrawRequest: Codable {
    let amount: String
}

// MARK: - V2 Request Models

internal struct OperatePositionRequest: Codable {
    let poolAddress: String
    let newCollateral: String
    let newDebt: String
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case newCollateral = "new_collateral"
        case newDebt = "new_debt"
    }
}

internal struct RebalancePositionRequest: Codable {
    let poolAddress: String
    let receiver: String?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case receiver
    }
}

internal struct LiquidatePositionRequest: Codable {
    let poolAddress: String
    let receiver: String?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case receiver
    }
}

// MARK: - Governance Request Models

internal struct GaugeVoteRequest: Codable {
    let weight: String
}

internal struct GaugeClaimRequest: Codable {
    let tokenAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
    }
}

internal struct ClaimAllGaugeRewardsRequest: Codable {
    let gaugeAddresses: [String]?
    
    enum CodingKeys: String, CodingKey {
        case gaugeAddresses = "gauge_addresses"
    }
}

internal struct VeFxnDepositRequest: Codable {
    let amount: String
    let unlockTime: Int
    
    enum CodingKeys: String, CodingKey {
        case amount
        case unlockTime = "unlock_time"
    }
}

// MARK: - Advanced Request Models

internal struct HarvestRequest: Codable {
    // No body needed, pool address in path
}

internal struct RequestBonusRequest: Codable {
    let tokenAddress: String
    let amount: String
    let recipient: String?
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case amount
        case recipient
    }
}

internal struct MintViaTreasuryRequest: Codable {
    let baseIn: String
    let recipient: String?
    let option: Int
    
    enum CodingKeys: String, CodingKey {
        case baseIn = "base_in"
        case recipient
        case option
    }
}

internal struct MintViaGatewayRequest: Codable {
    let amountEth: String
    let minTokenOut: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case amountEth = "amount_eth"
        case minTokenOut = "min_token_out"
        case tokenType = "token_type"
    }
}

internal struct SwapRequest: Codable {
    let tokenIn: String
    let amountIn: String
    let encoding: Int
    let routes: [Int]
    
    enum CodingKeys: String, CodingKey {
        case tokenIn = "token_in"
        case amountIn = "amount_in"
        case encoding
        case routes
    }
}

internal struct FlashLoanRequest: Codable {
    let tokenAddress: String
    let amount: String
    let receiver: String
    let data: String
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case amount
        case receiver
        case data
    }
}

// MARK: - Prepared Transactions Response

public struct PreparedTransactionsResponse: Codable {
    public let transactions: [TransactionDataResponse]
    public let count: Int
}

// MARK: - Protocol Info Models

/// Pool manager information response
public struct ProtocolPoolInfoResponse: Codable {
    public let poolAddress: String
    public let collateralCapacity: String?
    public let collateralBalance: String?
    public let debtCapacity: String?
    public let debtBalance: String?
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case collateralCapacity = "collateral_capacity"
        case collateralBalance = "collateral_balance"
        case debtCapacity = "debt_capacity"
        case debtBalance = "debt_balance"
        case details
    }
}

/// Market information response
public struct ProtocolMarketInfoResponse: Codable {
    public let marketAddress: String
    public let collateralRatio: String?
    public let totalCollateral: String?
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case marketAddress = "market_address"
        case collateralRatio = "collateral_ratio"
        case totalCollateral = "total_collateral"
        case details
    }
}

/// Treasury information response
public struct ProtocolTreasuryInfoResponse: Codable {
    public let treasuryAddress: String
    public let details: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case treasuryAddress = "treasury_address"
        case details
    }
}

/// V1 protocol information response
public struct ProtocolV1InfoResponse: Codable {
    public let nav: [String: String]?
    public let collateralRatio: String?
    public let rebalancePools: [String]?
    
    enum CodingKeys: String, CodingKey {
        case nav
        case collateralRatio = "collateral_ratio"
        case rebalancePools = "rebalance_pools"
    }
}

/// Rebalance pool balances response
public struct RebalancePoolBalancesResponse: Codable {
    public let poolAddress: String
    public let address: String
    public let staked: String
    public let unlocked: String
    public let unlocking: String
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case address
        case staked
        case unlocked
        case unlocking
    }
}

/// Peg Keeper information response
public struct ProtocolPegKeeperInfoResponse: Codable {
    public let isActive: Bool
    public let debtCeiling: String
    public let totalDebt: String
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case debtCeiling = "debt_ceiling"
        case totalDebt = "total_debt"
        case details
    }
}

// MARK: - V2 Models

/// V2 pool information response
public struct V2PoolInfoResponse: Codable {
    public let poolAddress: String
    public let totalAssets: String
    public let totalSupply: String
    public let basePoolAddress: String?
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case totalAssets = "total_assets"
        case totalSupply = "total_supply"
        case basePoolAddress = "base_pool_address"
        case details
    }
}

/// V2 position information response
public struct V2PositionInfoResponse: Codable {
    public let positionId: Int
    public let poolAddress: String
    public let owner: String
    public let collateral: String
    public let debt: String
    public let collateralRatio: String?
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case positionId = "position_id"
        case poolAddress = "pool_address"
        case owner
        case collateral
        case debt
        case collateralRatio = "collateral_ratio"
        case details
    }
}

/// V2 pool manager information response
public struct V2PoolManagerInfoResponse: Codable {
    public let poolAddress: String
    public let totalCollateral: String?
    public let totalDebt: String?
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case totalCollateral = "total_collateral"
        case totalDebt = "total_debt"
        case details
    }
}

// MARK: - Convex Models

/// Convex vault information response
public struct ConvexVaultInfoResponse: Codable {
    public let vaultAddress: String
    public let poolId: Int
    public let poolName: String?
    public let stakedBalance: String
    public let stakedToken: String?
    public let gaugeAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case vaultAddress = "vault_address"
        case poolId = "pool_id"
        case poolName = "pool_name"
        case stakedBalance = "staked_balance"
        case stakedToken = "staked_token"
        case gaugeAddress = "gauge_address"
    }
}

/// Convex vault rewards response
public struct ConvexVaultRewardsResponse: Codable {
    public let vaultAddress: String
    public let poolId: Int
    public let rewards: [String: String]  // token_address -> amount
    public let rewardTokens: [String]  // List of reward token addresses
    
    enum CodingKeys: String, CodingKey {
        case vaultAddress = "vault_address"
        case poolId = "pool_id"
        case rewards
        case rewardTokens = "reward_tokens"
    }
}

/// Convex pool information response
public struct ConvexPoolInfoResponse: Codable {
    public let poolId: Int
    public let poolName: String?
    public let lpToken: String?
    public let gaugeAddress: String?
    public let tvl: String?
    public let rewardTokens: [String]
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case poolId = "pool_id"
        case poolName = "pool_name"
        case lpToken = "lp_token"
        case gaugeAddress = "gauge_address"
        case tvl
        case rewardTokens = "reward_tokens"
        case details
    }
}

/// Convex pools list response
public struct ConvexPoolsListResponse: Codable {
    public let pools: [String: AnyCodable]  // pool_id -> pool_info
    public let totalPools: Int
    public let page: Int?
    public let limit: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case pools
        case totalPools = "total_pools"
        case page
        case limit
        case totalPages = "total_pages"
    }
}

/// User's Convex vaults response
public struct ConvexUserVaultsResponse: Codable {
    public let address: String
    public let vaults: [[String: AnyCodable]]  // List of vault info
    public let totalVaults: Int
    
    enum CodingKeys: String, CodingKey {
        case address
        case vaults
        case totalVaults = "total_vaults"
    }
}

// MARK: - Curve Models

/// Curve pool information response
public struct CurvePoolInfoResponse: Codable {
    public let poolAddress: String
    public let lpToken: String?
    public let gaugeAddress: String?
    public let virtualPrice: String?
    public let balances: [String]
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case lpToken = "lp_token"
        case gaugeAddress = "gauge_address"
        case virtualPrice = "virtual_price"
        case balances
        case details
    }
}

/// Curve gauge balance response
public struct CurveGaugeBalanceResponse: Codable {
    public let gaugeAddress: String
    public let userAddress: String
    public let stakedBalance: String
    public let lpToken: String?
    
    enum CodingKeys: String, CodingKey {
        case gaugeAddress = "gauge_address"
        case userAddress = "user_address"
        case stakedBalance = "staked_balance"
        case lpToken = "lp_token"
    }
}

/// Curve gauge rewards response
public struct CurveGaugeRewardsResponse: Codable {
    public let gaugeAddress: String
    public let userAddress: String
    public let rewards: [String: String]  // token_address -> amount
    public let rewardTokens: [String]
    
    enum CodingKeys: String, CodingKey {
        case gaugeAddress = "gauge_address"
        case userAddress = "user_address"
        case rewards
        case rewardTokens = "reward_tokens"
    }
}

/// Curve pools list response
public struct CurvePoolsListResponse: Codable {
    public let pools: [[String: AnyCodable]]
    public let totalPools: Int
    public let page: Int?
    public let limit: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case pools
        case totalPools = "total_pools"
        case page
        case limit
        case totalPages = "total_pages"
    }
}

// MARK: - Gauge Models

/// Gauge weight response
public struct GaugeWeightResponse: Codable {
    public let gaugeAddress: String
    public let weight: String
    
    enum CodingKeys: String, CodingKey {
        case gaugeAddress = "gauge_address"
        case weight
    }
}

/// Gauge relative weight response
public struct GaugeRelativeWeightResponse: Codable {
    public let gaugeAddress: String
    public let relativeWeight: String
    
    enum CodingKeys: String, CodingKey {
        case gaugeAddress = "gauge_address"
        case relativeWeight = "relative_weight"
    }
}

/// Gauge rewards response
public struct GaugeRewardsResponse: Codable {
    public let gaugeAddress: String
    public let address: String
    public let rewards: [String: String]  // token_address -> amount
    public let rewardTokens: [String]
    
    enum CodingKeys: String, CodingKey {
        case gaugeAddress = "gauge_address"
        case address
        case rewards
        case rewardTokens = "reward_tokens"
    }
}

/// All gauge rewards response
public struct AllGaugeRewardsResponse: Codable {
    public let address: String
    public let gauges: [String: [String: AnyCodable]]  // gauge_address -> rewards info
    public let totalGauges: Int
    
    enum CodingKeys: String, CodingKey {
        case address
        case gauges
        case totalGauges = "total_gauges"
    }
}

// MARK: - veFXN Models

/// veFXN locked information response
public struct VefxnInfoResponse: Codable {
    public let address: String
    public let veFxnBalance: String
    public let lockedFxn: String
    public let unlockTime: String?
    public let votingPower: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case veFxnBalance = "vefxn_balance"
        case lockedFxn = "locked_fxn"
        case unlockTime = "unlock_time"
        case votingPower = "voting_power"
    }
}

// MARK: - V2 Reserve Pool Model

/// V2 reserve pool information response
public struct V2ReservePoolInfoResponse: Codable {
    public let poolAddress: String
    public let totalReserves: String?
    public let bonusRatio: String?
    public let details: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case poolAddress = "pool_address"
        case totalReserves = "total_reserves"
        case bonusRatio = "bonus_ratio"
        case details
    }
}

// MARK: - Error Response

public struct ErrorResponse: Codable {
    public let error: Bool
    public let code: String
    public let message: String
    public let details: [String: AnyCodable]?
}

// MARK: - AnyCodable Helper

/// Helper for decoding dynamic JSON values
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded"
                )
            )
        }
    }
}

// MARK: - AnyCodable Decoding Helper

extension AnyCodable {
    /// Decode AnyCodable value to a specific Codable type
    func decode<T: Codable>(as type: T.Type) throws -> T {
        // Encode to JSON data, then decode to target type
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

