// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isDevelop = true

let devDependencies: [Package.Dependency] = isDevelop ? [
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.53.0"),
] : []
let devPlugins: [Target.PluginUsage] = isDevelop ? [
    .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
] : []

let package = Package(
    name: "BuildConfig.swift",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "buildconfigswift",
            targets: ["buildconfigswift"]
        ),
        .plugin(
            name: "BuildConfigSwiftGenerate",
            targets: ["BuildConfigSwiftGenerate"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
        .package(url: "https://github.com/behrang/YamlSwift.git", from: "3.4.4"),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.35.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.10.1"),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", from: "5.0.1"),
    ] + devDependencies,
    targets: [
        .executableTarget(
            name: "buildconfigswift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Core"
            ],
            plugins: devPlugins
        ),
        .target(
            name: "Core",
            dependencies: [
                "Common",
                "Parser",
                "Generator"
            ],
            plugins: devPlugins
        ),
        .target(
            name: "Common",
            dependencies: [
                "PathKit",
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
            ],
            plugins: devPlugins
        ),
        .target(
            name: "Parser",
            dependencies: [
                "Common",
                .product(name: "Yaml", package: "YamlSwift"),
            ],
            plugins: devPlugins
        ),
        .target(
            name: "Generator",
            dependencies: [
                "Common",
                "StencilSwiftKit"
            ],
            plugins: devPlugins
        ),
        .testTarget(
            name: "buildconfigswiftTests",
            dependencies: [
                "buildconfigswift",
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
        ),
        .plugin(
            name: "BuildConfigSwiftGenerate",
            capability: .buildTool(),
            dependencies: ["buildconfigswift"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
