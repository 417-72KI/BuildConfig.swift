import Foundation
import XCTest
import Common
import ArgumentParser

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
            XCTAssertEqual(ExitCode(process.terminationStatus), .success)
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
                    XCTAssertEqual(ExitCode(process.terminationStatus), .success)

                    let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.generated.swift")
                    XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))

                    try verifyGeneratedSwift(createdFile)
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
                    XCTAssertEqual(ExitCode(process.terminationStatus), .success)

                    let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.generated.swift")
                    XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))
                    try verifyGeneratedSwift(createdFile)
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
                    XCTAssertEqual(process.exitCode, .validationFailure)
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
                    XCTAssertEqual(process.exitCode, .validationFailure)
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

private extension BuildConfigswiftTests {
    func verifyGeneratedSwift(_ fileURL: URL) throws {
        let fileName = fileURL.lastPathComponent
        guard fileName.hasSuffix(".swift"),
              var content = String(data: try Data(contentsOf: fileURL), encoding: .utf8) else { throw SwiftError.invalidFile(fileURL.path) }
        content += [
            "print(BuildConfig.default.API.domain)",
            "print(BuildConfig.default.API.path.getList.method)",
            "print(BuildConfig.default.API.path.getList.path)",
            "print(BuildConfig.default.API.path.login.method)",
            "print(BuildConfig.default.API.path.login.path)",
            "print(BuildConfig.default.boolToken1)",
            "print(BuildConfig.default.boolToken2)",
            "print(BuildConfig.default.doubleToken)",
            "print(BuildConfig.default.fugaToken)",
            "print(BuildConfig.default.hogeToken)",
            "print(BuildConfig.default.numberToken)"
        ].reduce(into: "\n") { $0 += $1 + "\n" }

        let tmpSwiftFileURL = fileURL.deletingLastPathComponent()
            .appendingPathComponent("_\(fileName)")
        try content.write(to: tmpSwiftFileURL, atomically: true, encoding: .utf8)

        try executeSwiftFile(tmpSwiftFileURL)
    }

    enum SwiftError: Error {
        case invalidFile(String)
        case invalidExitCode(ExitCode)
    }

    @discardableResult
    func executeSwiftFile(_ fileURL: URL) throws -> [String] {
        let fileName = fileURL.lastPathComponent
        guard fileName.hasSuffix(".swift") else {
            throw SwiftError.invalidFile(fileURL.path)
        }
        let moduleName = String(
            fileName
                .split(separator: ".")
                .first
            ?? fileName.dropLast(6)
        )

        let process = Process()
        process.currentDirectoryURL = fileURL.deletingLastPathComponent()
        process.executableURL = {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", "xcrun --find swift"]
            let pipe = Pipe()
            process.standardOutput = pipe
            do {
                try process.run()
                process.waitUntilExit()
                let stdout = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let path = String(data: stdout, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                      path.hasSuffix("/swift") else { return nil }
                return URL(fileURLWithPath: path)
            } catch {
                print(error)
                return nil
            }
        }()
        process.arguments = [
            "-module-name",
            moduleName,
            fileURL.lastPathComponent
        ]

        if let executableURL = process.executableURL,
           let arguments = process.arguments {
            print(executableURL.path, arguments.joined(separator: " "))
        }
        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()
        guard case .success = process.exitCode else {
            throw SwiftError.invalidExitCode(process.exitCode)
        }
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .split(separator: "\n")
            .compactMap(String.init) ?? []
    }
}

