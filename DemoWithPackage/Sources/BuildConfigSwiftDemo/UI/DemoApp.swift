//
//  DemoApp.swift
//  BuildConfigSwiftDemo
//
//  Created by 417.72KI on 2022/04/11.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import SwiftUI

public struct DemoApp: App {
    static var buildConfig: BuildConfig = .default

    public init() {
    }

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.buildConfig, Self.buildConfig)
        }
    }
}
