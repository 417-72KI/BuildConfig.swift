import SourceKittenFramework
import Yams

struct YamlParser: FileParser {
    func parse<T>(_ type: T.Type, file: File) throws -> T where T : Decodable {
        try YAMLDecoder().decode(T.self, from: file.contents)
    }
}
