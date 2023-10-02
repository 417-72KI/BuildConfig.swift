import Common
import Foundation
import PathKit

public struct Generator {
    let data: Data

    public init(data: Data) {
        self.data = data
    }
}

public extension Generator {
    func run() throws -> String {
        guard let content = try? JSONSerialization.jsonObject(
            with: data,
            options: []
        ) as? [AnyHashable: Any] else { throw GeneratorError.invalidData }
        guard let parsed = Parser(content: content).run() else { throw GeneratorError.parseFailed(content) }
        return try CodeGenerator(content: parsed, data: data).run()
    }
}
