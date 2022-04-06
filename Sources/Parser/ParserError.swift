public enum ParserError: Error {
    case invalidFile(String)
}

extension ParserError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidFile(let path):
            return "invalidFile: '\(path)'"
        }
    }
}

extension ParserError: Equatable {
    public static func == (lhs: ParserError, rhs: ParserError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidFile(let lpath), .invalidFile(let rpath)):
            return lpath == rpath
        @unknown default:
            return false
        }
    }
}
