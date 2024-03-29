import Common
import Foundation
import Generator
import Parser
import PathKit

public struct Core {
    let outputDirectory: Path
    let environment: String?
    let srcDirectoryPath: Path
    let scriptInputFiles: [Path]
    let scriptOutputFiles: [Path]

    public init(
        outputDirectory: Path,
        environment: String?,
        srcDirectoryPath: Path,
        scriptInputFiles: [Path],
        scriptOutputFiles: [Path]
    ) {
        self.outputDirectory = outputDirectory
        self.environment = environment
        self.srcDirectoryPath = srcDirectoryPath
        self.scriptInputFiles = scriptInputFiles
        self.scriptOutputFiles = scriptOutputFiles
    }

    public func execute() throws {
        do {
            try validate()
        } catch let error as ValidationError {
            dumpError("Validation error:")
            error.errors.forEach { dumpError($0) }
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

        let scriptInputFiles = scriptInputFiles.map(\.lastComponent)

        let lastRunFileName = "buildconfigswift-lastrun"
        if scriptInputFiles.contains(lastRunFileName) {
            errors.append("`$(TEMP_DIR)/\(lastRunFileName)` is now obsoleted. Remove it from `Input Files` and uncheck `Based on dependency analysis` instead.")
        }

        let scriptOutputFiles = scriptOutputFiles.map(\.lastComponent)
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
