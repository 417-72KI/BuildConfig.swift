import struct Foundation.URL

protocol StructPropertyType {
    var typeString: String { get }
}

extension String: StructPropertyType {
    var typeString: String { "String" }
}

extension URL: StructPropertyType {
    var typeString: String { "URL" }
}

extension Int: StructPropertyType {
    var typeString: String { "Int" }
}

extension Double: StructPropertyType {
    var typeString: String { "Double" }
}

extension Bool: StructPropertyType {
    var typeString: String { "Bool" }
}

extension Array: StructPropertyType where Element == StructPropertyType {
    var typeString: String {
        guard let typeOfFirstItem = first.flatMap({ type(of: $0) }) else { return "[\(Element.self)]" }
        return "[\(typeOfFirstItem)]"
    }
}
