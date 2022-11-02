import Common
import Foundation
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
        do {
            try validate()
        } catch let error as ValidationError {
            dumpError("Validation error:")
            error.errors
                .forEach { dumpError($0) }
            return
        }

        let data = try Parser(directoryPath: srcDirectoryPath)
            .run(environment: environment)

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
        if scriptInputFiles.contains(Constants.lastRunFileName) {
            dumpWarn("`$(TEMP_DIR)/\(Constants.lastRunFileName)` is no longer needed in Build phase Input Files. Remove it from `Input Files` and uncheck `Based on dependency analysis` instead.")
        }

        let scriptOutputFiles = self.scriptOutputFiles.map { $0.lastComponent }
        if !scriptOutputFiles.contains(Constants.generatedSwiftFileName) {
            errors.append("Build phase Output Files does not contain `path/to/\(Constants.generatedSwiftFileName)`")
        }

        guard errors.isEmpty else { throw ValidationError(errors: errors) }
    }
}

extension Core {
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
