import Foundation
import XCTest
import Common

final class BuildConfigswiftTests: XCTestCase {
    private static let tmpDirectory = productsDirectory.appendingPathComponent("tmp")

    override class func setUp() {
        try? FileManager.default.createDirectory(at: tmpDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    override class func tearDown() {
        try? FileManager.default.removeItem(at: tmpDirectory)
    }

    func testBinary() throws {
        let tmpDirectory = Self.tmpDirectory
        let fooBinary = productsDirectory.appendingPathComponent("buildconfigswift")
        print("binary: \(fooBinary)")
        try context("version") {
            let process = Process()
            process.executableURL = fooBinary
            process.arguments = ["--version"]
            let pipe = Pipe()
            process.standardOutput = pipe
            XCTAssertNoThrow(try process.run())
            process.waitUntilExit()
            let version = try XCTUnwrap(String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .newlines))
            XCTAssertEqual(version, ApplicationInfo.version)
        }
        try context("with environment") {
            try context("staging") {
                let process = Process()
                process.executableURL = fooBinary
                process.arguments = [
                    "-e",
                    "staging",
                    "-o",
                    tmpDirectory.path,
                    srcPath.absolute().string
                ]
                print(process.arguments ?? [])
                process.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                print(process.environment ?? [:])
                let pipe = Pipe()
                process.standardOutput = pipe
                XCTAssertNoThrow(try process.run())

                process.waitUntilExit()
                let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.plist")
                XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))

                let createdData = try XCTUnwrap(try Data(contentsOf: createdFile))
                let expectedData = try XCTUnwrap(try Data(contentsOf: expectedStagingFilePath.url))
                let actual = try XCTUnwrap(try PropertyListSerialization.propertyList(from: createdData, options: [], format: nil) as? NSDictionary)
                let expected = try XCTUnwrap(try PropertyListSerialization.propertyList(from: expectedData, options: [], format: nil) as? NSDictionary)
                XCTAssertEqual(actual, expected)
            }
            try context("production") {
                let process = Process()
                process.executableURL = fooBinary
                process.arguments = [
                    "-e",
                    "production",
                    "-o",
                    tmpDirectory.path,
                    srcPath.absolute().string
                ]
                print(process.arguments ?? [])
                process.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                print(process.environment ?? [:])
                let pipe = Pipe()
                process.standardOutput = pipe
                XCTAssertNoThrow(try process.run())

                process.waitUntilExit()
                let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.plist")
                XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))
                let createdData = try XCTUnwrap(try Data(contentsOf: createdFile))
                let expectedData = try XCTUnwrap(try Data(contentsOf: expectedProductionFilePath.url))
                let actual = try XCTUnwrap(try PropertyListSerialization.propertyList(from: createdData, options: [], format: nil) as? NSDictionary)
                let expected = try XCTUnwrap(try PropertyListSerialization.propertyList(from: expectedData, options: [], format: nil) as? NSDictionary)
                XCTAssertEqual(actual, expected)
            }
        }
    }
}

private extension BuildConfigswiftTests {
    /// Returns path to the built products directory.
    static var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL { Self.productsDirectory }
}
