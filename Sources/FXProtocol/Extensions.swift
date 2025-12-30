// Extensions.swift
// Utility extensions for the SDK

import Foundation

// MARK: - Decimal Extensions

extension Decimal {
    /// Convert Decimal to String for API requests
    var apiString: String {
        return NSDecimalNumber(decimal: self).stringValue
    }
    
    /// Initialize Decimal from API string response
    init?(apiString: String) {
        if let value = Decimal(string: apiString, locale: Locale(identifier: "en_US_POSIX")) {
            self = value
        } else {
            return nil
        }
    }
}

// MARK: - String Extensions

extension String {
    /// Check if string is a valid Ethereum address format
    var isValidEthereumAddress: Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
    
    /// Convert to checksummed Ethereum address (EIP-55)
    var checksummedAddress: String {
        // Basic implementation - for production, use a proper EIP-55 library
        // This is a simplified version
        guard self.hasPrefix("0x"), self.count == 42 else {
            return self
        }
        
        let address = self.lowercased()
        let hash = address.data(using: .utf8)?.sha3Keccak256() ?? Data()
        
        var checksummed = "0x"
        for (index, char) in address.dropFirst(2).enumerated() {
            let hashByte = hash[index / 2]
            let hashNibble = (index % 2 == 0) ? (hashByte >> 4) : (hashByte & 0x0F)
            
            if hashNibble >= 8 {
                checksummed += String(char).uppercased()
            } else {
                checksummed += String(char)
            }
        }
        
        return checksummed
    }
}

// MARK: - Data Extensions

extension Data {
    /// SHA3-256 (Keccak-256) hash
    func sha3Keccak256() -> Data {
        // For production, use a proper crypto library like CryptoSwift
        // This is a placeholder - Web3.swift should provide this
        return self  // Placeholder
    }
}

