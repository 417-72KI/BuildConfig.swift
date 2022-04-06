import PathKit
import Foundation
import XCTest

var path: Path {
    let resourcePath = Bundle.module
        .url(forResource: "Resources", withExtension: nil)!.path
    return Path(resourcePath)
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
