import Foundation
import Common
import PathKit
import SourceKittenFramework

public struct Generator {
    let data: Data

    public init(data: Data) {
        self.data = data
    }

}

public extension Generator {
    func run() throws -> String {
        guard let content = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [AnyHashable: Any] else { throw GeneratorError.invalidData }
        print(content)
        return ""
    }
}

extension Generator {
   
}
