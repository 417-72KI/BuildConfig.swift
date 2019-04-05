import Commander
import Core
import Common
import Foundation
import PathKit

struct Options {
    static let outputDirectory = Option(
        "output-directory",
        default: "./",
        flag: "o",
        description: "The directory to output BuildConfig.plist and BuildConfig.generated.swift."
    ) { output in
        return output
    }
    static let environment = Option(
        "environment",
        default: "",
        flag: "e",
        description: "Environment to merge environment file."
    )
}

struct Arguments {
    static let srcDir = Argument<String>(
        "srcDir",
        description: "Directory which contains resource files."
    )
}

struct Flags {
    static let version = Flag(
        "version",
        flag: "v",
        description: "Display current version."
    )
}

let main = command(
    Flags.version,
    Options.outputDirectory,
    Options.environment,
    Arguments.srcDir
) {
    let version = $0
    if version {
        print(ApplicationInfo.version)
        return
    }

    let outputDirectory = Path($1)
    let environment = $2.isEmpty ? nil : $2
    let srcDirPath = Path($3)

    let tempDirectoryPath = Path(try Environment.getValue(forKey: .tempDir))
    let scriptInputFiles = try Environment.getScriptInputFiles().map { Path($0) }
    let scriptOutputFiles = try Environment.getScriptOutputFiles().map { Path($0) }
    
    do {
        try Core(
            outputDirectory: outputDirectory,
            environment: environment,
            srcDirectoryPath: srcDirPath,
            tempDirectoryPath: tempDirectoryPath,
            scriptInputFiles: scriptInputFiles,
            scriptOutputFiles: scriptOutputFiles
            ).execute()
    } catch {
        dumpError(error)
        exit(1)
    }
}

main.run(ApplicationInfo.version)
