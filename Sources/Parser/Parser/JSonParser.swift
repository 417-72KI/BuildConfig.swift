import Foundation
import SourceKittenFramework

struct JSonParser: FileParser {
    func parse<T>(_ type: T.Type, file: File) throws -> T where T: Decodable {
        let data = file.contents.data(using: .utf8)!
        return try JSONDecoder().decode(type, from: data)
    }
}
