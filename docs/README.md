# f(x) Protocol Swift SDK

**Version:** 1.0.0  
**Status:** Production Ready  
**Platform:** iOS (Swift 5.9+)  
**Target:** Swift Package Manager  
**API:** [https://fx-api-production.up.railway.app/v1](https://fx-api-production.up.railway.app/v1)

A native Swift SDK for interacting with the f(x) Protocol on iOS. This SDK leverages the f(x) Protocol REST API for backend operations while handling wallet management and transaction signing locally on the device.

## 🎯 Architecture

```
iOS App
  ↓
Swift SDK (HTTP Client + Crypto)
  ↓
REST API (FastAPI on Railway)
  ↓
Python SDK (fx-sdk)
  ↓
Ethereum Blockchain
```

## ✨ Features

- ✅ **Complete Read Operations** - Query balances, protocol info, Convex/Curve pools, gauges, and more
- ✅ **Full Write Operations** - 30+ transaction types (mint, redeem, stake, vote, etc.)
- ✅ **Client-Side Signing** - All transactions signed locally using Web3.swift
- ✅ **Secure Key Storage** - Private keys stored in iOS Keychain
- ✅ **Built-in Caching** - Memory and disk caching for read operations
- ✅ **Type-Safe** - Full Swift type safety with Codable models
- ✅ **Async/Await** - Modern Swift concurrency support
- ✅ **Comprehensive Tests** - 93+ unit and integration tests

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/chrisstampar/fx-swift.git", from: "1.0.0")
]
```

Or add via Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select version or branch

## 🚀 Quick Start

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
// Get all token balances for an address
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

// Get stETH price
let stethPrice = try await client.getStethPrice()

// Get fxUSD total supply
let supply = try await client.getFxusdSupply()
```

### Write Operations (Requires Wallet)

```swift
// Import wallet (stores private key securely in Keychain)
try client.importWallet(
    privateKey: "0x...",  // Your private key
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)

// Mint fxUSD
let tx = try await client.mintFToken(
    marketAddress: "0x...",
    baseIn: "1000000000000000000",  // 1 ETH in wei
    walletAddress: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
)

print("Transaction hash: \(tx.hash)")

// Track transaction status
let status = try await client.getTransactionStatus(txHash: tx.hash)
print("Status: \(status.status)")
```

### Available Write Operations

The SDK supports 30+ write operations:

**Token Operations:**
- `mintFToken()` - Mint f-token (e.g., fxUSD)
- `mintXToken()` - Mint x-token (e.g., xETH)
- `mintBothTokens()` - Mint both f and x tokens
- `approve()` - Approve token spending
- `transfer()` - Transfer tokens
- `redeem()` - Redeem tokens

**V2 Protocol:**
- `operatePosition()` - Operate V2 position
- `rebalancePosition()` - Rebalance V2 position
- `liquidatePosition()` - Liquidate V2 position

**Pool Operations:**
- `depositToRebalancePool()` - Deposit to rebalance pool
- `withdrawFromRebalancePool()` - Withdraw from rebalance pool
- `depositToStabilityPool()` - Deposit to stability pool
- `withdrawFromStabilityPool()` - Withdraw from stability pool

**Savings:**
- `depositToSavings()` - Deposit to fxSAVE
- `redeemFromSavings()` - Redeem from fxSAVE

**Governance:**
- `voteForGauge()` - Vote for gauge
- `claimGaugeRewards()` - Claim gauge rewards
- `lockFXN()` - Lock FXN to create veFXN

**Treasury:**
- `mintViaTreasury()` - Mint via treasury
- `mintViaGateway()` - Mint via gateway
- `redeemViaTreasury()` - Redeem via treasury

And more! See the full API in `FXProtocol.swift`.

## 🔐 Security & Privacy

- **Private Keys**: Stored securely in iOS Keychain (encrypted, secure enclave)
- **Client-Side Signing**: All transactions signed locally on device
- **No Key Transmission**: Private keys never leave the device
- **HTTPS Only**: All API calls over HTTPS
- **No Data Collection**: The SDK does not collect, track, or transmit any user data, analytics, or usage statistics
- **No Third-Party Services**: No analytics, tracking, or telemetry services are used
- **Local-Only Caching**: Cache statistics are stored locally and never transmitted

See [PRIVACY.md](./PRIVACY.md) for detailed privacy information.

## 💾 Caching

The SDK includes built-in caching for read operations:

```swift
// Use cache (default)
let balances = try await client.getAllBalances(
    address: "0x...",
    useCache: true
)

// Bypass cache
let freshBalances = try await client.getAllBalances(
    address: "0x...",
    useCache: false
)

// Access cache manager
let cacheStats = await client.cacheManager.getStats()
print("Cache hits: \(cacheStats.hits)")
print("Cache misses: \(cacheStats.misses)")

// Invalidate cache
await client.cacheManager.invalidate(pattern: "balance:*")
```

## 🧪 Testing

### Run All Tests

```bash
cd swift
swift test
```

### Run Integration Tests

Integration tests run against the production API:

```bash
swift test --filter IntegrationTests
```

### Use Custom API URL for Tests

