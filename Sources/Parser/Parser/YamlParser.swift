import SourceKittenFramework
import Yams

struct YamlParser: FileParser {
    @available(*, deprecated, message: "Use: parse(file:)")
    func parse<T>(_ type: T.Type, file: File) throws -> T where T : Decodable {
        try YAMLDecoder().decode(T.self, from: file.contents)
    }

    func parse(file: File) throws -> AnyParsable {
        (try load(yaml: file.contents))
            .flatMap(AnyParsable.init) ?? .init()
    }
}
