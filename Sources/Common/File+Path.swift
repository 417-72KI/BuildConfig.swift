import PathKit
import SourceKittenFramework

public extension File {
    convenience init?(path: Path) {
        self.init(path: path.string)
    }
}
