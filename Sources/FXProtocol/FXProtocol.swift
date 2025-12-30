// FXProtocol.swift
// Main entry point for the f(x) Protocol Swift SDK
//
// Privacy: This SDK does not collect, track, or transmit any user data, analytics,
// or usage statistics. All network requests go only to the configured API endpoint.
// Private keys are stored locally in iOS Keychain and never leave the device.

import Foundation

/// Main client for interacting with the f(x) Protocol
public class FXClient {
    private let apiClient: APIClient
    private let keychainManager: KeychainManager
    private let signer: TransactionSigner
    
    /// Cache manager for managing cached responses
    public var cacheManager: CacheManager {
        return apiClient.cacheManager
    }
    
    /// Initialize the FXClient
    /// - Parameters:
    ///   - baseURL: Base URL for the REST API (default: production API on Railway)
    ///   - apiKey: Optional API key for authentication
    public init(
        baseURL: String = "https://fx-api-production.up.railway.app/v1",
        apiKey: String? = nil
    ) {
        self.apiClient = APIClient(baseURL: baseURL, apiKey: apiKey)
        self.keychainManager = KeychainManager()
        self.signer = TransactionSigner()
    }
    
    // MARK: - Read Operations (No Auth Required)
    
    // MARK: - Health & Status
    
    /// Check API health
    public func getHealth() async throws -> HealthResponse {
        return try await apiClient.getHealth()
    }
    
    /// Get detailed API status
    public func getStatus() async throws -> StatusResponse {
        return try await apiClient.getStatus()
    }
    
    // MARK: - Balance Operations
    
    /// Get all token balances for an address
    /// - Parameters:
    ///   - address: Ethereum address
    ///   - useCache: Whether to use cached data (default: true)
    public func getAllBalances(address: String, useCache: Bool = true) async throws -> AllBalancesResponse {
        // Validate address
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getAllBalances(address: address, useCache: useCache)
    }
    
