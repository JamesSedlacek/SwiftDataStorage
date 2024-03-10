// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDataStorage",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SwiftDataStorage",
            targets: ["SwiftDataStorage"]),
    ],
    targets: [
        .target(
            name: "SwiftDataStorage"),
        .testTarget(
            name: "SwiftDataStorageTests",
            dependencies: ["SwiftDataStorage"]),
    ]
)
