import Foundation
import PathKit

extension Path {
    var isDsStore: Bool {
        lastComponent == dsStoreFileName
    }

    var isValidFile: Bool {
        isFile && !isDsStore
    }
}
