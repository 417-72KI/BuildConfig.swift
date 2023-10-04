//
//  BuildConfigSwiftDemoTests.swift
//  BuildConfigSwiftDemoTests
//
//  Created by 417.72KI on 2019/05/09.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import XCTest
@testable import BuildConfigSwiftDemo

final class BuildConfigTests: XCTestCase {
    func testDefault() {
        let buildConfig = BuildConfig.default
        XCTAssertEqual(1, buildConfig.apiVersion)
        XCTAssertEqual("develop", buildConfig.environment)
        XCTAssertFalse(buildConfig.isDebug)
        XCTAssertEqual(3.14, buildConfig.pi, accuracy: 0.01)
    }

    func testLoad() {
        let buildConfig = BuildConfig.load(
            from: #"""
            {
                "api_version": 100, 
                "environment": "staging",
                "is_debug": true,
                "pi": 3.14
            }
            """#.data(using: .utf8)!
        )
        XCTAssertEqual(100, buildConfig.apiVersion)
        XCTAssertEqual("staging", buildConfig.environment)
        XCTAssertTrue(buildConfig.isDebug)
        XCTAssertEqual(3.14, buildConfig.pi, accuracy: 0.01)
    }
}
