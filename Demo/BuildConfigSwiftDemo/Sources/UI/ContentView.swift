//
//  ContentView.swift
//  BuildConfig.swiftDemo
//
//  Created by 417.72KI on 2022/04/11.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var config: BuildConfig = .default

    var body: some View {
        VStack {
            Text("isDebug: \(String(config.isDebug))")
            Text("Environment: \(config.environment)")
            Text("API version: \(config.apiVersion)")
            Text("PI: \(config.pi)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
