import Common
import Foundation
import PathKit
import SourceKittenFramework

public struct Parser {
    let directoryPath: Path

    public init(directoryPath: Path) {
        precondition(directoryPath.isDirectory, "\(directoryPath) is not directory")
        self.directoryPath = directoryPath
    }
}

public extension Parser {
    func run(environment: String?, skipInvalidFile: Bool = true) throws -> Data {
        let files = try getFileList(at: directoryPath,
                                    environment: environment)
        if let environment, files.env.isEmpty {
            dumpWarn("No file for environment `\(environment)` in `\(directoryPath)`.")
        }
        let baseData = try parse(files: files.base,
                                 skipInvalidFile: skipInvalidFile)
            .reduce(AnyParsable()) { $0 + $1 }
        let environmentData = try parse(files: files.env,
                                        skipInvalidFile: skipInvalidFile)
            .reduce(AnyParsable()) { $0 + $1 }
        let result = baseData + environmentData
        return try JSONSerialization.data(
            withJSONObject: result.rawValue,
            options: []
        )
    }
}

extension Parser {
    func getFileList(at path: Path, environment: String? = nil) throws -> (base: [File], env: [File]) {
        let files = try path.children()
            .lazy
            .filter(\.isValidFile)
            .compactMap(File.init(path:))
            .filter(\.isYamlOrJson) as [File]
        guard let environment else { return (files, []) }
        let envFiles = (path + environment).lazy
            .compactMap(File.init(path:))
            .filter(\.isYamlOrJson) as [File]
        return (files, envFiles)
    }

    func detectParser(_ file: File) throws -> FileParser {
        if file.isYaml {
            return YamlParser()
        }
        if file.isJson {
            return JSonParser()
        }
        throw ParserError.invalidFile(file.path ?? "")
    }

    func comparePath(_ p1: Path, _ p2: Path) -> Bool {
        if p1.components.contains(envDirComponent), p2.components.contains(envDirComponent) {
            return p1 < p2
        }
        if p1.components.contains(envDirComponent) {
            return false
        }
        if p2.components.contains(envDirComponent) {
            return true
        }
        return p1 < p2
    }

    func parse(files: [File], skipInvalidFile: Bool) throws -> [AnyParsable] {
        try files.filter { !$0.isExcludedFile }
            .compactMap {
                if let path = $0.path {
                    dumpInfo("process: \(path)")
                }
                do {
                    let parser = try detectParser($0)
                    return try parser.parse(file: $0)
                } catch {
                    guard skipInvalidFile else { throw error }
                    dumpWarn("Skip file failed to parse: \($0.path ?? "")")
                    return nil
                }
            }
    }
}
