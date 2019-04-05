import Foundation

extension Process {
    func setEnvironmentForTest(tmpDirectory: URL) {
        if case .none = environment { environment = [:] }
        environment?["TEMP_DIR"] = tmpDirectory.absoluteString
        environment?["SCRIPT_INPUT_FILE_COUNT"] = "1"
        environment?["SCRIPT_INPUT_FILE_0"] = "$(TEMP_DIR)/buildconfigswift-lastrun"
        environment?["SCRIPT_OUTPUT_FILE_COUNT"] = "2"
        environment?["SCRIPT_OUTPUT_FILE_0"] = "\(tmpDirectory.absoluteString)/BuildConfig.plist"
        environment?["SCRIPT_OUTPUT_FILE_1"] = "\(tmpDirectory.absoluteString)/BuildConfig.generated.swift"
    }
}
