public extension String {
    func camelized(lower: Bool = true) -> String {
        guard !isEmpty else { return self }
        guard contains("_") else { return lower ? self : self.capitalized }

        let words = lowercased().split(separator: "_").map { String($0) }
        let firstWord: String = words.first ?? ""

        let camel = lower ? firstWord : firstWord.capitalized
        return words.dropFirst().reduce(into: camel) { $0.append($1.capitalized) }
    }
}

extension String {
    var capitalized: String {
        return "\(prefix(1).capitalized)\(suffix(from: index(after: startIndex)))"
    }
}