    /// Get balance for a specific token
    /// - Parameters:
    ///   - address: Ethereum address
    ///   - token: Token name (e.g., "fxn", "fxusd")
    ///   - useCache: Whether to use cached data (default: true)
    public func getBalance(address: String, token: String, useCache: Bool = true) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getBalance(address: address, token: token, useCache: useCache)
    }
    
    /// Get fxUSD balance
    public func getFxusdBalance(address: String) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getFxusdBalance(address: address)
    }
    
    /// Get FXN balance
    public func getFxnBalance(address: String) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getFxnBalance(address: address)
    }
    
    /// Get fETH balance
    public func getFethBalance(address: String) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getFethBalance(address: address)
    }
    
    /// Get xETH balance
    public func getXethBalance(address: String) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getXethBalance(address: address)
    }
    
    /// Get veFXN balance
    public func getVefxnBalance(address: String) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        return try await apiClient.getVefxnBalance(address: address)
    }
    
    /// Get balance for any ERC-20 token by contract address
    public func getTokenBalance(address: String, tokenAddress: String) async throws -> BalanceResponse {
        guard isValidEthereumAddress(address) else {
            throw FXError.invalidAddress(address)
        }
        guard isValidEthereumAddress(tokenAddress) else {
            throw FXError.invalidAddress(tokenAddress)
        }
        return try await apiClient.getTokenBalance(address: address, tokenAddress: tokenAddress)
    }
    
    // MARK: - Protocol Information
    
    /// Get protocol NAV (Net Asset Value)
    public func getProtocolNAV() async throws -> ProtocolInfoResponse {
        return try await apiClient.getProtocolNAV()
    }
    
    /// Get NAV for a specific token
    public func getTokenNAV(token: String) async throws -> TokenNavResponse {
        return try await apiClient.getTokenNAV(token: token)
    }
    
    /// Get stETH price
    public func getStethPrice() async throws -> BalanceResponse {
        return try await apiClient.getStethPrice()
    }
    
    /// Get fxUSD total supply
    public func getFxusdSupply() async throws -> BalanceResponse {
        return try await apiClient.getFxusdSupply()
    }
    
    // MARK: - Write Operations (Requires Wallet)
    
    /// Import a wallet and store private key securely
    public func importWallet(privateKey: String, address: String) throws {
        try keychainManager.storePrivateKey(privateKey, for: address)
    }
    
    // MARK: - Transaction Operations (Helper)
    
    /// Generic helper to prepare, sign, and broadcast a transaction
    private func executeTransaction(
        walletAddress: String,
        prepareTransaction: () async throws -> TransactionDataResponse
    ) async throws -> TransactionResponse {
        // Validate wallet address
        guard isValidEthereumAddress(walletAddress) else {
            throw FXError.invalidAddress(walletAddress)
        }
        
        // Get private key from Keychain
        guard let privateKey = try keychainManager.getPrivateKey(for: walletAddress) else {
            throw FXError.walletNotFound
        }
        
        // Prepare transaction via API
        let unsignedTx = try await prepareTransaction()
        
        // Sign transaction locally
        let rawTransaction = try signer.signTransaction(unsignedTx, privateKey: privateKey)
        
        // Broadcast signed transaction
        let response = try await apiClient.broadcastTransaction(rawTransaction)
        
        // Invalidate balance cache for the wallet address after write operations
        await cacheManager.invalidate(pattern: "balance:*:\(walletAddress.lowercased())")
        
        return response
    }
    
    // MARK: - Token Operations
    
    /// Mint f-token (e.g., fxUSD)
    public func mintFToken(
        marketAddress: String,
        baseIn: String,
        walletAddress: String,
        recipient: String? = nil,
        minFTokenOut: String = "0",
        estimateGas: Bool = false
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(marketAddress) else {
            throw FXError.invalidAddress(marketAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareMintFToken(
                marketAddress: marketAddress,
                baseIn: baseIn,
                recipient: recipient ?? walletAddress,
                minFTokenOut: minFTokenOut,
                estimateGas: estimateGas,
                fromAddress: estimateGas ? walletAddress : nil
            )
        }
    }
    
    /// Mint x-token (e.g., xETH)
    public func mintXToken(
        marketAddress: String,
        baseIn: String,
        walletAddress: String,
        recipient: String? = nil,
        minXTokenOut: String = "0"
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(marketAddress) else {
            throw FXError.invalidAddress(marketAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareMintXToken(
                marketAddress: marketAddress,
                baseIn: baseIn,
                recipient: recipient ?? walletAddress,
                minXTokenOut: minXTokenOut
            )
        }
    }
    
    /// Mint both f-token and x-token
    public func mintBothTokens(
        marketAddress: String,
        baseIn: String,
        walletAddress: String,
        recipient: String? = nil,
        minFTokenOut: String = "0",
        minXTokenOut: String = "0"
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(marketAddress) else {
            throw FXError.invalidAddress(marketAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareMintBothTokens(
                marketAddress: marketAddress,
                baseIn: baseIn,
                recipient: recipient ?? walletAddress,
                minFTokenOut: minFTokenOut,
                minXTokenOut: minXTokenOut
            )
        }
    }
    
    /// Approve token spending
    public func approve(
        tokenAddress: String,
        spenderAddress: String,
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(tokenAddress) else {
            throw FXError.invalidAddress(tokenAddress)
        }
        guard isValidEthereumAddress(spenderAddress) else {
            throw FXError.invalidAddress(spenderAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareApprove(
                tokenAddress: tokenAddress,
                spenderAddress: spenderAddress,
                amount: amount
            )
        }
    }
    
    /// Transfer tokens
    public func transfer(
        tokenAddress: String,
        recipientAddress: String,
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(tokenAddress) else {
            throw FXError.invalidAddress(tokenAddress)
        }
        guard isValidEthereumAddress(recipientAddress) else {
            throw FXError.invalidAddress(recipientAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareTransfer(
                tokenAddress: tokenAddress,
                recipientAddress: recipientAddress,
                amount: amount
            )
        }
    }
    
    /// Redeem tokens
    public func redeem(
        marketAddress: String,
        walletAddress: String,
        fTokenIn: String = "0",
        xTokenIn: String = "0",
        recipient: String? = nil,
        minBaseOut: String = "0"
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(marketAddress) else {
            throw FXError.invalidAddress(marketAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRedeem(
                marketAddress: marketAddress,
                fTokenIn: fTokenIn,
                xTokenIn: xTokenIn,
                recipient: recipient ?? walletAddress,
                minBaseOut: minBaseOut
            )
        }
    }
    
    /// Redeem via treasury
    public func redeemViaTreasury(
        walletAddress: String,
        fTokenIn: String = "0",
        xTokenIn: String = "0",
        owner: String? = nil
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRedeemViaTreasury(
                fTokenIn: fTokenIn,
                xTokenIn: xTokenIn,
                owner: owner ?? walletAddress
            )
        }
    }
    
    // MARK: - V1 Operations
    
    /// Deposit to rebalance pool
    public func depositToRebalancePool(
        poolAddress: String,
        amount: String,
        walletAddress: String,
        recipient: String? = nil
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRebalancePoolDeposit(
                poolAddress: poolAddress,
                amount: amount,
                recipient: recipient ?? walletAddress
            )
        }
    }
    
    /// Withdraw from rebalance pool
    public func withdrawFromRebalancePool(
        poolAddress: String,
        walletAddress: String,
        claimRewards: Bool = true
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRebalancePoolWithdraw(
                poolAddress: poolAddress,
                claimRewards: claimRewards
            )
        }
    }
    
    /// Unlock from rebalance pool
    public func unlockFromRebalancePool(
        poolAddress: String,
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRebalancePoolUnlock(
                poolAddress: poolAddress,
                amount: amount
            )
        }
    }
    
    /// Claim rewards from rebalance pool
    public func claimRebalancePoolRewards(
        poolAddress: String,
        tokens: [String],
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRebalancePoolClaim(
                poolAddress: poolAddress,
                tokens: tokens
            )
        }
    }
    
    // MARK: - Savings & Stability Pool
    
    /// Deposit to fxSAVE
    public func depositToSavings(
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareSavingsDeposit(amount: amount)
        }
    }
    
    /// Redeem from fxSAVE
    public func redeemFromSavings(
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareSavingsRedeem(amount: amount)
        }
    }
    
    /// Deposit to stability pool
    public func depositToStabilityPool(
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareStabilityPoolDeposit(amount: amount)
        }
    }
    
    /// Withdraw from stability pool
    public func withdrawFromStabilityPool(
        amount: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareStabilityPoolWithdraw(amount: amount)
        }
    }
    
    // MARK: - V2 Operations
    
    /// Operate V2 position
    public func operatePosition(
        positionId: Int,
        poolAddress: String,
        newCollateral: String,
        newDebt: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareOperatePosition(
                positionId: positionId,
                poolAddress: poolAddress,
                newCollateral: newCollateral,
                newDebt: newDebt
            )
        }
    }
    
    /// Rebalance V2 position
    public func rebalancePosition(
        positionId: Int,
        poolAddress: String,
        walletAddress: String,
        receiver: String? = nil
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRebalancePosition(
                positionId: positionId,
                poolAddress: poolAddress,
                receiver: receiver ?? walletAddress
            )
        }
    }
    
    /// Liquidate V2 position
    public func liquidatePosition(
        positionId: Int,
        poolAddress: String,
        walletAddress: String,
        receiver: String? = nil
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareLiquidatePosition(
                positionId: positionId,
                poolAddress: poolAddress,
                receiver: receiver ?? walletAddress
            )
        }
    }
    
    // MARK: - Governance
    
    /// Vote for gauge
    public func voteForGauge(
        gaugeAddress: String,
        weight: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(gaugeAddress) else {
            throw FXError.invalidAddress(gaugeAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareGaugeVote(
                gaugeAddress: gaugeAddress,
                weight: weight
            )
        }
    }
    
    /// Claim gauge rewards
    public func claimGaugeRewards(
        gaugeAddress: String,
        walletAddress: String,
        tokenAddress: String? = nil
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(gaugeAddress) else {
            throw FXError.invalidAddress(gaugeAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareGaugeClaim(
                gaugeAddress: gaugeAddress,
                tokenAddress: tokenAddress
            )
        }
    }
    
    /// Lock FXN to create veFXN
    public func lockFXN(
        amount: String,
        unlockTime: Int,
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareVeFxnDeposit(
                amount: amount,
                unlockTime: unlockTime
            )
        }
    }
    
    /// Claim vesting tokens
    public func claimVesting(
        tokenType: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareVestingClaim(tokenType: tokenType)
        }
    }
    
    // MARK: - Advanced Operations
    
    /// Harvest pool manager rewards
    public func harvestPoolManager(
        poolAddress: String,
        walletAddress: String
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(poolAddress) else {
            throw FXError.invalidAddress(poolAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareHarvest(poolAddress: poolAddress)
        }
    }
    
    /// Request bonus from reserve pool
    public func requestBonus(
        tokenAddress: String,
        amount: String,
        walletAddress: String,
        recipient: String? = nil
    ) async throws -> TransactionResponse {
        guard isValidEthereumAddress(tokenAddress) else {
            throw FXError.invalidAddress(tokenAddress)
        }
        
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareRequestBonus(
                tokenAddress: tokenAddress,
                amount: amount,
                recipient: recipient ?? walletAddress
            )
        }
    }
    
    /// Mint via treasury
    public func mintViaTreasury(
        baseIn: String,
        walletAddress: String,
        recipient: String? = nil,
        option: Int = 0
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareMintViaTreasury(
                baseIn: baseIn,
                recipient: recipient ?? walletAddress,
                option: option
            )
        }
    }
    
    /// Mint via gateway
    public func mintViaGateway(
        amountEth: String,
        tokenType: String,
        walletAddress: String,
        minTokenOut: String = "0"
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareMintViaGateway(
                amountEth: amountEth,
                minTokenOut: minTokenOut,
                tokenType: tokenType
            )
        }
    }
    
    /// Harvest treasury
    public func harvestTreasury(
        walletAddress: String
    ) async throws -> TransactionResponse {
        return try await executeTransaction(walletAddress: walletAddress) {
            try await apiClient.prepareTreasuryHarvest()
        }
    }
    
    // MARK: - Transaction Status
    
    /// Get transaction status
    public func getTransactionStatus(txHash: String) async throws -> TransactionStatusResponse {
        return try await apiClient.getTransactionStatus(txHash: txHash)
    }
}

