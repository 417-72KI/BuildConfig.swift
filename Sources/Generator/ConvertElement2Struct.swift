import struct Foundation.URL

// swiftlint:disable force_cast
func convertStruct(from element: ElementPropertyType) -> StructPropertyType {
    precondition(!(element is Element))
    if let arrayValue = element as? [ElementPropertyType] {
        return arrayValue.map { $0 as! StructPropertyType }
    }
    return element as! StructPropertyType
}
// swiftlint:enable force_cast
