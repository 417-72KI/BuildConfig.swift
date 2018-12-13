import Common
import Foundation

struct ValidationError: Error {
    let errors: [String]
}

extension ValidationError: CustomStringConvertible {
    var description: String {
        return "ValidationError: \n" +
            errors.map { "\t\($0)\n" }.reduce("") { $0 + $1 }
    }
}
