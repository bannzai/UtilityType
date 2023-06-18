// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "UtilityType",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "UtilityType",
            targets: ["UtilityType"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            branch: "main"
        )
    ],
    targets: [
        .macro(
            name: "UtilityTypePlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "UtilityType",
            dependencies: ["UtilityTypePlugin"]
        ),
        .testTarget(
            name: "UtilityTypePluginTests",
            dependencies: ["UtilityTypePlugin"]
        ),
        .executableTarget(
            name: "UtilityTypeExamples",
            dependencies: [
                "UtilityType"
            ]
        )
    ]
)
