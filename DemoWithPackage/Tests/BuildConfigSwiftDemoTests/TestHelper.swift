//
//  TestHelper.swift
//  BuildConfigSwiftDemoTests
//
//  Created by 417.72KI on 2023/10/05.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import Foundation
@testable import BuildConfigSwiftDemo

final class TestHelper {
    private init() {}
}

extension TestHelper {
    static var bundle: Bundle { Bundle(for: self.self) }
}

extension TestHelper {
    static func path(forResource name: String, ofType ext: String) -> String? {
        bundle.path(forResource: name, ofType: ext)
    }
}

extension BuildConfig {
    static var fake: Self {
        .load(from: TestHelper.path(forResource: "test_config", ofType: "json")!)
    }
}
