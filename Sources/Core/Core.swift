import Foundation
import Common
import Generator
import Parser
import PathKit

public struct Core {
    let output: Path
    let outputGeneratedSwift: Path
    let environment: String?
    let srcDirectoryPath: Path

    public init(output: Path, outputGeneratedSwift: Path, environment: String?, srcDirectoryPath: Path) {
        self.output = output
        self.outputGeneratedSwift = outputGeneratedSwift
        self.environment = environment
        self.srcDirectoryPath = srcDirectoryPath
    }

    public func execute() throws {
        guard srcDirectoryPath.isDirectory else { throw CommonError.notDirectory(srcDirectoryPath) }
        let data = try Parser(directoryPath: srcDirectoryPath).run(environment: environment)
        let outputFile = output.isDirectory ? (output + Constants.defaultOutputFileName) : output
        try dumpData(data, to: outputFile)
    }
}

extension Core {
    func dumpData(_ data: Data, to dest: Path) throws {
        precondition(!dest.isDirectory, "\(dest) is directory.")
        try data.write(to: dest.url)
        print("create \(dest)")
    }
}
