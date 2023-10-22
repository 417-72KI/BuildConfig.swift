// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "BuildConfigSwiftDemo",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "BuildConfigSwiftDemo",
            targets: ["BuildConfigSwiftDemo"]
        ),
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger", from: "7.0.1"),
        .package(url: "https://github.com/417-72KI/StubNetworkKit", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "BuildConfigSwiftDemo",
            dependencies: [
                "XCGLogger",
                "StubNetworkKit",
            ],
            plugins: [
                .plugin(name: "BuildConfigSwiftGenerate", package: "BuildConfig.swift"),
            ]
        ),
        .testTarget(
            name: "BuildConfigSwiftDemoTests",
            dependencies: ["BuildConfigSwiftDemo"],
            resources: [.copy("test_config.json")]
        ),
    ]
)
