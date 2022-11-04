import PathKit
import Foundation
import XCTest

var path: Path {
    let resourcePath = Bundle.module
        .url(forResource: "Resources", withExtension: nil)!.path
    return Path(resourcePath)
}

var srcPath: Path {
    return path + "src"
}

var outputPath: Path {
    return path + "output"
}

var expectedFilePath: Path {
    return outputPath + "BuildConfig.plist"
}

var expectedStagingFilePath: Path {
    return outputPath + "staging" + "BuildConfig.plist"
}

var expectedProductionFilePath: Path {
    return outputPath + "production" + "BuildConfig.plist"
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

extension Pipe {
    var outputString: String {
        String(data: fileHandleForReading.readDataToEndOfFile(),
               encoding: .utf8) ?? ""
    }
}
