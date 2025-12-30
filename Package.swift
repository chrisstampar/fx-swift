// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fx-sdk-swift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FXProtocol",
            targets: ["FXProtocol"]
        ),
    ],
    // Package metadata
    // Repository: https://github.com/chrisstampar/fx-swift.git
    dependencies: [
        // BigInt for large number handling
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.0.0"),
        
        // Web3.swift for Ethereum operations and transaction signing
        // Note: argentlabs/web3.swift has dependency issues with secp256k1
        // Using Boilertalk/Web3.swift for now (has harmless warnings but works)
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.5.0"),
        
        // KeychainAccess for secure key storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "FXProtocol",
            dependencies: [
                "BigInt",
                .product(name: "Web3", package: "Web3.swift"),
                "KeychainAccess"
            ]
        ),
        .testTarget(
            name: "FXProtocolTests",
            dependencies: ["FXProtocol"]
        ),
    ]
)

