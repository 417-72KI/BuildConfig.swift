import Foundation
import Common
import Generator
import Parser
import PathKit

public struct Core {
    let outputDirectory: Path
    let environment: String?
    let srcDirectoryPath: Path
    let tempDirectoryPath: Path
    let scriptInputFiles: [Path]
    let scriptOutputFiles: [Path]

    public init(
        outputDirectory: Path,
        environment: String?,
        srcDirectoryPath: Path,
        tempDirectoryPath: Path,
        scriptInputFiles: [Path],
        scriptOutputFiles: [Path]
        ) {
        self.outputDirectory = outputDirectory
        self.environment = environment
        self.srcDirectoryPath = srcDirectoryPath
        self.tempDirectoryPath = tempDirectoryPath
        self.scriptInputFiles = scriptInputFiles
        self.scriptOutputFiles = scriptOutputFiles
    }

    public func execute() throws {
        defer { createLastRunFile() }

        try validate()

        let data = try Parser(directoryPath: srcDirectoryPath).run(environment: environment)
        let outputFile = outputDirectory + Constants.defaultOutputFileName
        try dumpData(data, to: outputFile)

        let generatedSwift = try Generator(data: data).run()
        let outputSwiftFile = outputDirectory + Constants.generatedSwiftFileName
        try dumpSwift(generatedSwift, to: outputSwiftFile)
    }
}

extension Core {
    func validate() throws {
        var errors: [String] = []
        if !srcDirectoryPath.isDirectory {
            errors.append(CommonError.notDirectory(srcDirectoryPath).description)
        }
        if !outputDirectory.isDirectory {
            errors.append(CommonError.notDirectory(outputDirectory).description)
        }

        let scriptInputFiles = self.scriptInputFiles.map { $0.lastComponent }
        if !scriptInputFiles.contains(Constants.lastRunFileName) {
            errors.append("Build phase Input Files does not contain `$(TEMP_DIR)/\(Constants.lastRunFileName)`")
        }

        let scriptOutputFiles = self.scriptOutputFiles.map { $0.lastComponent }
        if !scriptOutputFiles.contains(Constants.defaultOutputFileName) {
            errors.append("Build phase Output Files does not contain `path/to/\(Constants.defaultOutputFileName)`")
        }
        if !scriptOutputFiles.contains(Constants.generatedSwiftFileName) {
            errors.append("Build phase Output Files does not contain `path/to/\(Constants.generatedSwiftFileName)`")
        }

        guard errors.isEmpty else { throw ValidationError(errors: errors) }
    }
}

extension Core {
    func dumpData(_ data: Data, to dest: Path) throws {
        precondition(!dest.isDirectory, "\(dest) is directory.")
        try data.write(to: dest.url)
        dumpInfo("create \(dest)")
    }

    func dumpSwift(_ content: String, to dest: Path) throws {
        let currentContent = try? String(contentsOf: dest.url)
        if currentContent == content {
            dumpInfo("No change with \(dest).")
            return
        }
        try content.write(to: dest.url, atomically: true, encoding: .utf8)
        dumpInfo("create \(dest)")
    }
}

extension Core {
    func createLastRunFile() {
        do {
            let lastRunFile = tempDirectoryPath + Constants.lastRunFileName
            try "\(Date().timeIntervalSince1970)\n"
                .write(to: lastRunFile.url, atomically: true, encoding: .utf8)
        } catch {
            dumpWarn("Failed to write out to '\(Constants.lastRunFileName)', this might cause Xcode to not run the build phase for ConfigurationPlist: \(error)")
        }
    }
}
