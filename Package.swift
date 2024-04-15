// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "BuildDSL",
    platforms: [
        .macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6),
        .macCatalyst(.v13), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "BuildDSL",
            targets: ["BuildDSL"]
        ),
        .executable(
            name: "BuildDSLClient",
            targets: ["BuildDSLClient"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "510.0.1"
        ),
        .package(url: "https://github.com/csjones/lefthook-plugin.git", from: "1.6.10")
    ],
    targets: [
        .macro(
            name: "BuildDSLMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "BuildDSL",
            dependencies: ["BuildDSLMacros"]
        ),
        .executableTarget(
            name: "BuildDSLClient",
            dependencies: ["BuildDSL"]
        ),
        .testTarget(
            name: "BuildDSLTests",
            dependencies: [
                "BuildDSL",
                "BuildDSLMacros",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                )
            ]
        )
    ]
)
