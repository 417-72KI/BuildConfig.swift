// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildConfig.swift",
    platforms: [ .macOS(.v12) ],
    products: [
        .executable(name: "buildconfigswift", targets: ["BuildConfig.swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4"),
        .package(name: "Yaml", url: "https://github.com/behrang/YamlSwift.git", from: "3.4.4"),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .exact("0.32.0")),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.10.1"),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", from: "5.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "BuildConfig.swift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Core"
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                "Common",
                "Parser",
                "Generator"
            ]
        ),
        .target(
            name: "Common",
            dependencies: [
                "PathKit",
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
            ]
        ),
        .target(
            name: "Parser",
            dependencies: [
                "Common",
                "Yaml"
            ]
        ),
        .target(
            name: "Generator",
            dependencies: [
                "Common",
                "StencilSwiftKit"
            ]
        ),
        .testTarget(
            name: "BuildConfig.swiftTests",
            dependencies: [
                "BuildConfig.swift",
                // "MirrorDiffKit"
            ],
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "ParserTests",
            dependencies: [
                "Parser",
                "MirrorDiffKit"
            ],
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: [
                "Generator",
                "MirrorDiffKit"
            ],
            resources: [.copy("Resources")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
