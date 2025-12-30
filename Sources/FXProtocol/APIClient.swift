// APIClient.swift
// HTTP client for interacting with the f(x) Protocol REST API
//
// Privacy: This client only makes requests to the configured API endpoint.
// No user data, analytics, or telemetry is collected or transmitted.

import Foundation

/// HTTP client wrapper for the f(x) Protocol REST API
internal class APIClient {
    private let baseURL: String
    private let apiKey: String?
    private let session: URLSession
    private let timeout: TimeInterval
    let cacheManager: CacheManager
    
    init(baseURL: String, apiKey: String? = nil, timeout: TimeInterval = 30.0, cacheManager: CacheManager? = nil) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.timeout = timeout
        self.cacheManager = cacheManager ?? CacheManager()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil
    ) async throws -> T {
        // Build URL
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw FXError.invalidResponse("Unable to connect to API. Please check the API URL configuration.")
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeout
        
        // Add API key if provided
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
        
        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw FXError.encodingError("Unable to prepare request data. Please check your input parameters.")
            }
        }
        
        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            // Provide user-friendly network error messages
            let errorMessage: String
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    errorMessage = "No internet connection. Please check your network settings."
                case .timedOut:
                    errorMessage = "Request timed out. The server took too long to respond. Please try again."
                case .cannotFindHost:
                    errorMessage = "Cannot reach server. Please check your internet connection and API URL."
                case .cannotConnectToHost:
                    errorMessage = "Cannot connect to server. Please check your internet connection."
                case .networkConnectionLost:
                    errorMessage = "Network connection lost. Please check your internet connection and try again."
                default:
                    errorMessage = "Network error: \(urlError.localizedDescription). Please check your connection and try again."
                }
            } else {
                errorMessage = "Network error: \(error.localizedDescription). Please check your connection and try again."
            }
            throw FXError.networkError(nil, errorMessage)
        }
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FXError.networkError(nil, "Unexpected response from server. Please try again.")
        }
        
        // Handle error status codes
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error response
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw FXError.apiError(errorResponse.code, errorResponse.message)
            }
            
            // Fallback to generic error with user-friendly message
            let statusCode = httpResponse.statusCode
            // Don't expose raw error messages to users, provide friendly message instead
            let friendlyMessage: String
            switch statusCode {
            case 400:
                friendlyMessage = "Invalid request. Please check your parameters and try again."
            case 401:
                friendlyMessage = "Authentication required. Please check your API key if required."
            case 403:
                friendlyMessage = "Access denied. You don't have permission for this operation."
            case 404:
                friendlyMessage = "Resource not found. Please check the endpoint and try again."
            case 429:
                friendlyMessage = "Too many requests. Please wait a moment and try again."
            case 500...599:
                friendlyMessage = "Server error. The API is experiencing issues. Please try again later."
            default:
                friendlyMessage = "Request failed. Please try again or contact support if the issue persists."
            }
            throw FXError.networkError(statusCode, friendlyMessage)
        }
        
        // Decode response
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // Don't expose technical decoding details to users
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            // Check if it's a known response format issue
            if errorMessage.contains("\"price\"") || errorMessage.contains("\"total_supply\"") {
                throw FXError.decodingError("Server returned data in an unexpected format. This may be a temporary API issue. Please try again later.")
            }
            throw FXError.decodingError("Unable to process server response. Please try again or contact support if the issue persists.")
        }
    }
    
    // MARK: - Health Endpoints
    
    func getHealth() async throws -> HealthResponse {
        return try await request(endpoint: "/health")
    }
    
    func getStatus() async throws -> StatusResponse {
        return try await request(endpoint: "/status")
    }
    
    // MARK: - Balance Endpoints
    
    func getAllBalances(address: String, useCache: Bool = true) async throws -> AllBalancesResponse {
        let cacheKey = "balance:all:\(address.lowercased())"
        
        // Check cache first
        if useCache {
            if let cached: AllBalancesResponse = await cacheManager.get(cacheKey, as: AllBalancesResponse.self) {
                return cached
            }
        }
        
        // Fetch from API
        let response: AllBalancesResponse = try await request(endpoint: "/balances/\(address)")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.balance)
        }
        
        return response
    }
    
    func getBalance(address: String, token: String, useCache: Bool = true) async throws -> BalanceResponse {
        let cacheKey = "balance:token:\(address.lowercased()):\(token.lowercased())"
        
        // Check cache first
        if useCache, let cached: BalanceResponse = await cacheManager.get(cacheKey, as: BalanceResponse.self) {
            return cached
        }
        
        // Fetch from API
        let response: BalanceResponse = try await request(endpoint: "/balances/\(address)/\(token)")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.balance)
        }
        
        return response
    }
    
    // Convenience methods for specific tokens
    func getFxusdBalance(address: String, useCache: Bool = true) async throws -> BalanceResponse {
        return try await getBalance(address: address, token: "fxusd", useCache: useCache)
    }
    
    func getFxnBalance(address: String, useCache: Bool = true) async throws -> BalanceResponse {
        return try await getBalance(address: address, token: "fxn", useCache: useCache)
    }
    
    func getFethBalance(address: String, useCache: Bool = true) async throws -> BalanceResponse {
        return try await getBalance(address: address, token: "feth", useCache: useCache)
    }
    
    func getXethBalance(address: String, useCache: Bool = true) async throws -> BalanceResponse {
        return try await getBalance(address: address, token: "xeth", useCache: useCache)
    }
    
    func getVefxnBalance(address: String, useCache: Bool = true) async throws -> BalanceResponse {
        return try await getBalance(address: address, token: "vefxn", useCache: useCache)
    }
    
    func getTokenBalance(address: String, tokenAddress: String, useCache: Bool = true) async throws -> BalanceResponse {
        let cacheKey = "balance:token:\(address.lowercased()):\(tokenAddress.lowercased())"
        
        // Check cache first
        if useCache {
            if let cached: BalanceResponse = await cacheManager.get(cacheKey, as: BalanceResponse.self) {
                return cached
            }
        }
        
        // Fetch from API
        let response: BalanceResponse = try await request(endpoint: "/balances/\(address)/token/\(tokenAddress)")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.balance)
        }
        
        return response
    }
    
    // MARK: - Protocol Endpoints
    
    func getProtocolNAV(useCache: Bool = true) async throws -> ProtocolInfoResponse {
        let cacheKey = "protocol:nav"
        
        // Check cache first
        if useCache {
            if let cached: ProtocolInfoResponse = await cacheManager.get(cacheKey, as: ProtocolInfoResponse.self) {
                return cached
            }
        }
        
        // Fetch from API
        let response: ProtocolInfoResponse = try await request(endpoint: "/protocol/nav")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.protocolInfo)
        }
        
        return response
    }
    
    func getTokenNAV(token: String, useCache: Bool = true) async throws -> TokenNavResponse {
        let cacheKey = "protocol:token_nav:\(token.lowercased())"
        
        // Check cache first
        if useCache {
            if let cached: TokenNavResponse = await cacheManager.get(cacheKey, as: TokenNavResponse.self) {
                return cached
            }
        }
        
        // Fetch from API
        let response: TokenNavResponse = try await request(endpoint: "/protocol/nav/\(token)")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.protocolInfo)
        }
        
        return response
    }
    
    func getStethPrice(useCache: Bool = true) async throws -> BalanceResponse {
        let cacheKey = "protocol:steth_price"
        
        // Check cache first
        if useCache, let cached: BalanceResponse = await cacheManager.get(cacheKey, as: BalanceResponse.self) {
            return cached
        }
        
        // Fetch from API
        let response: BalanceResponse = try await request(endpoint: "/protocol/steth-price")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.price)
        }
        
        return response
    }
    
    func getFxusdSupply(useCache: Bool = true) async throws -> BalanceResponse {
        let cacheKey = "protocol:fxusd_supply"
        
        // Check cache first
        if useCache, let cached: BalanceResponse = await cacheManager.get(cacheKey, as: BalanceResponse.self) {
            return cached
        }
        
        // Fetch from API
        let response: BalanceResponse = try await request(endpoint: "/protocol/fxusd/supply")
        
        // Cache the response
        if useCache {
            await cacheManager.set(response, for: cacheKey, ttl: CacheTTL.protocolInfo)
        }
        
        return response
    }
    
    func getPoolInfo(poolAddress: String) async throws -> ProtocolPoolInfoResponse {
        return try await request(endpoint: "/protocol/pool-info/\(poolAddress)")
    }
    
    func getMarketInfo(marketAddress: String) async throws -> ProtocolMarketInfoResponse {
        return try await request(endpoint: "/protocol/market-info/\(marketAddress)")
    }
    
    func getTreasuryInfo() async throws -> ProtocolTreasuryInfoResponse {
        return try await request(endpoint: "/protocol/treasury-info")
    }
    
    func getV1NAV() async throws -> ProtocolV1InfoResponse {
        return try await request(endpoint: "/protocol/v1/nav")
    }
    
    func getV1CollateralRatio() async throws -> BalanceResponse {
        return try await request(endpoint: "/protocol/v1/collateral-ratio")
    }
    
    func getV1RebalancePools() async throws -> [String] {
        struct Response: Codable {
            let rebalance_pools: [String]
        }
        let response: Response = try await request(endpoint: "/protocol/v1/rebalance-pools")
        return response.rebalance_pools
    }
    
    func getRebalancePoolBalances(poolAddress: String, address: String) async throws -> RebalancePoolBalancesResponse {
        return try await request(endpoint: "/protocol/v1/rebalance-pool/\(poolAddress)/balances/\(address)")
    }
    
    func getPegKeeperInfo() async throws -> ProtocolPegKeeperInfoResponse {
        return try await request(endpoint: "/protocol/peg-keeper")
    }
    
    // MARK: - V2 Endpoints
    
    func getV2PoolInfo(poolAddress: String) async throws -> V2PoolInfoResponse {
        return try await request(endpoint: "/v2/pool?pool_address=\(poolAddress)")
    }
    
    func getV2PositionInfo(positionId: Int) async throws -> V2PositionInfoResponse {
        return try await request(endpoint: "/v2/position/\(positionId)")
    }
    
    func getV2PoolManagerInfo(poolAddress: String) async throws -> V2PoolManagerInfoResponse {
        return try await request(endpoint: "/v2/pool-manager/\(poolAddress)")
    }
    
    func getV2ReservePoolInfo(tokenAddress: String) async throws -> V2ReservePoolInfoResponse {
        return try await request(endpoint: "/v2/reserve-pool/\(tokenAddress)")
    }
    
    // MARK: - Convex Endpoints
    
    func getAllConvexPools(page: Int = 1, limit: Int = 50) async throws -> ConvexPoolsListResponse {
        return try await request(endpoint: "/convex/pools?page=\(page)&limit=\(limit)")
    }
    
    func getConvexPoolInfo(poolId: Int) async throws -> ConvexPoolInfoResponse {
        return try await request(endpoint: "/convex/pool/\(poolId)")
    }
    
    func getConvexVaultInfo(vaultAddress: String) async throws -> ConvexVaultInfoResponse {
        return try await request(endpoint: "/convex/vault/\(vaultAddress)/info")
    }
    
    func getConvexVaultBalance(vaultAddress: String) async throws -> BalanceResponse {
        return try await request(endpoint: "/convex/vault/\(vaultAddress)/balance")
    }
    
    func getConvexVaultRewards(vaultAddress: String) async throws -> ConvexVaultRewardsResponse {
        return try await request(endpoint: "/convex/vault/\(vaultAddress)/rewards")
    }
    
    func getUserConvexVaults(address: String) async throws -> ConvexUserVaultsResponse {
        return try await request(endpoint: "/convex/user/\(address)/vaults")
    }
    
    // MARK: - Curve Endpoints
    
    func getCurvePools(page: Int = 1, limit: Int = 50) async throws -> CurvePoolsListResponse {
        return try await request(endpoint: "/curve/pools?page=\(page)&limit=\(limit)")
    }
    
    func getCurvePoolInfo(poolAddress: String) async throws -> CurvePoolInfoResponse {
        return try await request(endpoint: "/curve/pool/\(poolAddress)")
    }
    
    func getCurveGaugeBalance(gaugeAddress: String, userAddress: String) async throws -> CurveGaugeBalanceResponse {
        return try await request(endpoint: "/curve/gauge/\(gaugeAddress)/balance?user=\(userAddress)")
    }
    
    func getCurveGaugeRewards(gaugeAddress: String, userAddress: String) async throws -> CurveGaugeRewardsResponse {
        return try await request(endpoint: "/curve/gauge/\(gaugeAddress)/rewards?user=\(userAddress)")
    }
    
    // MARK: - Gauge Endpoints
    
    func getGaugeWeight(gaugeAddress: String) async throws -> GaugeWeightResponse {
        return try await request(endpoint: "/gauges/\(gaugeAddress)/weight")
    }
    
    func getGaugeRelativeWeight(gaugeAddress: String) async throws -> GaugeRelativeWeightResponse {
        return try await request(endpoint: "/gauges/\(gaugeAddress)/relative-weight")
    }
    
    func getGaugeRewards(gaugeAddress: String, address: String) async throws -> GaugeRewardsResponse {
        return try await request(endpoint: "/gauges/\(gaugeAddress)/rewards/\(address)")
    }
    
    func getAllGaugeRewards(address: String) async throws -> AllGaugeRewardsResponse {
        return try await request(endpoint: "/gauges/\(address)/all")
    }
    
    // MARK: - veFXN Endpoints
    
    func getVefxnInfo(address: String) async throws -> VefxnInfoResponse {
        return try await request(endpoint: "/vefxn/\(address)/info")
    }
    
    // MARK: - Transaction Endpoints
    
    // Generic transaction preparation helper
    private func prepareTransaction<T: Encodable>(
        endpoint: String,
        requestBody: T,
        estimateGas: Bool = false,
        fromAddress: String? = nil
    ) async throws -> TransactionDataResponse {
        var url = endpoint
        if estimateGas {
            url += "?estimate_gas=true"
            if let fromAddress = fromAddress {
                url += "&from_address=\(fromAddress)"
            }
        }
        return try await request(endpoint: url, method: .POST, body: requestBody)
    }
    
    // MARK: - Token Operations
    
    func prepareMintFToken(
        marketAddress: String,
        baseIn: String,
        recipient: String? = nil,
        minFTokenOut: String = "0",
        estimateGas: Bool = false,
        fromAddress: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = MintFTokenRequest(
            marketAddress: marketAddress,
            baseIn: baseIn,
            recipient: recipient,
            minFTokenOut: minFTokenOut
        )
        return try await prepareTransaction(
            endpoint: "/transactions/mint/f-token/prepare",
            requestBody: requestBody,
            estimateGas: estimateGas,
            fromAddress: fromAddress
        )
    }
    
    func prepareMintXToken(
        marketAddress: String,
        baseIn: String,
        recipient: String? = nil,
        minXTokenOut: String = "0"
    ) async throws -> TransactionDataResponse {
        let requestBody = MintXTokenRequest(
            marketAddress: marketAddress,
            baseIn: baseIn,
            recipient: recipient,
            minXTokenOut: minXTokenOut
        )
        return try await request(endpoint: "/transactions/mint/x-token/prepare", method: .POST, body: requestBody)
    }
    
    func prepareMintBothTokens(
        marketAddress: String,
        baseIn: String,
        recipient: String? = nil,
        minFTokenOut: String = "0",
        minXTokenOut: String = "0"
    ) async throws -> TransactionDataResponse {
        let requestBody = MintBothTokensRequest(
            marketAddress: marketAddress,
            baseIn: baseIn,
            recipient: recipient,
            minFTokenOut: minFTokenOut,
            minXTokenOut: minXTokenOut
        )
        return try await request(endpoint: "/transactions/mint/both/prepare", method: .POST, body: requestBody)
    }
    
    func prepareApprove(
        tokenAddress: String,
        spenderAddress: String,
        amount: String
    ) async throws -> TransactionDataResponse {
        let requestBody = ApproveRequest(
            tokenAddress: tokenAddress,
            spenderAddress: spenderAddress,
            amount: amount
        )
        return try await request(endpoint: "/transactions/approve/prepare", method: .POST, body: requestBody)
    }
    
    func prepareTransfer(
        tokenAddress: String,
        recipientAddress: String,
        amount: String
    ) async throws -> TransactionDataResponse {
        let requestBody = TransferRequest(
            tokenAddress: tokenAddress,
            recipientAddress: recipientAddress,
            amount: amount
        )
        return try await request(endpoint: "/transactions/transfer/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRedeem(
        marketAddress: String,
        fTokenIn: String = "0",
        xTokenIn: String = "0",
        recipient: String? = nil,
        minBaseOut: String = "0"
    ) async throws -> TransactionDataResponse {
        let requestBody = RedeemRequest(
            marketAddress: marketAddress,
            fTokenIn: fTokenIn,
            xTokenIn: xTokenIn,
            recipient: recipient,
            minBaseOut: minBaseOut
        )
        return try await request(endpoint: "/transactions/redeem/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRedeemViaTreasury(
        fTokenIn: String = "0",
        xTokenIn: String = "0",
        owner: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = RedeemViaTreasuryRequest(
            fTokenIn: fTokenIn,
            xTokenIn: xTokenIn,
            owner: owner
        )
        return try await request(endpoint: "/transactions/redeem/treasury/prepare", method: .POST, body: requestBody)
    }
    
    // MARK: - V1 Operations
    
    func prepareRebalancePoolDeposit(
        poolAddress: String,
        amount: String,
        recipient: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = RebalancePoolDepositRequest(amount: amount, recipient: recipient)
        return try await request(endpoint: "/transactions/v1/rebalance-pool/\(poolAddress)/deposit/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRebalancePoolWithdraw(
        poolAddress: String,
        claimRewards: Bool = true
    ) async throws -> TransactionDataResponse {
        let requestBody = RebalancePoolWithdrawRequest(claimRewards: claimRewards)
        return try await request(endpoint: "/transactions/v1/rebalance-pool/\(poolAddress)/withdraw/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRebalancePoolUnlock(
        poolAddress: String,
        amount: String
    ) async throws -> TransactionDataResponse {
        let requestBody = RebalancePoolUnlockRequest(amount: amount)
        return try await request(endpoint: "/transactions/v1/rebalance-pool/\(poolAddress)/unlock/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRebalancePoolClaim(
        poolAddress: String,
        tokens: [String]
    ) async throws -> TransactionDataResponse {
        let requestBody = RebalancePoolClaimRequest(tokens: tokens)
        return try await request(endpoint: "/transactions/v1/rebalance-pool/\(poolAddress)/claim/prepare", method: .POST, body: requestBody)
    }
    
    // MARK: - Savings & Stability Pool
    
    func prepareSavingsDeposit(amount: String) async throws -> TransactionDataResponse {
        let requestBody = SavingsDepositRequest(amount: amount)
        return try await request(endpoint: "/transactions/savings/deposit/prepare", method: .POST, body: requestBody)
    }
    
    func prepareSavingsRedeem(amount: String) async throws -> TransactionDataResponse {
        let requestBody = SavingsRedeemRequest(amount: amount)
        return try await request(endpoint: "/transactions/savings/redeem/prepare", method: .POST, body: requestBody)
    }
    
    func prepareStabilityPoolDeposit(amount: String) async throws -> TransactionDataResponse {
        let requestBody = StabilityPoolDepositRequest(amount: amount)
        return try await request(endpoint: "/transactions/stability-pool/deposit/prepare", method: .POST, body: requestBody)
    }
    
    func prepareStabilityPoolWithdraw(amount: String) async throws -> TransactionDataResponse {
        let requestBody = StabilityPoolWithdrawRequest(amount: amount)
        return try await request(endpoint: "/transactions/stability-pool/withdraw/prepare", method: .POST, body: requestBody)
    }
    
    // MARK: - V2 Operations
    
    func prepareOperatePosition(
        positionId: Int,
        poolAddress: String,
        newCollateral: String,
        newDebt: String
    ) async throws -> TransactionDataResponse {
        let requestBody = OperatePositionRequest(
            poolAddress: poolAddress,
            newCollateral: newCollateral,
            newDebt: newDebt
        )
        return try await request(endpoint: "/transactions/v2/position/\(positionId)/operate/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRebalancePosition(
        positionId: Int,
        poolAddress: String,
        receiver: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = RebalancePositionRequest(poolAddress: poolAddress, receiver: receiver)
        return try await request(endpoint: "/transactions/v2/position/\(positionId)/rebalance/prepare", method: .POST, body: requestBody)
    }
    
    func prepareLiquidatePosition(
        positionId: Int,
        poolAddress: String,
        receiver: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = LiquidatePositionRequest(poolAddress: poolAddress, receiver: receiver)
        return try await request(endpoint: "/transactions/v2/position/\(positionId)/liquidate/prepare", method: .POST, body: requestBody)
    }
    
    // MARK: - Governance
    
    func prepareGaugeVote(
        gaugeAddress: String,
        weight: String
    ) async throws -> TransactionDataResponse {
        let requestBody = GaugeVoteRequest(weight: weight)
        return try await request(endpoint: "/transactions/gauges/\(gaugeAddress)/vote/prepare", method: .POST, body: requestBody)
    }
    
    func prepareGaugeClaim(
        gaugeAddress: String,
        tokenAddress: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = GaugeClaimRequest(tokenAddress: tokenAddress)
        return try await request(endpoint: "/transactions/gauges/\(gaugeAddress)/claim/prepare", method: .POST, body: requestBody)
    }
    
    func prepareClaimAllGaugeRewards(
        gaugeAddresses: [String]? = nil
    ) async throws -> PreparedTransactionsResponse {
        let requestBody = ClaimAllGaugeRewardsRequest(gaugeAddresses: gaugeAddresses)
        return try await request(endpoint: "/transactions/gauges/claim-all/prepare", method: .POST, body: requestBody)
    }
    
    func prepareVeFxnDeposit(
        amount: String,
        unlockTime: Int
    ) async throws -> TransactionDataResponse {
        let requestBody = VeFxnDepositRequest(amount: amount, unlockTime: unlockTime)
        return try await request(endpoint: "/transactions/vefxn/deposit/prepare", method: .POST, body: requestBody)
    }
    
    // MARK: - Advanced Operations
    
    func prepareHarvest(poolAddress: String) async throws -> TransactionDataResponse {
        let requestBody = HarvestRequest()
        return try await request(endpoint: "/transactions/pool-manager/\(poolAddress)/harvest/prepare", method: .POST, body: requestBody)
    }
    
    func prepareRequestBonus(
        tokenAddress: String,
        amount: String,
        recipient: String? = nil
    ) async throws -> TransactionDataResponse {
        let requestBody = RequestBonusRequest(
            tokenAddress: tokenAddress,
            amount: amount,
            recipient: recipient
        )
        return try await request(endpoint: "/transactions/reserve-pool/request-bonus/prepare", method: .POST, body: requestBody)
    }
    
    func prepareMintViaTreasury(
        baseIn: String,
        recipient: String? = nil,
        option: Int = 0
    ) async throws -> TransactionDataResponse {
        let requestBody = MintViaTreasuryRequest(
            baseIn: baseIn,
            recipient: recipient,
            option: option
        )
        return try await request(endpoint: "/transactions/mint/treasury/prepare", method: .POST, body: requestBody)
    }
    
    func prepareMintViaGateway(
        amountEth: String,
        minTokenOut: String = "0",
        tokenType: String
    ) async throws -> TransactionDataResponse {
        let requestBody = MintViaGatewayRequest(
            amountEth: amountEth,
            minTokenOut: minTokenOut,
            tokenType: tokenType
        )
        return try await request(endpoint: "/transactions/mint/gateway/prepare", method: .POST, body: requestBody)
    }
    
    func prepareSwap(
        tokenIn: String,
        amountIn: String,
        encoding: Int,
        routes: [Int]
    ) async throws -> TransactionDataResponse {
        let requestBody = SwapRequest(
            tokenIn: tokenIn,
            amountIn: amountIn,
            encoding: encoding,
            routes: routes
        )
        return try await request(endpoint: "/transactions/swap/prepare", method: .POST, body: requestBody)
    }
    
    func prepareFlashLoan(
        tokenAddress: String,
        amount: String,
        receiver: String,
        data: String = "0x"
    ) async throws -> TransactionDataResponse {
        let requestBody = FlashLoanRequest(
            tokenAddress: tokenAddress,
            amount: amount,
            receiver: receiver,
            data: data
        )
        return try await request(endpoint: "/transactions/flash-loan/prepare", method: .POST, body: requestBody)
    }
    
    func prepareTreasuryHarvest() async throws -> TransactionDataResponse {
        let requestBody = HarvestRequest()
        return try await request(endpoint: "/transactions/treasury/harvest/prepare", method: .POST, body: requestBody)
    }
    
    func prepareVestingClaim(tokenType: String) async throws -> TransactionDataResponse {
        let requestBody = HarvestRequest()  // No body needed
        return try await request(endpoint: "/transactions/vesting/\(tokenType)/claim/prepare", method: .POST, body: requestBody)
    }
    
    // MARK: - Transaction Broadcasting & Status
    
    func broadcastTransaction(_ rawTransaction: String) async throws -> TransactionResponse {
        let requestBody = BroadcastTransactionRequest(rawTransaction: rawTransaction)
        return try await request(endpoint: "/transactions/broadcast", method: .POST, body: requestBody)
    }
    
    func getTransactionStatus(txHash: String) async throws -> TransactionStatusResponse {
        return try await request(endpoint: "/transactions/\(txHash)/status")
    }
}

// MARK: - HTTP Method

internal enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

