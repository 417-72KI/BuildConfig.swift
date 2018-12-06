import PathKit
import SourceKittenFramework

public extension File {
    convenience init?(path: Path) {
        self.init(path: path.string)
    }
}

public extension File {
    var isYaml: Bool {
        return ["yml", "yaml"].contains(pathExtension)
    }

    var isJson: Bool {
        return ["json"].contains(pathExtension)
    }

    var isExcludedFile: Bool {
        return ["xcfilelist"].contains(pathExtension)
    }
}

private extension File {
    var pathExtension: String? {
        return path?.bridge().pathExtension
    }
}
