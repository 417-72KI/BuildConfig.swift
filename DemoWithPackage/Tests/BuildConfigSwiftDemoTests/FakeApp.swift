//
//  FakeApp.swift
//  BuildConfigSwiftDemoTests
//
//  Created by 417.72KI on 2023/10/09.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import SwiftUI

@objc(FakeApp)
final class FakeApp: NSObject, App {
    override init() { super.init() }

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
