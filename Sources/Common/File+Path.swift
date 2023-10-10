import PathKit
import SourceKittenFramework

public extension File {
    convenience init?(path: Path) {
        self.init(path: path.string)
    }
}

public extension File {
    var isYaml: Bool {
        ["yml", "yaml"].contains(pathExtension)
    }

    var isJson: Bool {
        ["json"].contains(pathExtension)
    }

    var isYamlOrJson: Bool {
        isYaml || isJson
    }

    var isExcludedFile: Bool {
        ["xcfilelist"].contains(pathExtension)
    }
}

private extension File {
    var pathExtension: String? {
        path?.bridge().pathExtension
    }
}
