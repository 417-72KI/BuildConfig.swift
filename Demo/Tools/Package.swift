// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tools",
    platforms: [.macOS(.v12)],
    products: [],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/XcodeGen", from: "2.37.0"),
        // It's too heavy to build everytime😅
        // .package(url: "https://github.com/realm/SwiftLint", from: "0.53.0"),
    ],
    targets: []
)
