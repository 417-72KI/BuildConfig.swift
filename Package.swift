// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildConfig.swift",
    platforms: [ .macOS(.v10_14) ],
    products: [
        .executable(name: "buildconfigswift", targets: ["BuildConfig.swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/behrang/YamlSwift.git", .upToNextMajor(from: "3.4.0")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMajor(from: "0.26.0")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMajor(from: "0.9.0")),
        // Waiting for updates appling PathKit:1.0.0
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", .upToNextMajor(from: "2.7.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "BuildConfig.swift",
            dependencies: [
                "Commander", "Core"
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
                "SourceKittenFramework"
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
            ]
        ),
        .testTarget(
            name: "ParserTests",
            dependencies: [
                "Parser",
                // "MirrorDiffKit"
            ]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: [
                "Generator",
                "MirrorDiffKit"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
