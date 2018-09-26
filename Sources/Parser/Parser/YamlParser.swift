import Yams
import SourceKittenFramework

struct YamlParser: FileParser {
    func parse<T>(_ type: T.Type, file: File) throws -> T where T : Decodable {
        return try YAMLDecoder().decode(T.self, from: file.contents)
    }
}
