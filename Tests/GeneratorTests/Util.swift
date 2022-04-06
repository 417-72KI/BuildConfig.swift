import PathKit
import Foundation
import XCTest

let resourcePath: Path = {
    let currentDirectoryPath = Path(FileManager.default.currentDirectoryPath)
    if currentDirectoryPath.string.contains("Xcode/DerivedData"),
        let oldPwd = ProcessInfo.processInfo.environment["OLDPWD"] {
        // Run via Xcode
        return Path(oldPwd) + "BuildConfig.swift/TestResources"
    } else {
        // Run via Terminal
        return Path(FileManager.default.currentDirectoryPath) + "TestResources"
    }
}()

var path: Path {
    return resourcePath + "GeneratorTests"
}

extension XCTestCase {
    func context(_ name: String, block: () throws -> Void) rethrows {
        if let _ = ProcessInfo().environment["XCTestConfigurationFilePath"] {
            // FIXME: Run test with `swift test`, it fails with message: `XCTContext.runActivity(named:block:) failed because activities are disallowed in the current configuration.`
            return try XCTContext.runActivity(named: name) { _ in try block() }
        } else {
            return try block()
        }
    }
}
