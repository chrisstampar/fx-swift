// APIClientTests.swift
// Tests for APIClient HTTP operations

import XCTest
@testable import FXProtocol

final class APIClientTests: XCTestCase {
    var apiClient: APIClient!
    // Use production API for integration tests, or set TEST_API_URL env var for custom URL
    let testBaseURL = ProcessInfo.processInfo.environment["TEST_API_URL"] ?? "https://fx-api-production.up.railway.app/v1"
    
    override func setUp() {
        super.setUp()
        apiClient = APIClient(baseURL: testBaseURL)
    }
    
    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }
    
    // MARK: - URL Construction Tests
    
    func testBaseURLConstruction() {
        let client = APIClient(baseURL: "https://fx-api-production.up.railway.app/v1")
        // Verify client is initialized
        XCTAssertNotNil(client)
    }
    
    func testBaseURLWithTrailingSlash() {
        let client = APIClient(baseURL: "https://fx-api-production.up.railway.app/v1/")
        // Should handle trailing slash gracefully
        XCTAssertNotNil(client)
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidURL() async {
        let invalidClient = APIClient(baseURL: "not a valid url")
        // This should fail when making a request
        do {
            let _: HealthResponse = try await invalidClient.getHealth()
            XCTFail("Should have thrown an error")
        } catch {
            // Expected to fail
            XCTAssertTrue(error is FXError)
        }
    }
    
    // Note: Actual API tests would require a mock server or live API
    // These are structure tests for now
}

