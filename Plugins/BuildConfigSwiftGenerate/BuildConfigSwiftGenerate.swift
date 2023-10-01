import Foundation
import PackagePlugin

@main
struct BuildConfigSwiftGenerate: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, 
                        arguments: [String]) async throws {
        print(context)
        print(arguments)
    }
}