Set the `TEST_API_URL` environment variable:

```bash
TEST_API_URL=http://localhost:8000/v1 swift test
```

## 📚 API Reference

### Read Operations

#### Health & Status
- `getHealth()` - Check API health
- `getStatus()` - Get API status

#### Balances
- `getAllBalances(address:)` - Get all token balances
- `getBalance(address:token:)` - Get specific token balance
- `getFxusdBalance(address:)` - Get fxUSD balance
- `getFxnBalance(address:)` - Get FXN balance
- `getFethBalance(address:)` - Get fETH balance
- `getXethBalance(address:)` - Get xETH balance
- `getVefxnBalance(address:)` - Get veFXN balance
- `getTokenBalance(address:tokenAddress:)` - Get ERC-20 token balance

#### Protocol Info
- `getProtocolNAV()` - Get protocol NAV
- `getTokenNAV(token:)` - Get token NAV
- `getStethPrice()` - Get stETH price
- `getFxusdSupply()` - Get fxUSD total supply
- `getPoolInfo(poolAddress:)` - Get pool information
- `getMarketInfo(marketAddress:)` - Get market information
- `getTreasuryInfo()` - Get treasury information

#### Convex
- `getAllConvexPools()` - Get all Convex pools
- `getConvexPoolInfo(poolAddress:)` - Get Convex pool info
- `getConvexVaultInfo(vaultAddress:)` - Get Convex vault info
- `getConvexVaultBalance(vaultAddress:address:)` - Get vault balance
- `getConvexVaultRewards(vaultAddress:address:)` - Get vault rewards
- `getUserConvexVaults(address:)` - Get user's Convex vaults

#### Curve
- `getAllCurvePools()` - Get all Curve pools
- `getCurvePoolInfo(poolAddress:)` - Get Curve pool info
- `getCurveGaugeBalance(gaugeAddress:address:)` - Get gauge balance
- `getCurveGaugeRewards(gaugeAddress:address:)` - Get gauge rewards

#### Gauges
- `getGaugeWeight(gaugeAddress:)` - Get gauge weight
- `getGaugeRelativeWeight(gaugeAddress:)` - Get relative weight
- `getGaugeRewards(gaugeAddress:address:)` - Get gauge rewards
- `getAllGaugeRewards(address:)` - Get all gauge rewards

#### veFXN
- `getVeFxnInfo(address:)` - Get veFXN information

### Write Operations

All write operations follow this pattern:
1. Import wallet (if not already imported)
2. Call the operation method
3. SDK handles: prepare → sign → broadcast
4. Returns transaction hash

See the "Available Write Operations" section above for the full list.

## 🏗️ Project Structure

```
swift/
├── Sources/
│   └── FXProtocol/           # Main SDK code
│       ├── FXProtocol.swift   # Main client
│       ├── APIClient.swift    # HTTP client
│       ├── TransactionSigner.swift  # Transaction signing
│       ├── KeychainManager.swift    # Secure storage
│       ├── CacheManager.swift        # Caching layer
│       ├── Models.swift              # Data models
│       └── Extensions.swift          # Utilities
├── Tests/
│   └── FXProtocolTests/       # Test suite
│       ├── IntegrationTests.swift   # Live API tests
│       └── ...                 # Unit tests
├── Package.swift              # Swift Package Manager config
└── README.md                  # This file
```

## 🔄 Status

- ✅ Phase 1: Core Infrastructure - Complete
- ✅ Phase 2: Read Operations - Complete
- ✅ Phase 3: Write Operations - Complete
- ✅ Phase 4: Advanced Features - Caching complete, wallet management complete
- ✅ Phase 5: Testing & Documentation - 93+ tests passing

## 📝 License

MIT

## 🔗 Links

- **📚 Complete Documentation**: [DOCUMENTATION.md](./DOCUMENTATION.md) - Exhaustive API reference, examples, and guides
- **🔒 Privacy Policy**: [PRIVACY.md](./PRIVACY.md) - Privacy and data collection information
- **🧪 Test Commands**: [TEST_COMMANDS.md](./TEST_COMMANDS.md) - Testing guide and commands
- **📋 Implementation Plan**: [SWIFT_IOS_PLAN.md](../SWIFT_IOS_PLAN.md) - Development plan and status
- **📝 Changelog**: [CHANGELOG.md](./CHANGELOG.md) - Version history and changes
- **✅ Publish Readiness**: [PUBLISH_READINESS.md](./PUBLISH_READINESS.md) - Pre-publish checklist and status
- **🌐 API Documentation**: [https://fx-api-production.up.railway.app/docs](https://fx-api-production.up.railway.app/docs)
- **💚 API Health**: [https://fx-api-production.up.railway.app/v1/health](https://fx-api-production.up.railway.app/v1/health)

## 🤝 Contributing

Contributions welcome! Please ensure all tests pass before submitting PRs.

## ⚠️ Important Notes

- **Private Keys**: Never commit private keys to version control
- **Testnet**: For testing, use testnet addresses and small amounts
- **Rate Limiting**: The API has rate limits (100 req/min, 5000 req/hour)
- **Caching**: Cache is automatically invalidated after write operations
