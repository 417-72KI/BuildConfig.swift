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
            let pipe = Pipe()
            let process = process(
                withArguments: ["--version"],
                pipe: pipe
            )
            XCTAssertNoThrow(try process.run())
            process.waitUntilExit()
            let version = try XCTUnwrap(String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .newlines))
            XCTAssertEqual(version, ApplicationInfo.version)
        }
        try context("run") {
            try context("with environment") {
                try context("staging") {
                    let pipe = Pipe()
                    let process = process(
                        withArguments: [
                            "-e",
                            "staging",
                            "-o",
                            tmpDirectory.path,
                            srcPath.absolute().string
                        ],
                        pipe: pipe
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(process.terminationStatus, 0)

                    let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.plist")
                    XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))
                    let createdData = try XCTUnwrap(try Data(contentsOf: createdFile))
                    let expectedData = try XCTUnwrap(try Data(contentsOf: expectedStagingFilePath.url))
                    let actual = try XCTUnwrap(try PropertyListSerialization.propertyList(from: createdData, options: [], format: nil) as? NSDictionary)
                    let expected = try XCTUnwrap(try PropertyListSerialization.propertyList(from: expectedData, options: [], format: nil) as? NSDictionary)
                    XCTAssertEqual(actual, expected)
                }
                try context("production") {
                    let pipe = Pipe()
                    let process = process(
                        withArguments: [
                            "-e",
                            "production",
                            "-o",
                            tmpDirectory.path,
                            srcPath.absolute().string
                        ],
                        pipe: pipe
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(process.terminationStatus, 0)

                    let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.plist")
                    XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))
                    let createdData = try XCTUnwrap(try Data(contentsOf: createdFile))
                    let expectedData = try XCTUnwrap(try Data(contentsOf: expectedProductionFilePath.url))
                    let actual = try XCTUnwrap(try PropertyListSerialization.propertyList(from: createdData, options: [], format: nil) as? NSDictionary)
                    let expected = try XCTUnwrap(try PropertyListSerialization.propertyList(from: expectedData, options: [], format: nil) as? NSDictionary)
                    XCTAssertEqual(actual, expected)
                }
            }
            try context("with invalid environments") {
                try context("SCRIPT_INPUT_FILE_COUNT") {
                    let pipe = Pipe()
                    let process = process(
                        withArguments: [
                            "-e",
                            "staging",
                            "-o",
                            tmpDirectory.path,
                            srcPath.absolute().string
                        ],
                        pipe: pipe
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                        $0.environment?["SCRIPT_INPUT_FILE_COUNT"] = "foo"
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(process.terminationStatus, 1)
                }
                try context("SCRIPT_OUTPUT_FILE_COUNT") {
                    let pipe = Pipe()
                    let process = process(
                        withArguments: [
                            "-e",
                            "staging",
                            "-o",
                            tmpDirectory.path,
                            srcPath.absolute().string
                        ],
                        pipe: pipe
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                        $0.environment?["SCRIPT_OUTPUT_FILE_COUNT"] = "bar"

                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(process.terminationStatus, 1)
                }
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

private extension BuildConfigswiftTests {
    func process(withArguments arguments: [String],
                 pipe: Pipe? = nil,
                 handler: ((Process) -> Void)? = nil) -> Process {
        let binary = productsDirectory.appendingPathComponent("buildconfigswift")
        print("binary: \(binary)")
        let process = Process()
        process.executableURL = binary
        process.arguments = arguments
        print("arguments: \(process.arguments ?? [])")
        handler?(process)
        print("environment: \(process.environment ?? [:])")
        if let pipe = pipe {
            process.standardOutput = pipe
        }
        return process
    }
}

