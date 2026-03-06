// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isDevelop = true

let package = Package(
    name: "BuildConfig.swift",
    platforms: [.macOS(.v14)],
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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
        .package(url: "https://github.com/behrang/YamlSwift.git", from: "3.4.4"),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.37.2"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.10.1"),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", from: "6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "buildconfigswift",
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
                .product(name: "Yaml", package: "YamlSwift"),
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

if isDevelop {
    package.dependencies += [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.0"),
    ]
    package.targets.filter { $0.type == .regular }.forEach { target in
        target.plugins = (target.plugins ?? []) + [
            .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint"),
        ]
    }
}
