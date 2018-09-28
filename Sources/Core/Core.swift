import Foundation
import Common
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
        let plist = try PropertyListSerialization.data(fromPropertyList: data, format: .xml, options: 0)
        try plist.write(to: output.url)
        print("create \(output)")
    }
}
