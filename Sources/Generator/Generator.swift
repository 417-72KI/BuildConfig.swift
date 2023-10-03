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
        let decoder = JSONDecoder()
        guard let content = try? decoder.decode(AnyParsable.self, from: data) else {
            throw GeneratorError.invalidData
        }
        guard let parsed = Parser.parse(content) else { throw GeneratorError.parseFailed(content) }
        return try CodeGenerator(content: parsed, data: data).run()
    }
}
