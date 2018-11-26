import struct Foundation.URL
import Common

struct Parser {
    let content: [AnyHashable: Any]
}

extension Parser {
    func run() -> Struct? {
        guard let element = extractProperties(content) as? Element else { return nil }
        return generateStruct(from: element, name: "AppConfig", parent: [])
    }
}

private extension Parser {
    func extractProperties(_ value: Any) -> ElementPropertyType? {
        switch value {
        case let boolValue as Bool:
            return boolValue
        case let intValue as Int:
            return intValue
        case let doubleValue as Double:
            return doubleValue
        case let urlValue as URL:
            return urlValue
        case let stringValue as String:
            return stringValue
        case let arrayValue as [Any]:
            return arrayValue.compactMap { extractProperties($0) }
        case let dictionaryValue as [String: Any]:
            let properties = dictionaryValue.compactMap { key, value -> (String, ElementPropertyType)? in
                guard let value = extractProperties(value) else { return nil }
                return (key, value)
            }
            return Element(properties: Dictionary(uniqueKeysWithValues: properties))
        default:
            return nil
        }
    }

    func generateStruct(from element: Element, name: String, parent: [String]) -> Struct {
        let properties = element.properties.map { key, value -> (String, StructPropertyType) in
            if let element = value as? Element {
                let parent = parent + [name]
                return (key, generateStruct(from: element, name: key.camelized(lower: false), parent: parent))
            }
            return (key, convertStruct(from: value))
        }
        return Struct(name: name, parent: parent, properties: Dictionary(uniqueKeysWithValues: properties))
    }
}
