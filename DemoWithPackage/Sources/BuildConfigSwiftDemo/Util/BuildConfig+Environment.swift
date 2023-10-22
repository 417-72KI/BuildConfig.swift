//
//  BuildConfig+Environment.swift
//  BuildConfigSwiftDemo
//
//  Created by 417.72KI on 2023/10/09.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import SwiftUI

struct BuildConfigKey: EnvironmentKey {
    static let defaultValue = BuildConfig.default
}

extension EnvironmentValues {
    var buildConfig: BuildConfig {
        get { self[BuildConfigKey.self] }
        set { self[BuildConfigKey.self] = newValue }
    }
}
