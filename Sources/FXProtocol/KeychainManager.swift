// KeychainManager.swift
// Secure storage for private keys using iOS Keychain

import Foundation
import KeychainAccess

/// Manages secure storage of private keys in iOS Keychain
internal class KeychainManager {
    private let keychain: Keychain
    
    init() {
        // Use service identifier for f(x) Protocol
        self.keychain = Keychain(service: "com.fxprotocol.sdk")
            .accessibility(.whenUnlockedThisDeviceOnly)
    }
    
    /// Store a private key securely in Keychain
    /// - Parameters:
    ///   - privateKey: The private key to store
    ///   - address: The wallet address associated with this key
    func storePrivateKey(_ privateKey: String, for address: String) throws {
        // Validate private key format (should start with 0x and be 66 chars)
        guard privateKey.hasPrefix("0x") else {
            throw FXError.keychainError("Invalid private key format: Private key must start with '0x' prefix.")
        }
        guard privateKey.count == 66 else {
            throw FXError.keychainError("Invalid private key format: Private key must be 66 characters long (64 hex characters + '0x' prefix).")
        }
        
        let key = keyForAddress(address)
        do {
            try keychain.set(privateKey, key: key)
        } catch {
            // Provide user-friendly keychain error messages
            let errorMessage: String
            // Check for specific KeychainAccess error types
            let errorString = String(describing: error)
            if errorString.contains("duplicate") || errorString.contains("already exists") {
                errorMessage = "Wallet already exists. Use a different address or delete the existing wallet first."
            } else if errorString.contains("not found") || errorString.contains("itemNotFound") {
                errorMessage = "Wallet not found in secure storage."
            } else if errorString.contains("invalid") || errorString.contains("unexpected") {
                errorMessage = "Invalid data format. Please check your private key."
            } else {
                errorMessage = "Unable to save wallet to secure storage. Please check your device's security settings and try again."
            }
            throw FXError.keychainError("Failed to store private key: \(errorMessage)")
        }
    }
    
    /// Retrieve a private key from Keychain
    /// - Parameter address: The wallet address
    /// - Returns: The private key if found
    func getPrivateKey(for address: String) throws -> String? {
        let key = keyForAddress(address)
        do {
            return try keychain.get(key)
        } catch {
            // Provide user-friendly error messages
            let errorMessage: String
            let errorString = String(describing: error)
            if errorString.contains("not found") || errorString.contains("itemNotFound") {
                errorMessage = "Wallet not found. Please import the wallet first using importWallet(privateKey:address:)."
            } else {
                errorMessage = "Unable to access wallet from secure storage. Please check your device's security settings and ensure the wallet was previously imported."
            }
            throw FXError.keychainError("Failed to retrieve private key: \(errorMessage)")
        }
    }
    
    /// Delete a private key from Keychain
    /// - Parameter address: The wallet address
    func deletePrivateKey(for address: String) throws {
        let key = keyForAddress(address)
        do {
            try keychain.remove(key)
        } catch {
            // Provide user-friendly error messages
            let errorMessage: String
            let errorString = String(describing: error)
            if errorString.contains("not found") || errorString.contains("itemNotFound") {
                errorMessage = "Wallet not found. It may have already been deleted."
            } else {
                errorMessage = "Unable to remove wallet from secure storage. Please try again."
            }
            throw FXError.keychainError("Failed to delete private key: \(errorMessage)")
        }
    }
    
    /// Check if a private key exists for an address
    /// - Parameter address: The wallet address
    /// - Returns: True if key exists
    func hasPrivateKey(for address: String) -> Bool {
        let key = keyForAddress(address)
        return (try? keychain.get(key)) != nil
    }
    
    /// Generate a Keychain key for an address
    private func keyForAddress(_ address: String) -> String {
        return "private_key_\(address.lowercased())"
    }
}

