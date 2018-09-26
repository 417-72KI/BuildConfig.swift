import SourceKittenFramework

protocol FileParser {
    func parse<T>(_ type: T.Type, file: File) throws -> T where T: Decodable
}

extension FileParser {
    func parse(file: File) throws -> AnyParsable {
        return try parse(AnyParsable.self, file: file)
    }
}
