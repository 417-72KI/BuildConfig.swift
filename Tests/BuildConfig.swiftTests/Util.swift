import PathKit
import Foundation

let resourcePath: Path = {
    let currentDirectoryPath = Path(FileManager.default.currentDirectoryPath)
    if currentDirectoryPath.string.contains("Xcode/DerivedData"),
        let oldPwd = ProcessInfo.processInfo.environment["OLDPWD"] {
        // Run via Xcode
        return Path(oldPwd) + "BuildConfig.swift/TestResources"
    } else {
        // Run via Terminal
        return Path(FileManager.default.currentDirectoryPath) + "TestResources"
    }
}()

var path: Path {
    return resourcePath + "BuildConfig.swiftTests"
}

var srcPath: Path {
    return path + "src"
}

var outputPath: Path {
    return path + "output"
}

var expectedFilePath: Path {
    return outputPath + "BuildConfig.plist"
}

var expectedStagingFilePath: Path {
    return outputPath + "staging" + "BuildConfig.plist"
}

var expectedProductionFilePath: Path {
    return outputPath + "production" + "BuildConfig.plist"
}
