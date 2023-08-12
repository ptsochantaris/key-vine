// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "KeyVine",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "KeyVine",
            targets: ["KeyVine"]
        )
    ],
    targets: [
        .target(
            name: "KeyVine"),
        .testTarget(
            name: "KeyVineTests",
            dependencies: ["KeyVine"]
        )
    ]
)
