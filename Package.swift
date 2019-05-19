// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildConfig.swift",
    products: [
        .executable(name: "buildconfigswift", targets: ["BuildConfig.swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/behrang/YamlSwift.git", .upToNextMinor(from: "3.4.3")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMinor(from: "0.22.0")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.8.0")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.9.1")),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", .upToNextMinor(from: "2.7.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "8.0.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "2.1.0")),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", .upToNextMinor(from: "5.0.0")),
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
                "Nimble",
                "Quick",
                // "MirrorDiffKit"
            ]
        ),
        .testTarget(
            name: "ParserTests",
            dependencies: [
                "Parser",
                "Nimble",
                "Quick",
                // "MirrorDiffKit"
            ]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: [
                "Generator",
                "Nimble",
                "Quick",
                "MirrorDiffKit"
            ]
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
