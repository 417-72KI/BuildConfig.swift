//
//  FakeApp.swift
//  BuildConfigSwiftDemoTests
//
//  Created by 417.72KI on 2023/10/09.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import SwiftUI

@objc(FakeApp)
enum FakeApp: Int { // avoid crash `apps must be value types class`
    case fake

    init() { self = .fake }
}

extension FakeApp: App {
    var body: some Scene {
        WindowGroup {
            Text("This is a fake app.")
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.black
                }
        }
    }
}
