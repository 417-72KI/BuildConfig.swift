//
//  DemoApp.swift
//  BuildConfig.swiftDemo
//
//  Created by 417.72KI on 2022/04/11.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - For Debug
#if DEBUG
private extension DemoApp {
    var isTesting: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
#endif
