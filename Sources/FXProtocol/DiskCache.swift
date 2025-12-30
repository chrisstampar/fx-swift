// DiskCache.swift
// Disk-based cache storage using UserDefaults

import Foundation

/// Protocol for disk-based cache storage
public protocol DiskCacheProtocol {
    func get<T: Codable>(_ key: String, as type: T.Type) async throws -> T?
    func set<T: Codable>(_ value: T, for key: String) async throws
    func remove(_ key: String) async throws
    func clear() async throws
}

/// UserDefaults-based disk cache implementation
public final class UserDefaultsDiskCache: DiskCacheProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let prefix: String
    private let queue = DispatchQueue(label: "com.fxprotocol.diskcache", qos: .utility)
    
    public init(userDefaults: UserDefaults = .standard, prefix: String = "fx_sdk_cache") {
        self.userDefaults = userDefaults
        self.prefix = prefix
    }
    
    private func fullKey(_ key: String) -> String {
        return "\(prefix).\(key)"
    }
    
    public func get<T: Codable>(_ key: String, as type: T.Type) async throws -> T? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                guard let data = self.userDefaults.data(forKey: self.fullKey(key)) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let value = try JSONDecoder().decode(type, from: data)
                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func set<T: Codable>(_ value: T, for key: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let data = try JSONEncoder().encode(value)
                    self.userDefaults.set(data, forKey: self.fullKey(key))
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func remove(_ key: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                self.userDefaults.removeObject(forKey: self.fullKey(key))
                continuation.resume()
            }
        }
    }
    
    public func clear() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let keys = self.userDefaults.dictionaryRepresentation().keys
                for key in keys where key.hasPrefix(self.prefix) {
                    self.userDefaults.removeObject(forKey: key)
                }
                continuation.resume()
            }
        }
    }
}

