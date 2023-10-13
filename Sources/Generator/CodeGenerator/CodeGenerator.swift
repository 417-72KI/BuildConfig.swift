import Foundation
import SourceKittenFramework
import Stencil

struct CodeGenerator {
    let content: Struct
    let data: Data
}

extension CodeGenerator {
    func run() throws -> String {
        let header = try generateHeader()
        let root = try generateRoot()
        let loadExtension = try generateLoadExtension()
        let structs = try generateStruct(from: content)
        let rawData = try generateRawData(from: data)

        let array = structs.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? [header, root, loadExtension, rawData] : [header, root, loadExtension, structs, rawData]
        return array.joined(separator: "\n\n") + "\n"
    }
}

extension CodeGenerator {
    func generateHeader() throws -> String {
        try render(with: .header)
    }

    func generateRoot() throws -> String {
        try render(with: .root, dictionary: content.dictionary)
    }

    func generateLoadExtension() throws -> String {
        try render(with: .loadExtension)
    }

    func generateStruct(from content: Struct) throws -> String {
        let root = content.parent.isEmpty ? [] : [try render(with: .struct, dictionary: content.dictionary)]
        let children = try content.properties
            .mapValues { $0 as? Struct }
            .compactMap { $0.value }
            .sorted { $0.name < $1.name }
            .map { try generateStruct(from: $0) }
        return (root + children).joined(separator: "\n\n")
    }

    func generateRawData(from data: Data, asBinary: Bool = true) throws -> String {
        let rawDataString: String
        if asBinary {
            rawDataString = data.base64EncodedString()
        } else {
            let json = try JSONSerialization.jsonObject(with: data)
            let rawData = try JSONSerialization.data(
                withJSONObject: json,
                options: [.sortedKeys, .prettyPrinted]
            )
            rawDataString = String(data: rawData, encoding: .utf8) ?? ""
        }
        return try render(with: .rawData(asBinary: asBinary), dictionary: ["rawData": rawDataString])
    }

    func render(with template: Template, dictionary: [String: Any] = [:]) throws -> String {
        try Stencil.Template(
            templateString: template.code,
            environment: .init(trimBehaviour: .smart)
        )
        .render(dictionary)
    }
}
