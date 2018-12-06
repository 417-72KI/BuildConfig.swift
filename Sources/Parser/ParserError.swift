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
