import Foundation

protocol StructPropertyType {
    var typeString: String { get }
}

extension String: StructPropertyType {
    var typeString: String { "String" }
}

extension URL: StructPropertyType {
    var typeString: String { "URL" }
}

extension Decimal: StructPropertyType {
    var typeString: String { "Decimal" }
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
