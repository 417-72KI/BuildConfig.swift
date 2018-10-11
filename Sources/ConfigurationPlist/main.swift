import Commander
import Core
import Common
import PathKit

struct Options {
    static let outputDirectory = Option(
        "output-directory",
        default: "./",
        flag: "o",
        description: "The directory to output Config.plist and AppConfig.generated.swift."
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

let main = command(
    Options.outputDirectory,
    Options.environment,
    Arguments.srcDir
) {
    let outputDirectory = Path($0)
    let environment = $1.isEmpty ? nil : $1
    let srcDirPath = Path($2)
    try Core(outputDirectory: outputDirectory, environment: environment, srcDirectoryPath: srcDirPath).execute()
}

main.run(Version.current)
