import Foundation
import Common
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
    func run(environment: String?, skipInvalidFile: Bool = true) throws -> Any {
        let filePaths = try getFileList(at: directoryPath, environment: environment)
        let environmentFiles = filePaths.filter { $0.components.contains(envDirComponent) }.compactMap { File(path: $0) }
        let otherFiles = filePaths.filter { !$0.components.contains(envDirComponent) }.compactMap { File(path: $0) }
        let environmentData = try parse(files: environmentFiles, skipInvalidFile: skipInvalidFile)
            .reduce(AnyParsable(0)) { $0 + $1 }
        let defaultData = try parse(files: otherFiles, skipInvalidFile: skipInvalidFile)
            .reduce(AnyParsable(0)) { $0 + $1 }
        let result = defaultData + environmentData
        return result.rawValue
    }
}

extension Parser {
    func getFileList(at path: Path, environment: String? = nil) throws -> [Path] {
        if path.lastComponent == envDirComponent {
            if let environment = environment {
                return try path.children().filter { $0.lastComponentWithoutExtension == environment }
            }
            return []
        }
        return try path.children()
            .lazy
            .filter { $0.lastComponent != dsStoreFileName }
            .compactMap { $0.isDirectory ? try getFileList(at: $0, environment: environment) : [$0] }
            .flatMap { $0 }
    }

    func detectParser(_ file: File) throws -> FileParser {
        let ext = (file.path as NSString?)?.pathExtension
        switch ext {
        case "yml", "yaml":
            return YamlParser()
        case "json":
            return JSonParser()
        default:
            throw ParserError.invalidFile
        }
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
        return try files.compactMap {
            if let path = $0.path {
                print("process: \(path)")
            }
            do {
                let parser = try detectParser($0)
                return try parser.parse(file: $0)
            } catch {
                guard skipInvalidFile else { throw error }
                return nil
            }
        }
    }
}
