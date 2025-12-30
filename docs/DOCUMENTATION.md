# f(x) Protocol Swift SDK - Complete Documentation

**Version:** 1.0.0  
**Last Updated:** December 29, 2025  
**Platform:** iOS 15.0+, macOS 12.0+  
**Swift:** 5.9+

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
5. [API Reference](#api-reference)
6. [Data Models](#data-models)
7. [Error Handling](#error-handling)
8. [Caching](#caching)
9. [Security & Privacy](#security--privacy)
10. [Advanced Usage](#advanced-usage)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)
13. [Examples](#examples)
14. [Testing](#testing)

---

## Overview

The f(x) Protocol Swift SDK is a native iOS/macOS library for interacting with the f(x) Protocol on Ethereum. It provides a type-safe, Swift-native interface for reading protocol data and executing transactions.

### Key Features

- ✅ **Complete API Coverage** - All read and write operations
- ✅ **Type-Safe** - Full Swift type safety with Codable models
- ✅ **Client-Side Signing** - All transactions signed locally
- ✅ **Secure Storage** - Private keys in iOS Keychain
- ✅ **Built-in Caching** - Memory and disk caching
- ✅ **Async/Await** - Modern Swift concurrency
- ✅ **Zero Data Collection** - No analytics or tracking
- ✅ **Comprehensive Tests** - 93+ unit and integration tests

### What It Does

- Query balances, protocol info, pool data, and more
- Execute 30+ transaction types (mint, redeem, stake, vote, etc.)
- Manage wallets securely
- Cache responses for offline access
- Handle errors gracefully

### What It Doesn't Do

- ❌ No analytics or tracking
- ❌ No data collection
- ❌ No third-party services
- ❌ No RPC connection management (uses REST API)

---

## Architecture

### System Architecture

```
┌─────────────────┐
│   iOS/macOS App │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   FXClient      │  ← Main entry point
│   (Swift SDK)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌──────────────┐
│APIClient│ │KeychainMgr  │
│(HTTP)  │ │(Storage)     │
└───┬────┘ └──────────────┘
    │
    ▼
┌─────────────────────────┐
│  REST API (FastAPI)     │
│  (Railway/Production)   │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Python SDK (fx-sdk)    │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Ethereum Blockchain    │
└─────────────────────────┘
```

### Component Overview

1. **FXClient** - Main client class, public API
2. **APIClient** - HTTP client for REST API calls
3. **TransactionSigner** - Client-side transaction signing (Web3.swift)
4. **KeychainManager** - Secure private key storage
5. **CacheManager** - Response caching (memory + disk)
6. **Models** - Type-safe data models

### Transaction Flow

```
1. User calls write operation (e.g., mintFToken)
   ↓
2. FXClient validates inputs
   ↓
3. Get private key from Keychain
   ↓
4. APIClient calls API /prepare endpoint
   ↓
5. API returns unsigned transaction
   ↓
6. TransactionSigner signs locally (Web3.swift)
   ↓
7. APIClient broadcasts signed transaction
   ↓
8. API returns transaction hash
   ↓
9. Cache invalidated for affected addresses
```

---

## Installation

### Swift Package Manager

#### Xcode

1. File → Add Packages...
2. Enter repository URL: `https://github.com/chrisstampar/fx-swift.git`
3. Select version or branch
4. Add to target

#### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/chrisstampar/fx-swift.git", from: "1.0.0")
]
```

### Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

### Dependencies

The SDK includes these dependencies (automatically resolved):

- **BigInt** (5.0.0+) - Large number handling
- **Web3.swift** (0.5.0+) - Ethereum transaction signing
- **KeychainAccess** (4.0.0+) - iOS Keychain wrapper

---

## Quick Start

### Basic Setup

```swift
import FXProtocol

// Initialize client (uses production API by default)
let client = FXClient()

// Or specify custom API URL
let client = FXClient(baseURL: "https://fx-api-production.up.railway.app/v1")
```

### Read Operations (No Auth Required)

```swift
// Get all balances for an address
let balances = try await client.getAllBalances(
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)

// Get specific token balance
let fxusdBalance = try await client.getBalance(
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    token: "fxusd"
)

// Get protocol NAV
let nav = try await client.getProtocolNAV()
print("Base NAV: \(nav.baseNav)")
```

### Write Operations (Requires Wallet)

```swift
// 1. Import wallet (stores private key securely)
try client.importWallet(
    privateKey: "0x...",  // Your private key
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)

// 2. Execute transaction
let tx = try await client.mintFToken(
    marketAddress: "0x...",
    baseIn: "1000000000000000000",  // 1 ETH in wei
    walletAddress: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)

// 3. Track transaction
let status = try await client.getTransactionStatus(txHash: tx.transactionHash)
print("Status: \(status.status)")
```

---

## API Reference

### FXClient

Main client class for interacting with the f(x) Protocol.

#### Initialization

```swift
public init(
    baseURL: String = "https://fx-api-production.up.railway.app/v1",
    apiKey: String? = nil
)
```

**Parameters:**
- `baseURL`: Base URL for the REST API (default: production)
- `apiKey`: Optional API key for authentication

**Example:**
```swift
let client = FXClient()
let customClient = FXClient(baseURL: "https://custom-api.com/v1", apiKey: "your-key")
```

#### Properties

```swift
public var cacheManager: CacheManager
```

Access to the cache manager for cache operations.

---

### Read Operations

#### Health & Status

##### `getHealth()`

Check API health status.

```swift
public func getHealth() async throws -> HealthResponse
```

**Returns:** `HealthResponse` with status and version

**Example:**
```swift
let health = try await client.getHealth()
print("Status: \(health.status), Version: \(health.version)")
```

##### `getStatus()`

Get detailed API status information.

```swift
public func getStatus() async throws -> StatusResponse
```

**Returns:** `StatusResponse` with detailed status

---

#### Balance Operations

##### `getAllBalances(address:useCache:)`

Get all token balances for an address.

```swift
public func getAllBalances(
    address: String,
    useCache: Bool = true
) async throws -> AllBalancesResponse
```

**Parameters:**
- `address`: Ethereum address (0x format)
- `useCache`: Whether to use cached data (default: true)

**Returns:** `AllBalancesResponse` with all token balances

**Example:**
```swift
let balances = try await client.getAllBalances(
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)
print("fxUSD: \(balances.balances["fxusd"] ?? "0")")
print("FXN: \(balances.balances["fxn"] ?? "0")")
```

##### `getBalance(address:token:useCache:)`

Get balance for a specific token.

```swift
public func getBalance(
    address: String,
    token: String,
    useCache: Bool = true
) async throws -> BalanceResponse
```

**Parameters:**
- `address`: Ethereum address
- `token`: Token name (e.g., "fxusd", "fxn", "feth")
- `useCache`: Whether to use cached data

**Returns:** `BalanceResponse` with token balance

**Example:**
```swift
let balance = try await client.getBalance(
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    token: "fxusd"
)
print("Balance: \(balance.balance)")
```

##### Convenience Methods

```swift
// Get specific token balances
public func getFxusdBalance(address: String) async throws -> BalanceResponse
public func getFxnBalance(address: String) async throws -> BalanceResponse
public func getFethBalance(address: String) async throws -> BalanceResponse
public func getXethBalance(address: String) async throws -> BalanceResponse
public func getVefxnBalance(address: String) async throws -> BalanceResponse

// Get ERC-20 token balance by contract address
public func getTokenBalance(
    address: String,
    tokenAddress: String
) async throws -> BalanceResponse
```

---

#### Protocol Information

##### `getProtocolNAV()`

Get protocol Net Asset Value (NAV).

```swift
public func getProtocolNAV() async throws -> ProtocolInfoResponse
```

**Returns:** `ProtocolInfoResponse` with base NAV, f NAV, x NAV

**Example:**
```swift
let nav = try await client.getProtocolNAV()
print("Base NAV: \(nav.baseNav)")
print("f NAV: \(nav.fNav)")
print("x NAV: \(nav.xNav)")
```

##### `getTokenNAV(token:)`

Get NAV for a specific token.

```swift
public func getTokenNAV(token: String) async throws -> TokenNavResponse
```

**Parameters:**
- `token`: Token name (e.g., "feth", "xeth", "xcvx")

**Returns:** `TokenNavResponse` with token NAV

##### `getStethPrice()`

Get stETH price.

```swift
public func getStethPrice() async throws -> BalanceResponse
```

##### `getFxusdSupply()`

Get fxUSD total supply.

```swift
public func getFxusdSupply() async throws -> BalanceResponse
```

---

### Write Operations

All write operations follow this pattern:
1. Import wallet (if not already imported)
2. Call the operation method
3. SDK handles: prepare → sign → broadcast
4. Returns transaction hash

#### Wallet Management

##### `importWallet(privateKey:address:)`

Import a wallet and store private key securely in Keychain.

```swift
public func importWallet(
    privateKey: String,
    address: String
) throws
```

**Parameters:**
- `privateKey`: Private key (hex string with 0x prefix, 66 characters)
- `address`: Wallet address (0x format, 42 characters)

**Throws:** `FXError.keychainError` if storage fails

**Example:**
```swift
try client.importWallet(
    privateKey: "0x1234567890abcdef...",
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)
```

**Security Note:** Private keys are stored in iOS Keychain with `.whenUnlockedThisDeviceOnly` accessibility.

---

#### Token Operations

##### `mintFToken(marketAddress:baseIn:walletAddress:recipient:minFTokenOut:estimateGas:)`

Mint f-token (e.g., fxUSD).

```swift
public func mintFToken(
    marketAddress: String,
    baseIn: String,
    walletAddress: String,
    recipient: String? = nil,
    minFTokenOut: String = "0",
    estimateGas: Bool = false
) async throws -> TransactionResponse
```

**Parameters:**
- `marketAddress`: Market contract address
- `baseIn`: Amount of base token (wei, as string)
- `walletAddress`: Wallet address (must be imported)
- `recipient`: Optional recipient address (default: walletAddress)
- `minFTokenOut`: Minimum f-token output (default: "0")
- `estimateGas`: Whether to estimate gas (default: false)

**Returns:** `TransactionResponse` with transaction hash

**Example:**
```swift
let tx = try await client.mintFToken(
    marketAddress: "0x...",
    baseIn: "1000000000000000000",  // 1 ETH
    walletAddress: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)
```

##### `mintXToken(marketAddress:baseIn:walletAddress:recipient:minXTokenOut:)`

Mint x-token (e.g., xETH).

```swift
public func mintXToken(
    marketAddress: String,
    baseIn: String,
    walletAddress: String,
    recipient: String? = nil,
    minXTokenOut: String = "0"
) async throws -> TransactionResponse
```

##### `mintBothTokens(marketAddress:baseIn:walletAddress:recipient:minFTokenOut:minXTokenOut:)`

Mint both f-token and x-token.

```swift
public func mintBothTokens(
    marketAddress: String,
    baseIn: String,
    walletAddress: String,
    recipient: String? = nil,
    minFTokenOut: String = "0",
    minXTokenOut: String = "0"
) async throws -> TransactionResponse
```

##### `approve(tokenAddress:spenderAddress:amount:walletAddress:)`

Approve token spending.

```swift
public func approve(
    tokenAddress: String,
    spenderAddress: String,
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `transfer(tokenAddress:recipientAddress:amount:walletAddress:)`

Transfer tokens.

```swift
public func transfer(
    tokenAddress: String,
    recipientAddress: String,
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `redeem(marketAddress:walletAddress:fTokenIn:xTokenIn:recipient:minBaseOut:)`

Redeem tokens.

```swift
public func redeem(
    marketAddress: String,
    walletAddress: String,
    fTokenIn: String = "0",
    xTokenIn: String = "0",
    recipient: String? = nil,
    minBaseOut: String = "0"
) async throws -> TransactionResponse
```

##### `redeemViaTreasury(walletAddress:fTokenIn:xTokenIn:owner:)`

Redeem via treasury.

```swift
public func redeemViaTreasury(
    walletAddress: String,
    fTokenIn: String = "0",
    xTokenIn: String = "0",
    owner: String? = nil
) async throws -> TransactionResponse
```

---

#### V1 Operations

##### `depositToRebalancePool(poolAddress:amount:walletAddress:recipient:)`

Deposit to rebalance pool.

```swift
public func depositToRebalancePool(
    poolAddress: String,
    amount: String,
    walletAddress: String,
    recipient: String? = nil
) async throws -> TransactionResponse
```

##### `withdrawFromRebalancePool(poolAddress:walletAddress:claimRewards:)`

Withdraw from rebalance pool.

```swift
public func withdrawFromRebalancePool(
    poolAddress: String,
    walletAddress: String,
    claimRewards: Bool = true
) async throws -> TransactionResponse
```

##### `unlockFromRebalancePool(poolAddress:amount:walletAddress:)`

Unlock from rebalance pool.

```swift
public func unlockFromRebalancePool(
    poolAddress: String,
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `claimRebalancePoolRewards(poolAddress:tokens:walletAddress:)`

Claim rewards from rebalance pool.

```swift
public func claimRebalancePoolRewards(
    poolAddress: String,
    tokens: [String],
    walletAddress: String
) async throws -> TransactionResponse
```

---

#### Savings & Stability Pool

##### `depositToSavings(amount:walletAddress:)`

Deposit to fxSAVE.

```swift
public func depositToSavings(
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `redeemFromSavings(amount:walletAddress:)`

Redeem from fxSAVE.

```swift
public func redeemFromSavings(
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `depositToStabilityPool(amount:walletAddress:)`

Deposit to stability pool.

```swift
public func depositToStabilityPool(
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `withdrawFromStabilityPool(amount:walletAddress:)`

Withdraw from stability pool.

```swift
public func withdrawFromStabilityPool(
    amount: String,
    walletAddress: String
) async throws -> TransactionResponse
```

---

#### V2 Operations

##### `operatePosition(positionId:poolAddress:newCollateral:newDebt:walletAddress:)`

Operate V2 position.

```swift
public func operatePosition(
    positionId: Int,
    poolAddress: String,
    newCollateral: String,
    newDebt: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `rebalancePosition(positionId:poolAddress:walletAddress:receiver:)`

Rebalance V2 position.

```swift
public func rebalancePosition(
    positionId: Int,
    poolAddress: String,
    walletAddress: String,
    receiver: String? = nil
) async throws -> TransactionResponse
```

##### `liquidatePosition(positionId:poolAddress:walletAddress:receiver:)`

Liquidate V2 position.

```swift
public func liquidatePosition(
    positionId: Int,
    poolAddress: String,
    walletAddress: String,
    receiver: String? = nil
) async throws -> TransactionResponse
```

---

#### Governance

##### `voteForGauge(gaugeAddress:weight:walletAddress:)`

Vote for gauge.

```swift
public func voteForGauge(
    gaugeAddress: String,
    weight: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `claimGaugeRewards(gaugeAddress:walletAddress:tokenAddress:)`

Claim gauge rewards.

```swift
public func claimGaugeRewards(
    gaugeAddress: String,
    walletAddress: String,
    tokenAddress: String? = nil
) async throws -> TransactionResponse
```

##### `lockFXN(amount:unlockTime:walletAddress:)`

Lock FXN to create veFXN.

```swift
public func lockFXN(
    amount: String,
    unlockTime: Int,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `claimVesting(tokenType:walletAddress:)`

Claim vesting tokens.

```swift
public func claimVesting(
    tokenType: String,
    walletAddress: String
) async throws -> TransactionResponse
```

---

#### Advanced Operations

##### `harvestPoolManager(poolAddress:walletAddress:)`

Harvest pool manager rewards.

```swift
public func harvestPoolManager(
    poolAddress: String,
    walletAddress: String
) async throws -> TransactionResponse
```

##### `requestBonus(tokenAddress:amount:walletAddress:recipient:)`

Request bonus from reserve pool.

```swift
public func requestBonus(
    tokenAddress: String,
    amount: String,
    walletAddress: String,
    recipient: String? = nil
) async throws -> TransactionResponse
```

##### `mintViaTreasury(baseIn:walletAddress:recipient:option:)`

Mint via treasury.

```swift
public func mintViaTreasury(
    baseIn: String,
    walletAddress: String,
    recipient: String? = nil,
    option: Int = 0
) async throws -> TransactionResponse
```

##### `mintViaGateway(amountEth:tokenType:walletAddress:minTokenOut:)`

Mint via gateway.

```swift
public func mintViaGateway(
    amountEth: String,
    tokenType: String,
    walletAddress: String,
    minTokenOut: String = "0"
) async throws -> TransactionResponse
```

##### `harvestTreasury(walletAddress:)`

Harvest treasury.

```swift
public func harvestTreasury(
    walletAddress: String
) async throws -> TransactionResponse
```

---

#### Transaction Status

##### `getTransactionStatus(txHash:)`

Get transaction status.

```swift
public func getTransactionStatus(txHash: String) async throws -> TransactionStatusResponse
```

**Parameters:**
- `txHash`: Transaction hash (0x format)

**Returns:** `TransactionStatusResponse` with status, block number, confirmations

**Example:**
```swift
let status = try await client.getTransactionStatus(txHash: "0x...")
print("Status: \(status.status)")
if let blockNumber = status.blockNumber {
    print("Block: \(blockNumber)")
}
```

---

## Data Models

### Response Models

#### `AllBalancesResponse`

Response for all token balances.

```swift
public struct AllBalancesResponse: Codable {
    public let address: String
    public let balances: [String: String]  // token_name -> balance
    public let totalUsdValue: String?
}
```

#### `BalanceResponse`

Response for single token balance.

```swift
public struct BalanceResponse: Codable {
    public let address: String
    public let token: String
    public let balance: String  // Decimal as string
    public let tokenAddress: String?
}
```

#### `ProtocolInfoResponse`

Protocol NAV response.

```swift
public struct ProtocolInfoResponse: Codable {
    public let baseNav: String
    public let fNav: String
    public let xNav: String
    public let source: String
    public let note: String?
}
```

#### `TransactionResponse`

Transaction response after broadcasting.

```swift
public struct TransactionResponse: Codable {
    public let success: Bool
    public let transactionHash: String
    public let status: String
    public let gasEstimate: Int?
    public let blockNumber: Int?
}
```

#### `TransactionStatusResponse`

Transaction status response.

```swift
public struct TransactionStatusResponse: Codable {
    public let transactionHash: String
    public let status: String
    public let blockNumber: Int?
    public let confirmations: Int?
}
```

### Error Models

#### `FXError`

Main error type for SDK operations.

```swift
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
}
```

---

## Error Handling

### Error Types

The SDK uses `FXError` enum for all errors:

```swift
do {
    let balance = try await client.getBalance(address: "0x...", token: "fxusd")
} catch let error as FXError {
    switch error {
    case .invalidAddress(let address):
        print("Invalid address: \(address)")
    case .networkError(let statusCode, let message):
        print("Network error (\(statusCode ?? 0)): \(message ?? "Unknown")")
    case .apiError(let code, let message):
        print("API error (\(code)): \(message)")
    case .walletNotFound:
        print("Wallet not found in Keychain")
    default:
        print("Error: \(error.localizedDescription)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

### Common Error Scenarios

#### Invalid Address

```swift
// Throws: FXError.invalidAddress
let balance = try await client.getBalance(
    address: "invalid",
    token: "fxusd"
)
```

#### Wallet Not Found

```swift
// Throws: FXError.walletNotFound
let tx = try await client.mintFToken(
    marketAddress: "0x...",
    baseIn: "1000000000000000000",
    walletAddress: "0x..."  // Not imported
)
```

#### Network Errors

```swift
// Throws: FXError.networkError
// Handles HTTP errors, timeouts, connection failures
```

#### API Errors

```swift
// Throws: FXError.apiError(code, message)
// Handles API-specific errors (rate limits, validation, etc.)
```

### Error Best Practices

1. **Always handle errors** - Use do-catch blocks
2. **Check error types** - Use pattern matching for specific errors
3. **Provide user feedback** - Show meaningful error messages
4. **Retry logic** - Implement retry for transient errors
5. **Log errors** - Log for debugging (without sensitive data)

---

## Caching

### Overview

The SDK includes built-in caching for read operations:
- **Memory Cache**: Fast, in-memory storage
- **Disk Cache**: Persistent storage (UserDefaults)
- **TTL Support**: Time-to-live for cache entries
- **Automatic Invalidation**: Cache cleared after write operations

### Cache Usage

#### Enable/Disable Caching

```swift
// Use cache (default)
let balance = try await client.getBalance(
    address: "0x...",
    token: "fxusd",
    useCache: true
)

// Bypass cache
let freshBalance = try await client.getBalance(
    address: "0x...",
    token: "fxusd",
    useCache: false
)
```

#### Cache Statistics

```swift
let stats = await client.cacheManager.getStats()
print("Cache hits: \(stats.memoryHits + stats.diskHits)")
print("Cache misses: \(stats.misses)")
print("Hit rate: \(stats.hitRate * 100)%")
```

#### Cache Management

```swift
// Invalidate specific pattern
await client.cacheManager.invalidate(pattern: "balance:*:0x...")

// Invalidate all cache
await client.cacheManager.clear()

// Remove specific entry
await client.cacheManager.remove("balance:token:0x...:fxusd")
```

### Cache TTL

Default TTL values:
- **Balance**: 60 seconds
- **Protocol Info**: 300 seconds (5 minutes)
- **Price**: 60 seconds
- **Pool Info**: 300 seconds

Cache is automatically invalidated after write operations.

---

## Security & Privacy

### Private Key Management

Private keys are stored securely in iOS Keychain:

- **Encryption**: Hardware-backed encryption (Secure Enclave)
- **Accessibility**: `.whenUnlockedThisDeviceOnly`
- **No Transmission**: Keys never leave the device
- **Client-Side Signing**: All signing happens locally

### Privacy

**The SDK collects zero user data:**

- ✅ No analytics
- ✅ No tracking
- ✅ No telemetry
- ✅ No data collection
- ✅ No third-party services

**Network Activity:**
- Only requests to configured API endpoint
- No external services called

**Local Storage:**
- Private keys in Keychain (encrypted)
- Cache data in memory/UserDefaults (local only)
- Cache statistics (local only, never transmitted)

See [PRIVACY.md](./PRIVACY.md) for detailed privacy information.

### Best Practices

1. **Never log private keys** - Avoid logging sensitive data
2. **Validate addresses** - Always validate before use
3. **Use HTTPS** - All API calls use HTTPS
4. **Secure storage** - Keys stored in Keychain only
5. **Error handling** - Don't expose sensitive info in errors

---

## Advanced Usage

### Custom API Configuration

```swift
// Custom API URL
let client = FXClient(
    baseURL: "https://custom-api.com/v1",
    apiKey: "your-api-key"
)
```

### Concurrent Operations

```swift
// Execute multiple operations concurrently
async let balance1 = client.getBalance(address: "0x1...", token: "fxusd")
async let balance2 = client.getBalance(address: "0x2...", token: "fxusd")
async let nav = client.getProtocolNAV()

let results = try await (balance1, balance2, nav)
```

### Transaction Monitoring

```swift
// Monitor transaction status
func monitorTransaction(txHash: String) async {
    var confirmed = false
    while !confirmed {
        do {
            let status = try await client.getTransactionStatus(txHash: txHash)
            print("Status: \(status.status)")
            
            if status.status == "confirmed" {
                confirmed = true
                if let blockNumber = status.blockNumber {
                    print("Confirmed in block: \(blockNumber)")
                }
            } else {
                // Wait before checking again
                try await Task.sleep(nanoseconds: 5_000_000_000)  // 5 seconds
            }
        } catch {
            print("Error checking status: \(error)")
            break
        }
    }
}
```

### Batch Operations

```swift
// Get multiple balances
func getMultipleBalances(addresses: [String]) async throws -> [String: BalanceResponse] {
    var results: [String: BalanceResponse] = [:]
    
    await withTaskGroup(of: (String, BalanceResponse?).self) { group in
        for address in addresses {
            group.addTask {
                do {
                    let balance = try await client.getBalance(address: address, token: "fxusd")
                    return (address, balance)
                } catch {
                    return (address, nil)
                }
            }
        }
        
        for await (address, balance) in group {
            if let balance = balance {
                results[address] = balance
            }
        }
    }
    
    return results
}
```

### Error Recovery

```swift
// Retry with exponential backoff
func retryOperation<T>(
    maxRetries: Int = 3,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    
    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            
            // Don't retry on certain errors
            if let fxError = error as? FXError {
                switch fxError {
                case .invalidAddress, .walletNotFound:
                    throw fxError  // Don't retry
                default:
                    break
                }
            }
            
            // Exponential backoff
            if attempt < maxRetries - 1 {
                let delay = pow(2.0, Double(attempt))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    
    throw lastError ?? FXError.networkError(nil, "Max retries exceeded")
}
```

---

## Best Practices

### 1. Address Validation

Always validate addresses before use:

```swift
func isValidAddress(_ address: String) -> Bool {
    return address.hasPrefix("0x") && address.count == 42
}

// Use before operations
guard isValidAddress(address) else {
    // Handle invalid address
    return
}
```

### 2. Error Handling

Always handle errors appropriately:

```swift
do {
    let result = try await client.someOperation()
    // Handle success
} catch let error as FXError {
    // Handle SDK errors
    switch error {
    case .walletNotFound:
        // Prompt user to import wallet
    case .networkError:
        // Show network error message
    default:
        // Show generic error
    }
} catch {
    // Handle unexpected errors
}
```

### 3. Amount Formatting

Use string format for amounts (wei):

```swift
// Convert ETH to wei
func ethToWei(_ eth: Decimal) -> String {
    let wei = eth * Decimal(1_000_000_000_000_000_000)
    return String(describing: wei)
}

// Use in transactions
let amount = ethToWei(1.0)  // "1000000000000000000"
```

### 4. Cache Management

Use cache appropriately:

```swift
// Use cache for frequently accessed data
let balance = try await client.getBalance(
    address: address,
    token: "fxusd",
    useCache: true
)

// Bypass cache for critical operations
let freshBalance = try await client.getBalance(
    address: address,
    token: "fxusd",
    useCache: false
)

// Invalidate cache after write operations
// (Automatically done by SDK)
```

### 5. Transaction Monitoring

Monitor transactions properly:

```swift
// Wait for confirmation
func waitForConfirmation(txHash: String) async throws {
    var attempts = 0
    let maxAttempts = 60  // 5 minutes
    
    while attempts < maxAttempts {
        let status = try await client.getTransactionStatus(txHash: txHash)
        
        if status.status == "confirmed" {
            return
        }
        
        if status.status == "failed" {
            throw FXError.transactionFailed("Transaction failed")
        }
        
        try await Task.sleep(nanoseconds: 5_000_000_000)  // 5 seconds
        attempts += 1
    }
    
    throw FXError.transactionFailed("Transaction timeout")
}
```

### 6. Wallet Management

Secure wallet handling:

```swift
// Import wallet securely
func importWalletSafely(privateKey: String, address: String) throws {
    // Validate before importing
    guard privateKey.hasPrefix("0x") && privateKey.count == 66 else {
        throw FXError.keychainError("Invalid private key format")
    }
    
    guard address.hasPrefix("0x") && address.count == 42 else {
        throw FXError.invalidAddress(address)
    }
    
    try client.importWallet(privateKey: privateKey, address: address)
}

// Never log private keys
// Never store private keys outside Keychain
// Always validate addresses
```

---

## Troubleshooting

### Common Issues

#### 1. "Wallet not found" Error

**Problem:** Trying to execute write operation without importing wallet.

**Solution:**
```swift
// Import wallet first
try client.importWallet(
    privateKey: "0x...",
    address: "0x..."
)
```

#### 2. Invalid Address Error

**Problem:** Address format is incorrect.

**Solution:**
```swift
// Ensure address is valid Ethereum address
// Format: 0x followed by 40 hex characters (42 total)
let address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
```

#### 3. Network Errors

**Problem:** API requests failing.

**Solutions:**
- Check internet connection
- Verify API URL is correct
- Check rate limits (100 req/min)
- Retry with exponential backoff

#### 4. Transaction Signing Errors

**Problem:** Transaction signing fails.

**Solutions:**
- Verify private key format (0x prefix, 66 chars)
- Ensure wallet is imported
- Check transaction data is valid

#### 5. Cache Issues

**Problem:** Stale data from cache.

**Solution:**
```swift
// Bypass cache
let fresh = try await client.getBalance(
    address: address,
    token: "fxusd",
    useCache: false
)

// Or clear cache
await client.cacheManager.clear()
```

### Debug Tips

1. **Enable verbose logging** (if available)
2. **Check cache statistics** - Verify cache is working
3. **Monitor network requests** - Use network debugging tools
4. **Validate inputs** - Ensure all parameters are correct
5. **Check error messages** - Read error descriptions carefully

---

## Examples

### Complete Example: Mint fxUSD

```swift
import FXProtocol

@MainActor
class FXProtocolManager {
    let client = FXClient()
    
    func mintFxUSD() async {
        let walletAddress = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
        let marketAddress = "0x..."  // Market contract address
        
        do {
            // 1. Import wallet (if not already imported)
            if !client.hasWallet(for: walletAddress) {
                // In production, get private key securely
                let privateKey = getPrivateKeySecurely()
                try client.importWallet(
                    privateKey: privateKey,
                    address: walletAddress
                )
            }
            
            // 2. Check current balance
            let balance = try await client.getFxusdBalance(address: walletAddress)
            print("Current fxUSD balance: \(balance.balance)")
            
            // 3. Mint fxUSD (1 ETH)
            let amount = "1000000000000000000"  // 1 ETH in wei
            let tx = try await client.mintFToken(
                marketAddress: marketAddress,
                baseIn: amount,
                walletAddress: walletAddress
            )
            
            print("Transaction submitted: \(tx.transactionHash)")
            
            // 4. Monitor transaction
            var confirmed = false
            while !confirmed {
                let status = try await client.getTransactionStatus(
                    txHash: tx.transactionHash
                )
                
                print("Status: \(status.status)")
                
                if status.status == "confirmed" {
                    confirmed = true
                    print("Transaction confirmed!")
                    
                    // 5. Check new balance
                    let newBalance = try await client.getFxusdBalance(
                        address: walletAddress
                    )
                    print("New fxUSD balance: \(newBalance.balance)")
                } else {
                    try await Task.sleep(nanoseconds: 5_000_000_000)  // 5 sec
                }
            }
            
        } catch let error as FXError {
            switch error {
            case .walletNotFound:
                print("Wallet not found. Please import wallet first.")
            case .networkError(let code, let message):
                print("Network error (\(code ?? 0)): \(message ?? "Unknown")")
            case .transactionFailed(let message):
                print("Transaction failed: \(message ?? "Unknown error")")
            default:
                print("Error: \(error.localizedDescription)")
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func getPrivateKeySecurely() -> String {
        // In production, get from secure storage
        // Never hardcode private keys!
        return "0x..."
    }
}
```

### Example: Query Protocol Info

```swift
func queryProtocolInfo() async {
    let client = FXClient()
    
    do {
        // Get protocol NAV
        let nav = try await client.getProtocolNAV()
        print("Base NAV: \(nav.baseNav)")
        print("f NAV: \(nav.fNav)")
        print("x NAV: \(nav.xNav)")
        
        // Get stETH price
        let stethPrice = try await client.getStethPrice()
        print("stETH price: \(stethPrice.balance)")
        
        // Get fxUSD supply
        let supply = try await client.getFxusdSupply()
        print("fxUSD supply: \(supply.balance)")
        
    } catch {
        print("Error: \(error)")
    }
}
```

### Example: Batch Balance Queries

```swift
func getMultipleBalances(addresses: [String]) async {
    let client = FXClient()
    
    await withTaskGroup(of: (String, Result<AllBalancesResponse, Error>).self) { group in
        for address in addresses {
            group.addTask {
                do {
                    let balances = try await client.getAllBalances(address: address)
                    return (address, .success(balances))
                } catch {
                    return (address, .failure(error))
                }
            }
        }
        
        for await (address, result) in group {
            switch result {
            case .success(let balances):
                print("\(address): \(balances.balances)")
            case .failure(let error):
                print("\(address): Error - \(error)")
            }
        }
    }
}
```

---

## Testing

### Running Tests

```bash
# Run all tests
cd swift
swift test

# Run specific test suite
swift test --filter IntegrationTests

# Run specific test
swift test --filter IntegrationTests.testHealthEndpoint

# Run with custom API URL
TEST_API_URL=http://localhost:8000/v1 swift test
```

### Test Coverage

The SDK includes 93+ tests covering:
- ✅ Core utilities
- ✅ API client
- ✅ Keychain manager
- ✅ Transaction signing
- ✅ Cache management
- ✅ Error handling
- ✅ Integration tests (live API)

See [TEST_COMMANDS.md](./TEST_COMMANDS.md) for detailed testing information.

---

## Additional Resources

- **README.md** - Quick start guide
- **PRIVACY.md** - Privacy policy
- **TEST_COMMANDS.md** - Testing guide
- **API Documentation** - https://fx-api-production.up.railway.app/docs

---

## Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Review the source code
- Check the API documentation

---

**Last Updated:** December 29, 2025  
**SDK Version:** 1.0.0  
**API Version:** v1

