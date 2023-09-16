import Foundation

protocol ElementPropertyType {
}

struct Element: ElementPropertyType {
    let properties: [String: ElementPropertyType]
}

extension String: ElementPropertyType {
}

extension URL: ElementPropertyType {
}

extension Decimal: ElementPropertyType {
}

extension Int: ElementPropertyType {
}

extension Double: ElementPropertyType {
}

extension Bool: ElementPropertyType {
}

extension Array: ElementPropertyType where Element == ElementPropertyType {
}
