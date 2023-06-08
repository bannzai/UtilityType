// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UtilityType",
    products: [
        .library(
            name: "UtilityType",
            targets: ["UtilityType"]),
    ],
    targets: [
        .target(
            name: "UtilityType"),
        .testTarget(
            name: "UtilityTypeTests",
            dependencies: ["UtilityType"]),
    ]
)
