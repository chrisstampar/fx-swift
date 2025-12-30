// TransactionSigner.swift
// Client-side transaction signing using Boilertalk/Web3.swift
// API verified via MCP Context7 and source code inspection

import Foundation
import Web3
import BigInt

/// Handles client-side transaction signing
internal class TransactionSigner {
    
    /// Sign an unsigned transaction using a private key
    /// - Parameters:
    ///   - transaction: The unsigned transaction from the API
    ///   - privateKey: The private key to sign with (hex string with 0x prefix)
    /// - Returns: Raw signed transaction as hex string (ready for broadcasting)
    func signTransaction(
        _ transaction: TransactionDataResponse,
        privateKey: String
    ) throws -> String {
        do {
            // Parse private key
            guard privateKey.hasPrefix("0x") else {
                throw FXError.signingError("Private key must start with '0x' prefix. Please check your private key format.")
            }
            
            let privateKeyHex = String(privateKey.dropFirst(2))
            guard privateKeyHex.count == 64 else {
                throw FXError.signingError("Invalid private key length. Private key must be 66 characters (64 hex characters + '0x' prefix).")
            }
            
            // Create EthereumPrivateKey from hex string
            let ethereumPrivateKey = try EthereumPrivateKey(hexPrivateKey: privateKey)
            
            // Parse transaction values
            guard let toAddress = try? EthereumAddress(hex: transaction.to, eip55: false) else {
                throw FXError.signingError("Invalid recipient address in transaction: '\(transaction.to)'. Please check the transaction data.")
            }
            
            // Parse value, nonce, gasLimit, chainId as BigUInt then convert to EthereumQuantity
            guard let valueBigUInt = BigUInt(transaction.value, radix: 16) else {
                throw FXError.signingError("Invalid transaction amount: '\(transaction.value)'. Please check the transaction data.")
            }
            let value = EthereumQuantity(quantity: valueBigUInt)
            
            // Parse nonce, gasLimit, chainId as BigUInt
            // BigUInt(string:) is non-optional, throws on invalid format
            let nonce = EthereumQuantity(quantity: BigUInt(transaction.nonce))
            let gasLimit = EthereumQuantity(quantity: BigUInt(transaction.gas))
            let chainId = EthereumQuantity(quantity: BigUInt(transaction.chainId))
            
            // Parse data using ethereumValue initializer
            let data = try EthereumData(ethereumValue: .string(transaction.data))
            
            // Parse gas price (EIP-1559 or legacy)
            let gasPrice: EthereumQuantity?
            let maxFeePerGas: EthereumQuantity?
            let maxPriorityFeePerGas: EthereumQuantity?
            let transactionType: EthereumTransaction.TransactionType
            
            if let maxFee = transaction.maxFeePerGas, let maxPriority = transaction.maxPriorityFeePerGas {
                // EIP-1559 transaction
                guard let maxFeeBigUInt = BigUInt(maxFee, radix: 16) else {
                    throw FXError.signingError("Invalid gas fee in transaction. This may be a temporary API issue. Please try again.")
                }
                guard let maxPriorityBigUInt = BigUInt(maxPriority, radix: 16) else {
                    throw FXError.signingError("Invalid priority gas fee in transaction. This may be a temporary API issue. Please try again.")
                }
                maxFeePerGas = EthereumQuantity(quantity: maxFeeBigUInt)
                maxPriorityFeePerGas = EthereumQuantity(quantity: maxPriorityBigUInt)
                gasPrice = nil
                transactionType = .eip1559
            } else if let gasPriceStr = transaction.gasPrice {
                // Legacy transaction
                guard let gasPriceBigUInt = BigUInt(gasPriceStr, radix: 16) else {
                    throw FXError.signingError("Invalid gas price in transaction. This may be a temporary API issue. Please try again.")
                }
                gasPrice = EthereumQuantity(quantity: gasPriceBigUInt)
                maxFeePerGas = nil
                maxPriorityFeePerGas = nil
                transactionType = .legacy
            } else {
                throw FXError.signingError("Transaction missing gas price information. This may be a temporary API issue. Please try again.")
            }
            
            // Create EthereumTransaction
            let tx: EthereumTransaction
            if transactionType == .eip1559, let maxFee = maxFeePerGas, let maxPriority = maxPriorityFeePerGas {
                // EIP-1559 transaction
                tx = EthereumTransaction(
                    nonce: nonce,
                    gasPrice: nil, // EIP-1559 doesn't use gasPrice
                    maxFeePerGas: maxFee,
                    maxPriorityFeePerGas: maxPriority,
                    gasLimit: gasLimit,
                    to: toAddress,
                    value: value,
                    data: data,
                    transactionType: .eip1559
                )
            } else if let gasPrice = gasPrice {
                // Legacy transaction
                tx = EthereumTransaction(
                    nonce: nonce,
                    gasPrice: gasPrice,
                    gasLimit: gasLimit,
                    to: toAddress,
                    value: value,
                    data: data,
                    transactionType: .legacy
                )
            } else {
                throw FXError.signingError("Unable to prepare transaction for signing. Please check the transaction data and try again.")
            }
            
            // Sign transaction using Web3.swift API
            let signedTx = try tx.sign(with: ethereumPrivateKey, chainId: chainId)
            
            // Get raw transaction (RLP encoded)
            let rawTransaction = try signedTx.rawTransaction()
            
            // Convert to hex string with 0x prefix
            // EthereumData has a public hex() method that returns hex string with prefix
            return rawTransaction.hex()
            
        } catch let error as FXError {
            throw error
        } catch {
            // Provide user-friendly signing error messages
            let errorMessage: String
            let errorDesc = error.localizedDescription.lowercased()
            if errorDesc.contains("private key") || errorDesc.contains("key") {
                errorMessage = "Invalid private key. Please ensure your wallet is properly imported and try again."
            } else if errorDesc.contains("address") {
                errorMessage = "Invalid address in transaction. Please check the transaction data and try again."
            } else if errorDesc.contains("gas") {
                errorMessage = "Invalid gas parameters in transaction. This may be a temporary API issue. Please try again."
            } else {
                errorMessage = "Transaction signing failed. Please ensure your wallet is properly imported and try again."
            }
            throw FXError.signingError("Transaction signing failed: \(errorMessage)")
        }
    }
}
