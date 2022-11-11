import Foundation

public protocol Parsable: Decodable, Equatable {
    var value: Any { get }
}

@available(*, deprecated, message: "Will be replaced to Decimal")
extension Int: Parsable {
    public var value: Any { self }
}

extension Decimal: Parsable {
    var value: Any { self }
}

extension String: Parsable {
    public var value: Any { self }
}

extension URL: Parsable {
    public var value: Any { self }
}

@available(*, deprecated, message: "Will be replaced to Decimal")
extension Double: Parsable {
    public var value: Any { self }
}

extension Bool: Parsable {
    public var value: Any { self }
}

extension Array: Parsable where Element: Parsable {
    public var value: Any { self }
}

extension Dictionary: Parsable where Key: Parsable, Value: Parsable {
    public var value: Any { self }
}

public extension Parsable {
    var rawValue: Any {
        if let array = value as? [AnyParsable] {
            return array.map { $0.rawValue }
        }
        if let dic = value as? [AnyHashable: AnyParsable] {
            return dic.mapValues { $0.rawValue }
        }
        return value
    }
}

public struct AnyParsable: Parsable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init() {
        self.init([String: Self]())
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self),
           let intValue = try? container.decode(Int.self) {
            if Int(stringValue) == intValue {
                value = intValue
            } else {
                value = stringValue
            }
        } else if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let arrayValue = try? container.decode([Self].self) {
            value = arrayValue
        } else if let dictionaryValue = try? container.decode([String: Self].self) {
            value = dictionaryValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else {
            throw DecodingError.typeMismatch(
                Self.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported Parsable type")
            )
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lhs = lhs.value as? Int, let rhs = rhs.value as? Int {
            return lhs == rhs
        }
        if let lhs = lhs.value as? String, let rhs = rhs.value as? String {
            return lhs == rhs
        }
        if let lhs = lhs.value as? Bool, let rhs = rhs.value as? Bool {
            return lhs == rhs
        }
        if let lhs = lhs.value as? Double, let rhs = rhs.value as? Double {
            return lhs == rhs
        }
        if let lhs = lhs.value as? [Self], let rhs = rhs.value as? [Self] {
            return lhs == rhs
        }
        if let lhs = lhs.value as? [String: Self], let rhs = rhs.value as?  [String: Self] {
            return lhs == rhs
        }
        return false
    }
}

public extension AnyParsable {
    var isEmpty: Bool {
        if let value = value as? String {
            return value.isEmpty
        }
        if let value = value as? [AnyParsable] {
            return value.isEmpty
        }
        if let value = value as? [String: AnyParsable] {
            return value.isEmpty
        }
        return false
    }
}
