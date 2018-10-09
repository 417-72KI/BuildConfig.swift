import Foundation
import Common
import PathKit
import SourceKittenFramework

public struct Generator {
    let data: Data

    public init(data: Data) {
        self.data = data
    }

}

public extension Generator {
    func run() throws -> String {
        print(data)
        return ""
    }
}

extension Generator {
   
}
