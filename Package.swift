// swift-tools-version: 6.0

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
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "600.0.0-latest"
        ),
    ],
    targets: [
        .macro(
            name: "BuildDSLMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
        ),
        .target(
            name: "BuildDSL",
            dependencies: ["BuildDSLMacros"],
        ),
        .executableTarget(
            name: "BuildDSLClient",
            dependencies: ["BuildDSL"],
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
