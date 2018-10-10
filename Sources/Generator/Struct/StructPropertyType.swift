import struct Foundation.URL

protocol StructPropertyType {
    var typeString: String { get }
}

extension String: StructPropertyType {
    var typeString: String { return "String" }
}

extension URL: StructPropertyType {
    var typeString: String { return "URL" }
}

extension Int: StructPropertyType {
    var typeString: String { return "Int" }
}

extension Double: StructPropertyType {
    var typeString: String { return "Double" }
}

extension Bool: StructPropertyType {
    var typeString: String { return "Bool" }
}

extension Array: StructPropertyType where Element == StructPropertyType {
    var typeString: String {
        guard let typeOfFirstItem = first.flatMap({ type(of: $0) }) else { return "[\(Element.self)]" }
        return "[\(typeOfFirstItem)]"
    }
}
