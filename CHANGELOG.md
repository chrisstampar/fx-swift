# Changelog

All notable changes to the f(x) Protocol Swift SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-29

### Added
- Initial release of f(x) Protocol Swift SDK
- Complete read operations (balances, protocol info, pools, gauges, etc.)
- Full write operations (30+ transaction types)
- Client-side transaction signing using Web3.swift
- Secure private key storage in iOS Keychain
- Built-in caching layer (memory + disk)
- Comprehensive error handling with user-friendly messages
- Type-safe data models with Codable
- Async/await support throughout
- Complete documentation (1,668+ lines)
- Privacy policy (zero data collection)
- 114+ unit and integration tests

### Features

#### Read Operations
- Health and status endpoints
- Balance queries (all tokens, specific tokens, by address)
- Protocol information (NAV, token NAV, prices, supply)
- V1 protocol queries (pool info, market info, treasury info)
- V2 protocol queries (pool info, position info, pool manager, reserve pool)
- Convex operations (pools, vaults, balances, rewards)
- Curve operations (pools, gauges, balances, rewards)
- Gauge operations (weight, relative weight, rewards)
- veFXN information

#### Write Operations
- Token operations (mint f-token, mint x-token, mint both, approve, transfer, redeem)
- V1 operations (rebalance pool deposit/withdraw/unlock/claim, stability pool)
- V2 operations (operate position, rebalance position, liquidate position)
- Savings operations (deposit, redeem)
- Treasury operations (mint via treasury, mint via gateway, redeem via treasury)
- Governance (gauge vote, gauge claim, claim all gauge rewards)
- veFXN operations (deposit)
- Vesting (claim)
- Harvest operations (pool manager, treasury)
- Request bonus, swap, flash loan

#### Security & Privacy
- Private keys stored in iOS Keychain (encrypted, secure enclave)
- Client-side transaction signing (keys never leave device)
- Zero data collection (no analytics, tracking, or telemetry)
- HTTPS-only API communication

#### Developer Experience
- User-friendly error messages with actionable guidance
- Comprehensive documentation
- Type-safe API with Codable models
- Modern Swift concurrency (async/await)
- Built-in caching for performance
- Extensive test coverage

### Technical Details

#### Dependencies
- BigInt (5.0.0+) - Large number handling
- Web3.swift (0.5.0+) - Ethereum transaction signing
- KeychainAccess (4.0.0+) - iOS Keychain wrapper

#### Platform Support
- iOS 15.0+
- macOS 12.0+
- Swift 5.9+

#### API
- Production API: https://fx-api-production.up.railway.app/v1
- All operations tested against live API

### Documentation
- Complete API reference
- Usage examples
- Error handling guide
- Security and privacy documentation
- Testing guide
- Troubleshooting guide

### Known Limitations
- Some API endpoints return different JSON structures than expected models (stETH price, fxUSD supply) - handled gracefully
- Web3.swift package shows harmless warnings about unhandled files (does not affect functionality)
- Rate limiting: 100 requests/minute, 5000 requests/hour (handled gracefully)

### Security
- Private keys never transmitted
- All transactions signed locally
- Secure Keychain storage
- No data collection or tracking

---

## [Unreleased]

### Planned
- Example iOS app
- Performance benchmarks
- Additional convenience methods
- Enhanced error recovery

---

[1.0.0]: https://github.com/chrisstampar/fx-swift/releases/tag/v1.0.0

