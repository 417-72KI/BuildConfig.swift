import Foundation
import PackagePlugin

@main
struct BuildConfigSwiftGenerate: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        guard let target = target as? SourceModuleTarget else { return [] }

        guard let buildConfigDirectoryPath = try find(
            resourceDirectoryName,
            in: target.directory
                .removingLastComponent()
                .removingLastComponent()
        ) else {
            throw Error.directoryNotFound(in: target.directory)
        }
        let generatedFileContainerPath = context.pluginWorkDirectory
            .appending(subpath: target.name)
            .appending(subpath: resourceDirectoryName)

        try FileManager.default.createDirectory(
            atPath: generatedFileContainerPath.string,
            withIntermediateDirectories: true
        )

        let description = "\(target.kind) \(target.name)"
        return [
            .buildCommand(
                displayName: "BuildConfig.swift generate for \(description)",
                executable: try context.tool(named: "buildconfigswift").path,
                arguments: [
                    "-o",
                    generatedFileContainerPath.string,
                    buildConfigDirectoryPath.string
                ],
                outputFiles: [generatedFileContainerPath.appending(generatedFileName)]
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension BuildConfigSwiftGenerate: XcodeBuildToolPlugin {
    func createBuildCommands(
        context: XcodeProjectPlugin.XcodePluginContext,
        target: XcodeProjectPlugin.XcodeTarget
    ) throws -> [PackagePlugin.Command] {
        guard let buildConfigDirectoryPath = try find(resourceDirectoryName,
                                                      in: context.xcodeProject.directory) else {
            throw Error.directoryNotFound(in: context.xcodeProject.directory)
        }
        let generatedFileContainerPath = context.pluginWorkDirectory
            .appending(subpath: target.displayName)
            .appending(subpath: resourceDirectoryName)

        try FileManager.default.createDirectory(
            atPath: generatedFileContainerPath.string,
            withIntermediateDirectories: true
        )

        let description: String
        if let product = target.product {
            description = "\(product.kind) \(target.displayName)"
        } else {
            description = target.displayName
        }
        return [
            .buildCommand(
                displayName: "BuildConfig.swift generate for \(description)",
                executable: try context.tool(named: "buildconfigswift").path,
                arguments: [
                    "-o",
                    generatedFileContainerPath.string,
                    buildConfigDirectoryPath.string
                ],
                outputFiles: [generatedFileContainerPath.appending(generatedFileName)]
            )
        ]
    }
}
#endif

private extension BuildConfigSwiftGenerate {
    var resourceDirectoryName: String { "BuildConfig" }
    var generatedFileName: String { "BuildConfig.generated.swift" }
    var ignoreDirectories: [String] {
        [
            ".build",
            ".swiftpm",
            "build",
            "Build",
            "DerivedData",
            "Packages",
            "SourcePackages",
        ]
    }
}

private extension BuildConfigSwiftGenerate {
    func find(_ path: String, in targetPath: Path) throws -> Path? {
        let fm = FileManager.default
        var isDirectory = ObjCBool(false)
        guard fm.fileExists(atPath: targetPath.string,
                            isDirectory: &isDirectory),
              isDirectory.boolValue else { preconditionFailure() }
        if ignoreDirectories.contains(targetPath.lastComponent) {
            return nil
        }
        let files = try fm.contentsOfDirectory(atPath: targetPath.string)
        if files.contains(path) {
            return targetPath.appending(path)
        }
        return try files.lazy
            .map(targetPath.appending(subpath:))
            .filter(fm.isDirectory(atPath:))
            .compactMap { try find(path, in: $0) }
            .first
    }
}

private extension BuildConfigSwiftGenerate {
    enum Error: Swift.Error {
        case directoryNotFound(in: Path)
    }
}

extension BuildConfigSwiftGenerate.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case let .directoryNotFound(path):
            return "Directory `BuildConfig` not found in project: \(path.string)"
        }
    }
}

// MARK: -
private extension FileManager {
    func isDirectory(atPath path: Path) -> Bool {
        var isDirectory = ObjCBool(false)
        guard fileExists(atPath: path.string, isDirectory: &isDirectory) else {
            return false
        }
        return isDirectory.boolValue
    }
}
