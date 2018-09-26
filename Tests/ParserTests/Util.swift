import PathKit
import Foundation

let resourcePath: Path = {
    if let oldPwd = ProcessInfo.processInfo.environment["OLDPWD"] {
        // Run via Xcode
        return Path(oldPwd) + "ConfigurationPlist/TestResources"
    } else {
        // Run via Terminal
        return "./TestResources"
    }
}()

var path: Path {
    return resourcePath + "ParserTests"
}
