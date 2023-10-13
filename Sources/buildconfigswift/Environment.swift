import ArgumentParser
import Foundation

public enum Environment {}

public extension Environment {
    static func getValue(forKey key: Key) throws -> String {
        guard let value = ProcessInfo().environment[key.rawValue] else {
            throw Error.notFound(key)
        }
        return value
    }
}

public extension Environment {
    static func getScriptInputFiles() throws -> [String] {
        let scriptInputFileCountString = (try? getValue(forKey: .scriptInputFileCount)) ?? "0"
        guard let scriptInputFileCount = Int(scriptInputFileCountString) else {
            throw ValidationError("\(Key.scriptInputFileCount.rawValue) must be Int. Invalid value `\(scriptInputFileCountString)`")
        }
        return try (0..<scriptInputFileCount)
            .map(Key.scriptInputFile)
            .map(getValue)
    }

    static func getScriptOutputFiles() throws -> [String] {
        let scriptOutputFileCountString = (try? getValue(forKey: .scriptOutputFileCount)) ?? "0"
        guard let scriptOutputFileCount = Int(scriptOutputFileCountString) else {
            throw ValidationError("\(Key.scriptOutputFileCount.rawValue) must be Int. Invalid value `\(scriptOutputFileCountString)`")
        }
        return try (0..<scriptOutputFileCount)
            .map(Key.scriptOutputFile)
            .map(getValue)
    }
}

public extension Environment {
    enum Key {
        case scriptInputFileCount
        case scriptOutputFileCount
        case scriptInputFile(Int)
        case scriptOutputFile(Int)

        public var rawValue: String {
            switch self {
            case .scriptInputFileCount: return "SCRIPT_INPUT_FILE_COUNT"
            case .scriptOutputFileCount: return "SCRIPT_OUTPUT_FILE_COUNT"
            case .scriptInputFile(let num): return "SCRIPT_INPUT_FILE_\(num)"
            case .scriptOutputFile(let num): return "SCRIPT_OUTPUT_FILE_\(num)"
            }
        }
    }
}

public extension Environment {
    enum Error: Swift.Error {
        case notFound(Key)
    }
}

extension Environment.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notFound(let key):
            return "Missing value for `\(key.rawValue)` in environment."
        }
    }
}
