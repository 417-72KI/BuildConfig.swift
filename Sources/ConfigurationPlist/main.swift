import Commander
import Core
import Common
import PathKit

struct Options {
    static let outputGeneratedSwift = Option(
        "output-generated-swift",
        default: "./",
        flag: "s",
        description: "The directory to output generated Swift file."
    )
    static let output = Option(
        "output",
        default: "./",
        flag: "o",
        description: "The file/directory to output file, If directory is set, file name will be '\(Constants.defaultOutputFileName)'"
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
    Options.output,
    Options.outputGeneratedSwift,
    Options.environment,
    Arguments.srcDir
) {
    let output = Path($0)
    let outputGeneratedSwift = Path($1)
    let environment = $2.isEmpty ? nil : $2
    let srcDirPath = Path($3)
    try Core(output: output, outputGeneratedSwift: outputGeneratedSwift, environment: environment, srcDirectoryPath: srcDirPath).execute()
}

main.run(Version.current)
