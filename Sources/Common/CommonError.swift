import PathKit

public enum CommonError: Error {
    case invalidPath(Path)
    case notDirectory(Path)
}

extension CommonError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidPath(let path):
            return "\(path) is invalid path."
        case .notDirectory(let path):
            return "\(path) is not directory."
        }
    }
}
