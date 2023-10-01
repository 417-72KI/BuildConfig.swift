public extension String {
    /// Convert to `camelCase`
    /// - Parameter lower: if `false`, convert to `UpperCamelCase`
    /// - Returns: `camelCased` string
    func camelized(lower: Bool = true) -> String {
        guard !isEmpty else { return self }
        guard contains("_") else { return lower ? self : self.capitalized }

        let words = lowercased().split(separator: "_").map { String($0) }
        let firstWord: String = words.first ?? ""

        let camel = lower ? firstWord : firstWord.capitalized
        return words.dropFirst().reduce(into: camel) { $0.append($1.capitalized) }
    }

    /// Convert to `snake_case`
    /// - Returns: `snake_cased` string
    func snakenized() -> String {
        guard !isEmpty else { return self }
        return components(separatedBy: .alphanumerics.inverted)
            .lazy
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
            .joined(separator: "_")
    }
}

extension String {
    var capitalized: String {
        "\(prefix(1).capitalized)\(suffix(from: index(after: startIndex)))"
    }
}
