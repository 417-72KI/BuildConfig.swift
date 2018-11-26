import PathKit
import Foundation

let resourcePath: Path = {
    let currentDirectoryPath = Path(FileManager.default.currentDirectoryPath)
    if currentDirectoryPath.string.contains("Xcode/DerivedData"),
        let oldPwd = ProcessInfo.processInfo.environment["OLDPWD"] {
        // Run via Xcode
        return Path(oldPwd) + "ConfigurationPlist/TestResources"
    } else {
        // Run via Terminal
        return Path(FileManager.default.currentDirectoryPath) + "TestResources"
    }
}()

var path: Path {
    return resourcePath + "ConfigurationPlistTests"
}

var srcPath: Path {
    return path + "src"
}

var outputPath: Path {
    return path + "output"
}

var expectedFilePath: Path {
    return outputPath + "Config.plist"
}

var expectedStagingFilePath: Path {
    return outputPath + "staging" + "Config.plist"
}

var expectedProductionFilePath: Path {
    return outputPath + "production" + "Config.plist"
}
