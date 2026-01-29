// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EPrint",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "EPrint",
            targets: ["EPrint"]),
    ],
    dependencies: [
        // No external dependencies - only uses Foundation
    ],
    targets: [
        .target(
            name: "EPrint",
            dependencies: []),
        .testTarget(
            name: "EPrintTests",
            dependencies: ["EPrint"]),
    ]
)

