//
//  DemoApp.swift
//  BuildConfig.swiftDemo
//
//  Created by 417.72KI on 2022/04/11.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import SwiftUI

struct DemoApp: App {
    static var buildConfig: BuildConfig = .default

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.buildConfig, Self.buildConfig)
        }
    }
}
