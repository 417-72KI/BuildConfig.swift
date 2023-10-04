import Foundation
import PathKit
import SourceKittenFramework
import Common
import XCTest

@testable import Parser

final class FileParserTests: XCTestCase {
    func testYamlParser() throws {
        let parser = YamlParser()
        try context("valid yaml") {
            let file = try XCTUnwrap(File(path: path + Path("test.yaml")))
            try context("for TestContent") {
                let expected = TestContent(
                    api: TestContent.API(
                        domain: URL(string: "http://localhost")!,
                        api: [
                            "login": TestContent.API.Path(method: .post, path: "/login"),
                            "getList": TestContent.API.Path(method: .get, path: "/list")
                        ],
                        timeout: 11.5,
                        apiVersion: 1
                    ),
                    count: 0,
                    isDebug: true
                )
                XCTAssertEqual(try parser.parse(TestContent.self, file: file), expected)
            }
            try context("for AnyParsable") {
                let data = try parser.parse(file: file)
                let root = try XCTUnwrap(data.value as? [String: AnyParsable])
                let api = try XCTUnwrap(root["API"]?.value as? [String: AnyParsable])
                let domain = try XCTUnwrap(api["domain"]?.value as? String)
                XCTAssertEqual(domain, "http://localhost")

                let timeout = try XCTUnwrap(api["timeout"]?.value as? Decimal)
                XCTAssertEqual(timeout, 11.5)

                let apiVersion = try XCTUnwrap(api["api_version"]?.value as? Decimal)
                XCTAssertEqual(1, apiVersion)

                let count = try XCTUnwrap(root["count"]?.value as? Decimal)
                XCTAssertEqual(count, 0)

                let isDebug = try XCTUnwrap(root["is_debug"]?.value as? Bool)
                XCTAssertTrue(isDebug)
            }
        }
    }

    func testJSonParser() throws {
        let parser = JSonParser()
        try context("valid json") {
            let file = try XCTUnwrap(File(path: path + Path("test.json")))
            try context("for TestContent") {
                let expected = TestContent(
                    api: TestContent.API(
                        domain: URL(string: "http://localhost")!,
                        api: [
                            "login": TestContent.API.Path(method: .post, path: "/login"),
                            "getList": TestContent.API.Path(method: .get, path: "/list")
                        ],
                        timeout: 10.5,
                        apiVersion: 1
                    ),
                    count: 0,
                    isDebug: true
                )
                XCTAssertEqual(try parser.parse(TestContent.self, file: file), expected)
            }
            try context("for AnyParsable") {
                let data = try parser.parse(file: file)
                let root = try XCTUnwrap(data.value as? [String: AnyParsable])
                let api = try XCTUnwrap(root["API"]?.value as? [String: AnyParsable])
                let domain = try XCTUnwrap(api["domain"]?.value as? String)
                XCTAssertEqual(domain, "http://localhost")

                let timeout = try XCTUnwrap(api["timeout"]?.value as? Decimal)
                XCTAssertEqual(timeout, 10.5)

                let apiVersion = try XCTUnwrap(api["api_version"]?.value as? Decimal)
                XCTAssertEqual(1, apiVersion)

                let count = try XCTUnwrap(root["count"]?.value as? Decimal)
                XCTAssertEqual(count, 0)

                let isDebug = try XCTUnwrap(root["is_debug"]?.value as? Bool)
                XCTAssertTrue(isDebug)
            }
        }
    }
}

private struct TestContent: Codable, Equatable {
    let api: API
    let count: Int
    let isDebug: Bool

    struct API: Codable, Equatable {
        let domain: URL
        let api: [String: Path]
        let timeout: Double
        let apiVersion: Int

        struct Path: Codable, Equatable {
            let method: Method
            let path: String
        }

        enum Method: String, Codable {
            case get = "GET"
            case post = "POST"
        }

        enum CodingKeys: String, CodingKey {
            case domain, api, timeout, apiVersion = "api_version"
        }
    }

    enum CodingKeys: String, CodingKey {
        case api = "API", count, isDebug = "is_debug"
    }
}
