import Common
import Foundation

public extension AnyParsable {
    static func + (lhs: AnyParsable, rhs: AnyParsable) -> AnyParsable {
        if let lhs = lhs.value as? [String: AnyParsable],
           let rhs = rhs.value as? [String: AnyParsable] {
            return AnyParsable(lhs + rhs)
        }
        if let lhs = lhs.value as? [AnyParsable],
           let rhs = rhs.value as? [AnyParsable] {
            return AnyParsable(lhs + rhs)
        }
        if let lhs = lhs.value as? Decimal,
           let rhs = rhs.value as? Decimal {
            return AnyParsable(lhs + rhs)
        }
        if let lhs = lhs.value as? String,
           let rhs = rhs.value as? String {
            return AnyParsable(lhs + rhs)
        }
        if lhs.isEmpty,
           rhs.isEmpty {
            return AnyParsable([String: AnyParsable]())
        }
        if rhs.isEmpty {
            return lhs
        }
        return rhs
    }
}

public extension Dictionary where Key == String, Value == AnyParsable {
    static func + (lhs: [String: AnyParsable], rhs: [String: AnyParsable]) -> [String: AnyParsable] {
        var result = lhs
        for (key, rValue) in rhs {
            if let lValue = lhs[key] {
                if let rDic = rValue.value as? [String: AnyParsable],
                   let lDic = lValue.value as? [String: AnyParsable] {
                    result[key] = AnyParsable(lDic + rDic)
                } else if let rArr = rValue.value as? [AnyParsable],
                          let lArr = lValue.value as? [AnyParsable] {
                    result[key] = AnyParsable(lArr + rArr)
                } else {
                    result[key] = rValue
                }
            } else {
                result[key] = rValue
            }
        }

        return result
    }
}
