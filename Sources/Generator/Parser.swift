import struct Foundation.URL
import Common

enum Parser {}

extension Parser {
    static func parse(_ content: [AnyHashable: Any]) -> Struct? {
        guard let element = extractProperties(content) as? Element else { return nil }
        return generateStruct(from: element, name: "BuildConfig", parent: [])
    }
}

private extension Parser {
    static func extractProperties(_ value: Any) -> ElementPropertyType? {
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
                guard let extractedValue = extractProperties(value) else { return nil }
                // FIXME: when value is `0` or `1`, it may parsed as Bool unexpectedly.
                if extractedValue is Bool, !key.hasPrefix("is") {
                    // swiftlint:disable:next force_cast
                    return (key, value as! Int)
                }
                return (key, extractedValue)
            }
            return Element(properties: Dictionary(uniqueKeysWithValues: properties))
        default:
            return nil
        }
    }

    static func generateStruct(from element: Element, name: String, parent: [String]) -> Struct {
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
