import ArgumentParser
import Common
import Core
import Foundation
import PathKit

@main
struct BuildConfigSwift: ParsableCommand {
    @Option(name: .shortAndLong, help: "The directory to output BuildConfig.plist and BuildConfig.generated.swift.")
    var outputDirectory: String = "./"

    @Option(name: .shortAndLong, help: "Environment to merge environment file.")
    var environment: String?

    @Argument(help: "Directory which contains resource files.", completion: .directory)
    var srcDir: String
}

extension BuildConfigSwift {
    static var configuration: CommandConfiguration {
        CommandConfiguration(version: ApplicationInfo.version)
    }
}

extension BuildConfigSwift {
    func run() throws {
        let outputDirectory = Path(outputDirectory)
        let environment = environment.flatMap { $0.isEmpty ? nil : $0 }
        let srcDirPath = Path(srcDir)

        let tempDirectoryPath = Path(try Environment.getValue(forKey: .tempDir))
        let scriptInputFiles = try Environment.getScriptInputFiles().map { Path($0) }
        let scriptOutputFiles = try Environment.getScriptOutputFiles().map { Path($0) }
        try Core(
            outputDirectory: outputDirectory,
            environment: environment,
            srcDirectoryPath: srcDirPath,
            tempDirectoryPath: tempDirectoryPath,
            scriptInputFiles: scriptInputFiles,
            scriptOutputFiles: scriptOutputFiles
        ).execute()
    }
}