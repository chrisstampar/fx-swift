# Privacy Policy - f(x) Protocol Swift SDK

**Last Updated:** December 29, 2025

## 🔒 No Data Collection

The f(x) Protocol Swift SDK is designed with privacy as a core principle. **We do not collect, track, or transmit any user data, analytics, or usage statistics.**

## What We Don't Do

✅ **No Analytics**: No analytics services (Firebase, Amplitude, Mixpanel, Segment, etc.)  
✅ **No Tracking**: No user behavior tracking or telemetry  
✅ **No Data Transmission**: No data sent to third-party services  
✅ **No Usage Statistics**: No collection of SDK usage patterns  
✅ **No Crash Reporting**: No automatic crash reporting or error tracking services  
✅ **No Device Information**: No collection of device IDs, IP addresses, or identifiers  

## What We Do

The SDK only:

1. **Makes API Requests**: Only to the f(x) Protocol API endpoint you configure
2. **Stores Data Locally**: 
   - Private keys in iOS Keychain (encrypted, secure enclave)
   - Cache data in local memory and disk (UserDefaults)
   - Cache statistics are local-only and never transmitted

## Network Activity

The SDK makes network requests **only** to:
- The f(x) Protocol API endpoint you specify (default: `https://fx-api-production.up.railway.app/v1`)

**No other network requests are made.**

## Dependencies

All dependencies are privacy-focused:

- **BigInt**: Pure math library, no network access
- **Web3.swift**: Blockchain library, no analytics
- **KeychainAccess**: iOS Keychain wrapper, no network access

## Local Storage

Data stored locally on the device:

- **Private Keys**: Stored in iOS Keychain (encrypted, secure enclave)
- **Cache Data**: Stored in memory and UserDefaults (local only)
- **Cache Statistics**: Local counters for cache performance (never transmitted)

## Your Privacy Rights

- **Full Control**: You control all API endpoints and can use your own
- **No Tracking**: No tracking cookies, beacons, or identifiers
- **No Data Sharing**: No data is shared with third parties
- **Open Source**: All code is open source and auditable

## Questions?

If you have questions about privacy, please review the source code or open an issue on GitHub.

---

**Summary**: The SDK is a pure client library that only communicates with the f(x) Protocol API you configure. No user data is collected, tracked, or transmitted.

