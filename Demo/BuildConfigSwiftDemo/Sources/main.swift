//
//  main.swift
//  BuildConfigSwiftDemo
//
//  Created by 417.72KI on 2023/10/09.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import SwiftUI

if let clazz = NSClassFromString("FakeApp") as? any App.Type {
    clazz.main()
} else {
    DemoApp.main()
}
