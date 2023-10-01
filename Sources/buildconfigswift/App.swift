import ArgumentParser
import Common
import Core
import Foundation
import PathKit

@main
struct App: ParsableCommand {
    @Option(name: .shortAndLong, help: "The directory to output BuildConfig.plist and BuildConfig.generated.swift.")
    var outputDirectory: String = "./"

    @Option(name: .shortAndLong, help: "Environment to merge environment file.")
    var environment: String?

    @Argument(help: "Directory which contains resource files.", completion: .directory)
    var srcDir: String
}

extension App {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "buildconfigswift",
            version: ApplicationInfo.version
        )
    }
}

extension App {
    func run() throws {
        let outputDirectory = Path(outputDirectory)
        let environment = environment.flatMap { $0.isEmpty ? nil : $0 }
            ?? ProcessInfo.processInfo.environment["CONFIGURATION"]
            .flatMap { $0.snakenized() }

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
