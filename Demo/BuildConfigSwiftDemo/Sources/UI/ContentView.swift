//
//  ContentView.swift
//  BuildConfig.swiftDemo
//
//  Created by 417.72KI on 2022/04/11.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.buildConfig) var config: BuildConfig

    var body: some View {
        VStack {
            Text("isDebug: \(String(config.isDebug))")
            Text("Environment: \(config.environment)")
            Text("API version: \(config.api.version, format: .number)")
            Text("PI: \(config.pi, format: .number)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
