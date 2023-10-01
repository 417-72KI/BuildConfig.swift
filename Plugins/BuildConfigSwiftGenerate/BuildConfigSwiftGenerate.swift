import Foundation
import PackagePlugin

@main
struct BuildConfigSwiftGenerate: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, 
                             target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        print(context)
        print(target)
        return []
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension BuildConfigSwiftGenerate: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, 
                             target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        print(context)
        print(target)
        return []
    }
}
#endif
