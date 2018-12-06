import struct Foundation.Data
import class Foundation.PropertyListSerialization
import Common
import PathKit

public struct Generator {
    let data: Data

    public init(data: Data) {
        self.data = data
    }
}

public extension Generator {
    func run() throws -> String {
        guard let content = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [AnyHashable: Any] else { throw GeneratorError.invalidData }
        guard let parsed = Parser(content: content).run() else { throw GeneratorError.parseFailed(content) }
        return try CodeGenerator(content: parsed).run()
    }
}
