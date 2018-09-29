// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigurationPlist",
    products: [
        .executable(name: "configurationPlist", targets: ["ConfigurationPlist"])
    ],
    dependencies: [
        .package(url: "https://github.com/behrang/YamlSwift.git", .upToNextMinor(from: "3.4.3")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMinor(from: "0.21.2")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.8.0")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.9.1")),
        // .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.6.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.3.1"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.2"),
        // .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "ConfigurationPlist",
            dependencies: [
                "Commander", "Core"
            ]),
        .target(
            name: "Core",
            dependencies: [
                "Common",
                "Parser",
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
        .testTarget(
            name: "ConfigurationPlistTests",
            dependencies: [
                "ConfigurationPlist",
                "Nimble",
                "Quick",
                // "MirrorDiffKit"
            ]),
        .testTarget(
            name: "ParserTests",
            dependencies: [
                "Parser",
                "Nimble",
                "Quick",
                // "MirrorDiffKit"
            ]),
    ]
)
