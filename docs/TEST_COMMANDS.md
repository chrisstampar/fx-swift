# Swift SDK Test Commands

This document lists all available test commands you can run in the terminal for the f(x) Protocol Swift SDK.

## 📋 Available Test Suites

The SDK includes 11 test files:

1. **APIClientTests** - HTTP client and networking tests
2. **CacheTests** - Caching layer tests
3. **FXClientTests** - Main client interface tests
4. **FXProtocolTests** - Core protocol tests
5. **IntegrationTests** - Live API integration tests
6. **KeychainManagerTests** - Secure storage tests
7. **ModelsTests** - Data model tests
8. **RequestModelsTests** - Request encoding tests
9. **TransactionFlowTests** - Transaction flow tests
10. **TransactionSignerTests** - Transaction signing tests
11. **WriteOperationsIntegrationTests** - Write operation structure tests
12. **WriteOperationsTests** - Write operation validation tests

## 🚀 Basic Test Commands

### Run All Tests
```bash
cd swift
swift test
```

### Run Tests with Verbose Output
```bash
swift test --verbose
```

### Run Tests in Parallel (faster)
```bash
swift test --parallel
```

### Run Tests and Show Code Coverage
```bash
swift test --enable-code-coverage
```

## 🎯 Filter Tests by Test Suite

### Run Only Integration Tests (Live API)
```bash
swift test --filter IntegrationTests
```

### Run Only Unit Tests (No API calls)
```bash
swift test --filter APIClientTests
swift test --filter CacheTests
swift test --filter FXClientTests
swift test --filter KeychainManagerTests
swift test --filter ModelsTests
swift test --filter RequestModelsTests
swift test --filter TransactionSignerTests
```

### Run Transaction-Related Tests
```bash
swift test --filter TransactionFlowTests
swift test --filter TransactionSignerTests
swift test --filter WriteOperationsTests
swift test --filter WriteOperationsIntegrationTests
```

## 🔍 Filter Tests by Specific Test Case

### Run a Single Test
```bash
# Run specific test method
swift test --filter IntegrationTests.testHealthEndpoint
swift test --filter FXClientTests.testClientInitialization
swift test --filter TransactionSignerTests.testSignTransaction
```

### Run Multiple Specific Tests
```bash
# Run multiple tests (use pattern matching)
swift test --filter "IntegrationTests.testGet"
swift test --filter "FXClientTests.test"
```

## 🧪 Test Categories

### Read Operations Tests
```bash
# Test balance queries
swift test --filter "IntegrationTests.testGet.*Balance"

# Test protocol info
swift test --filter "IntegrationTests.testGetProtocol"
swift test --filter "IntegrationTests.testGetSteth"
swift test --filter "IntegrationTests.testGetFxusd"
```

### Write Operations Tests
```bash
# Test write operation structure
swift test --filter WriteOperationsIntegrationTests

# Test write operation validation
swift test --filter WriteOperationsTests
```

### Caching Tests
```bash
swift test --filter CacheTests
swift test --filter "IntegrationTests.testCaching"
```

### Error Handling Tests
```bash
swift test --filter "IntegrationTests.testNetworkError"
swift test --filter "FXClientTests.testError"
```

## 🔧 Advanced Options

### Use Custom API URL for Tests
```bash
# Test against local API
TEST_API_URL=http://localhost:8000/v1 swift test

# Test against staging API
TEST_API_URL=https://staging-api.example.com/v1 swift test
```

### Run Tests with Specific Build Configuration
```bash
# Debug build (default)
swift test

# Release build
swift test -c release
```

### List All Available Tests
```bash
swift test --list-tests
```

### Run Tests and Generate Coverage Report
```bash
swift test --enable-code-coverage
# Coverage data will be in .build/debug/codecov/
```

### Run Tests with Timeout
```bash
# Tests will timeout after 30 seconds (default is 60)
swift test --timeout 30
```

## 📊 Test Output Options

### Show Only Failures
```bash
swift test 2>&1 | grep -E "(failed|FAILED|error)"
```

### Show Test Summary
```bash
swift test 2>&1 | grep -E "(Test Suite|Executed|passed|failed)"
```

### Save Test Results to File
```bash
swift test > test_results.txt 2>&1
```

## 🎯 Common Test Scenarios

### Quick Smoke Test (Fast)
```bash
# Run just health check and basic initialization
swift test --filter "IntegrationTests.testHealthEndpoint"
swift test --filter "FXClientTests.testClientInitialization"
```

### Full Integration Test Suite
```bash
# Run all integration tests against production API
swift test --filter IntegrationTests
```

### Unit Tests Only (No Network)
```bash
# Run tests that don't require network
swift test --filter APIClientTests
swift test --filter CacheTests
swift test --filter KeychainManagerTests
swift test --filter ModelsTests
swift test --filter TransactionSignerTests
```

### Transaction Flow Tests
```bash
# Test complete transaction flow
swift test --filter TransactionFlowTests
```

### Write Operations Validation
```bash
# Test all write operations
swift test --filter WriteOperationsTests
swift test --filter WriteOperationsIntegrationTests
```

## ⚠️ Important Notes

1. **Rate Limiting**: Integration tests hit the production API. Running all tests may hit rate limits (429 errors). This is expected and tests handle it gracefully.

2. **Test Environment**: By default, tests use the production API. Set `TEST_API_URL` environment variable to use a different endpoint.

3. **Test Duration**: Full test suite takes ~60-90 seconds due to network calls.

4. **Parallel Execution**: Use `--parallel` for faster execution, but be aware of rate limits.

## 📝 Example Test Workflow

```bash
# 1. Quick smoke test
swift test --filter IntegrationTests.testHealthEndpoint

# 2. Run unit tests (fast, no network)
swift test --filter CacheTests
swift test --filter KeychainManagerTests

# 3. Run integration tests (slower, requires network)
swift test --filter IntegrationTests

# 4. Run full suite
swift test
```

## 🔗 Related Documentation

- [README.md](./README.md) - SDK documentation

