//
//  APIClientTests.swift
//  BuildConfigSwiftDemoTests
//
//  Created by 417.72KI on 2023/10/05.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import XCTest
import StubNetworkKit

@testable import BuildConfigSwiftDemo

final class APIClientTests: XCTestCase {
    var config = BuildConfig.fake.api

    var apiClient: APIClient!

    override func setUpWithError() throws {
        apiClient = APIClient(config: config,
                              session: defaultStubSession)
    }

    override func tearDownWithError() throws {
        clearStubs()
    }

    func testLogin() async throws {
        stub { 
            Scheme.is("https")
            Host.is("localhost")
            Path.is("/login")
            Method.isPost()
            Body.isJson(["id": "john_doe", "password": "password"])
        }.responseJson(["access_token": "foo", "refresh_token": "bar"])

        let response = try await apiClient.login(id: "john_doe",
                                                 password: "password")
        XCTAssertEqual("foo", response.accessToken)
        XCTAssertEqual("bar", response.refreshToken)
    }

    @available(iOS 16.0, *)
    func testSearch() async throws {
        stub {
            Scheme.is("https")
            Host.is("localhost")
            Path.is("/search")
            Method.isGet()
            QueryParams.contains(["text": "寿限無"])
        }.responseJson([
            "items": [
                ["name": "foo"],
                ["name": "bar"],
                ["name": "baz"],
            ]
        ])

        let response = try await apiClient.search("寿限無")
        XCTAssertEqual(3, response.items.count)
        XCTAssertEqual("foo", response.items.first?.name)
        XCTAssertEqual("baz", response.items.last?.name)
    }
}
