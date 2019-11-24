import Common
import Foundation

struct ValidationError: Error {
    let errors: [String]
}

extension ValidationError: CustomStringConvertible {
    var description: String {
        "ValidationError: \n" +
        errors.map { "\t\($0)\n" }
            .reduce(into: "") { $0 += $1 }
    }
}