// MARK: - Address Validation

extension FXClient {
    /// Validate Ethereum address format
    private func isValidEthereumAddress(_ address: String) -> Bool {
        // Basic format check: 0x followed by 40 hex characters
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex?.firstMatch(in: address, options: [], range: range) != nil
    }
}

// MARK: - Errors

public enum FXError: Error, LocalizedError {
    case walletNotFound
    case invalidAddress(String)
    case transactionFailed(String?)
    case networkError(Int?, String?)
    case invalidResponse(String?)
    case apiError(String, String)  // code, message
    case encodingError(String)
    case decodingError(String)
    case keychainError(String)
    case signingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .walletNotFound:
            return "Wallet not found. Please import your wallet first using importWallet(privateKey:address:)."
        case .invalidAddress(let address):
            return "Invalid Ethereum address format: '\(address)'. Address must start with '0x' and be 42 characters long (e.g., '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb')."
        case .transactionFailed(let message):
            if let message = message, !message.isEmpty {
                return "Transaction failed: \(message). Please check the transaction details and try again."
            }
            return "Transaction failed. Please check your network connection and transaction parameters, then try again."
        case .networkError(let statusCode, let message):
            if let statusCode = statusCode {
                switch statusCode {
                case 400:
                    return "Bad request (HTTP 400). Please check your request parameters and try again."
                case 401:
                    return "Unauthorized (HTTP 401). Please check your API key if required."
                case 403:
                    return "Forbidden (HTTP 403). You don't have permission to access this resource."
                case 404:
                    return "Not found (HTTP 404). The requested resource was not found."
                case 429:
                    return "Rate limit exceeded (HTTP 429). Please wait a moment and try again. Rate limits: 100 requests/minute, 5000 requests/hour."
                case 500...599:
                    return "Server error (HTTP \(statusCode)). The API is experiencing issues. Please try again later."
                default:
                    if let message = message, !message.isEmpty {
                        return "Network error (HTTP \(statusCode)): \(message). Please check your internet connection and try again."
                    }
                    return "Network error (HTTP \(statusCode)). Please check your internet connection and try again."
                }
            }
            if let message = message, !message.isEmpty {
                return "Network error: \(message). Please check your internet connection and try again."
            }
            return "Network error. Please check your internet connection and try again."
        case .invalidResponse(let message):
            if let message = message, !message.isEmpty {
                return "Invalid response from server: \(message). Please try again or contact support if the issue persists."
            }
            return "Invalid response from server. Please try again or contact support if the issue persists."
        case .apiError(let code, let message):
            // Provide user-friendly messages for common API error codes
            let friendlyCode = code.uppercased()
            let friendlyMessage: String
            switch friendlyCode {
            case "RATE_LIMIT_EXCEEDED", "TOO_MANY_REQUESTS":
                friendlyMessage = "Rate limit exceeded. Please wait a moment and try again. Limits: 100 requests/minute, 5000 requests/hour."
            case "INVALID_ADDRESS":
                friendlyMessage = "Invalid address format. Please check the address and try again."
            case "INSUFFICIENT_BALANCE":
                friendlyMessage = "Insufficient balance. Please check your account balance and try again."
            case "TRANSACTION_FAILED":
                friendlyMessage = "Transaction failed on the blockchain. Please check the transaction details and try again."
            case "INTERNAL_ERROR":
                friendlyMessage = "API internal error. The server encountered an issue. Please try again later."
            default:
                friendlyMessage = message.isEmpty ? "An error occurred" : message
            }
            return "API error (\(code)): \(friendlyMessage)"
        case .encodingError(let message):
            return "Failed to prepare request data: \(message). This is usually a temporary issue. Please try again."
        case .decodingError(let message):
            // Don't expose technical details to users
            if message.contains("The data couldn't be read") {
                return "Invalid response format from server. Please try again or contact support if the issue persists."
            }
            return "Failed to process server response: \(message). Please try again or contact support."
        case .keychainError(let message):
            if message.contains("Invalid private key format") {
                return "Invalid private key format. Private key must start with '0x' and be 66 characters long (64 hex characters + '0x' prefix)."
            }
            if message.contains("store") {
                return "Failed to save wallet to secure storage: \(message). Please check your device's security settings and try again."
            }
            if message.contains("retrieve") {
                return "Failed to access wallet from secure storage: \(message). Please ensure the wallet was previously imported."
            }
            if message.contains("delete") {
                return "Failed to remove wallet from secure storage: \(message). Please try again."
            }
            return "Secure storage error: \(message). Please try again or check your device's security settings."
        case .signingError(let message):
            if message.contains("Private key must start with 0x") {
                return "Invalid private key format. Private key must start with '0x' prefix."
            }
            if message.contains("Invalid private key length") {
                return "Invalid private key length. Private key must be 66 characters (64 hex characters + '0x' prefix)."
            }
            if message.contains("Invalid 'to' address") {
                return "Invalid recipient address in transaction. Please check the address format."
            }
            if message.contains("Missing gas price") {
                return "Transaction missing gas price information. This may be a temporary API issue. Please try again."
            }
            if message.contains("Unable to create transaction") {
                return "Failed to prepare transaction. Please check the transaction parameters and try again."
            }
            return "Transaction signing failed: \(message). Please ensure your wallet is properly imported and try again."
        }
    }
}

