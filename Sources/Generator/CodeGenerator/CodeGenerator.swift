import SourceKittenFramework
import StencilSwiftKit

struct CodeGenerator {
    let content: Struct
}

extension CodeGenerator {
    func run() throws -> String {
        let header = try generateHeader()
        let root = try generateRoot()
        let loadExtension = try generateLoadExtension()
        let structs = try generateStruct(from: content)
        return [header, root, loadExtension, structs].joined(separator: "\n\n") + "\n"
    }
}

extension CodeGenerator {
    func generateHeader() throws -> String {
        return try render(with: .header)
    }

    func generateRoot() throws -> String {
        return try render(with: .root, dictionary: content.dictionary)
    }

    func generateLoadExtension() throws -> String {
        return try render(with: .loadExtension)
    }

    func generateStruct(from content: Struct) throws -> String {
        let root = content.parent.isEmpty ? [] : [try render(with: .struct, dictionary: content.dictionary)]
        let children = try content.properties
            .mapValues { $0 as? Struct }
            .compactMap { $0.value }
            .map { try generateStruct(from: $0) }
        return (root + children).joined(separator: "\n\n")
    }

    func render(with template: Template, dictionary: [String: Any]? = nil) throws -> String {
        return try StencilSwiftTemplate(templateString: template.code).render(dictionary)
    }
}
