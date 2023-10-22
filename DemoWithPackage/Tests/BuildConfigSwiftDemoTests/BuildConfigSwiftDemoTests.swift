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
        XCTAssertEqual(1, buildConfig.api.version)
        XCTAssertEqual("api-dev.example.com", buildConfig.api.host)
        XCTAssertEqual("debug", buildConfig.environment)
        XCTAssertTrue(buildConfig.isDebug)
        XCTAssertEqual(3.14, buildConfig.pi, accuracy: 0.01)
    }

    func testLoad() throws {
        let buildConfig = BuildConfig.fake
        XCTAssertEqual(100, buildConfig.api.version)
        XCTAssertEqual("localhost", buildConfig.api.host)
        XCTAssertEqual("staging", buildConfig.environment)
        XCTAssertFalse(buildConfig.isDebug)
        XCTAssertEqual(3.14, buildConfig.pi, accuracy: 0.01)
    }
}
