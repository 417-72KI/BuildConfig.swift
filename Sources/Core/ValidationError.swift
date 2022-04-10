import Common
import Foundation

struct ValidationError: Error {
    let errors: [String]
}

extension ValidationError: CustomStringConvertible {
    var description: String {
        "ValidationError: \n\(dumpedErrors)"
    }
}

private extension ValidationError {
    var dumpedErrors: String {
        errors.map { "\t\($0)" }
            .joined(separator: "\n")
    }
}
