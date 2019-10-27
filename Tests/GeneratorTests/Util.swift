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
    func context<Result>(_ name: String, block: () throws -> Result) rethrows -> Result {
        try XCTContext.runActivity(named: name) { _ in try block() }
    }
}
