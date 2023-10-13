import Foundation
import ArgumentParser

extension Process {
    var exitCode: ExitCode { .init(terminationStatus) }
}

extension Process {
    func setEnvironmentForTest(tmpDirectory: URL) {
        if case .none = environment { environment = [:] }
        environment?["TEMP_DIR"] = tmpDirectory.absoluteString
        environment?["SCRIPT_OUTPUT_FILE_COUNT"] = "1"
        environment?["SCRIPT_OUTPUT_FILE_0"] = "\(tmpDirectory.absoluteString)/BuildConfig.generated.swift"
    }

    func addDeprecatedLastrunIntoEnvironment() {
        environment?["SCRIPT_INPUT_FILE_COUNT"] = "1"
        environment?["SCRIPT_INPUT_FILE_0"] = "$(TEMP_DIR)/buildconfigswift-lastrun"
    }
}
