// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tools",
    platforms: [.macOS(.v11)],
    products: [],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/XcodeGen", from: "2.28.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.47.0"),
    ],
    targets: []
)
