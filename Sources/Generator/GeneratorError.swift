enum GeneratorError: Error {
    case invalidData
    case parseFailed(Any)
}

extension GeneratorError: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidData:
            return "invalidData"
        case .parseFailed(let content):
            return "parseFailed: '\(content)'"
        }
    }
}
