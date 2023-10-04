struct Struct {
    let name: String
    let parent: [String]
    let properties: [String: StructPropertyType]
}

extension Struct: StructPropertyType {
    var typeString: String { name }
}

extension Struct {
    var dictionary: [String: Any] {
        [
            "name": name,
            "parent": parent.joined(separator: "."),
            "properties": properties.map { ["name": $0.key.camelized(), "type": $0.value.typeString] }
                .sorted { $0["name"]! < $1["name"]! },
            "codingKeys": properties.map { ["key": $0.key.camelized(), "origin": $0.key] }
                .sorted { $0["key"]! < $1["key"]! },
        ]
    }
}
