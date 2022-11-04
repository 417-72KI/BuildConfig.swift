import Foundation
import XCTest
import Common
import ArgumentParser

private let needsDump = false

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
        dumpLog("binary: \(fooBinary)")
        try context("version") {
            let (stdout, stderr) = (Pipe(), Pipe())
            let process = process(
                withArguments: ["--version"],
                stdout: stdout,
                stderr: stderr
            )
            XCTAssertNoThrow(try process.run())
            process.waitUntilExit()
            XCTAssertEqual(ExitCode(process.terminationStatus), .success)
            XCTAssertEmpty(stderr.outputString)

            let version = stdout.outputString
                .trimmingCharacters(in: .newlines)
            XCTAssertEqual(version, ApplicationInfo.version)
        }
        try context("run") {
            try context("with environment") {
                try context("staging") {
                    let arguments = [
                        "-e",
                        "staging",
                        "-o",
                        tmpDirectory.path,
                        srcPath.absolute().string
                    ]
                    let (stdout, stderr) = (Pipe(), Pipe())
                    let process = process(
                        withArguments: arguments,
                        stdout: stdout,
                        stderr: stderr
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(ExitCode(process.terminationStatus), .success)
                    XCTAssertEmpty(stderr.outputString)

                    let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.generated.swift")
                    XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))

                    try verifyGeneratedSwift(createdFile)
                }
                try context("production") {
                    let arguments: [String] = [
                        "-e",
                        "production",
                        "-o",
                        tmpDirectory.path,
                        srcPath.absolute().string
                    ]
                    let (stdout, stderr) = (Pipe(), Pipe())
                    let process = process(
                        withArguments: arguments,
                        stdout: stdout,
                        stderr: stderr
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(ExitCode(process.terminationStatus), .success)
                    XCTAssertEmpty(stderr.outputString)

                    let createdFile = tmpDirectory.appendingPathComponent("BuildConfig.generated.swift")
                    XCTAssertTrue(FileManager.default.fileExists(atPath: createdFile.path))
                    try verifyGeneratedSwift(createdFile)
                }
            }
            try context("with invalid environments") {
                let arguments: [String] = [
                    "-e",
                    "staging",
                    "-o",
                    tmpDirectory.path,
                    srcPath.absolute().string
                ]
                try context("SCRIPT_INPUT_FILE_COUNT") {
                    let (stdout, stderr) = (Pipe(), Pipe())
                    let process = process(
                        withArguments: arguments,
                        stdout: stdout,
                        stderr: stderr
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                        $0.environment?["SCRIPT_INPUT_FILE_COUNT"] = "foo"
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(process.exitCode, .validationFailure)
                    XCTAssertEqual(stderr.outputString, """
                        Error: SCRIPT_INPUT_FILE_COUNT must be Int. Invalid value `foo`
                        Usage: build-config-swift [--output-directory <output-directory>] [--environment <environment>] <src-dir>
                          See 'build-config-swift --help' for more information.
                        """)
                }
                try context("SCRIPT_OUTPUT_FILE_COUNT") {
                    let (stdout, stderr) = (Pipe(), Pipe())
                    let process = process(
                        withArguments: arguments,
                        stdout: stdout,
                        stderr: stderr
                    ) {
                        $0.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                        $0.environment?["SCRIPT_OUTPUT_FILE_COUNT"] = "bar"
                    }
                    XCTAssertNoThrow(try process.run())
                    process.waitUntilExit()
                    XCTAssertEqual(process.exitCode, .validationFailure)
                    XCTAssertEqual(stderr.outputString, """
                        Error: SCRIPT_OUTPUT_FILE_COUNT must be Int. Invalid value `bar`
                        Usage: build-config-swift [--output-directory <output-directory>] [--environment <environment>] <src-dir>
                          See 'build-config-swift --help' for more information.
                        """)
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
                 stdout: Pipe? = nil,
                 stderr: Pipe? = nil,
                 handler: ((Process) -> Void)? = nil) -> Process {
        let binary = productsDirectory.appendingPathComponent("buildconfigswift")
        dumpLog("binary: \(binary)")
        let process = Process()
        process.executableURL = binary
        process.arguments = arguments
        dumpLog("arguments: \(process.arguments ?? [])")
        handler?(process)
        dumpLog("environment: \(process.environment ?? [:])")
        if let stdout = stdout {
            process.standardOutput = stdout
        }
        if let stderr = stderr {
            process.standardError = stderr
        }
        return process
    }
}

private extension BuildConfigswiftTests {
    func verifyGeneratedSwift(_ fileURL: URL) throws {
        // FIXME: `<unknown>:0: unable to load standard library for target 'x86_64-apple-macosx12.0'` occurs in GitHub Actions via xcodebuild.
        if let _ = ProcessInfo().environment["XCTestConfigurationFilePath"] {
            return
        }

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
        dumpLog(content)
        try executeSwiftFile(tmpSwiftFileURL)
    }

    enum SwiftError: Error {
        case invalidFile(String)
        case invalidExitCode(ExitCode, command: String, stdErr: String?)
    }

    @discardableResult
    func executeSwiftFile(_ fileURL: URL) throws -> [String] {
        dumpLog(fileURL)
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
                dumpLog(error)
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
            dumpLog(executableURL.path, arguments.joined(separator: " "))
        }
        let stdOutPipe = Pipe()
        let stdErrPipe = Pipe()
        process.standardOutput = stdOutPipe
        process.standardError = stdErrPipe

        try process.run()
        process.waitUntilExit()
        guard case .success = process.exitCode else {
            throw SwiftError.invalidExitCode(process.exitCode,
                                             command: "\(process.executableURL?.path ?? "") \((process.arguments ?? []).joined(separator: " "))",
                                             stdErr: String(data: stdErrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8))
        }
        return String(data: stdOutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .split(separator: "\n")
            .compactMap(String.init) ?? []
    }
}

private extension BuildConfigswiftTests {
    func dumpLog(_ items: Any..., file: StaticString = #file, line: UInt = #line) {
        if needsDump {
            print("[\(URL(fileURLWithPath: String(describing: file)).lastPathComponent):L\(line)]", (items as [Any]).map(String.init(describing:)).joined(separator: " "))
        }
    }
}
