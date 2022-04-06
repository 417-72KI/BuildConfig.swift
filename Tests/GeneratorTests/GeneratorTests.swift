import SourceKittenFramework
import Foundation
import PathKit
import XCTest
import MirrorDiffKit

@testable import Generator

final class GeneratorTests: XCTestCase {
    func testGenerator() throws {
        context("valid data") {
            let content = [
                "API": [
                    "domain": "http://192.168.0.1",
                    "path": [
                        "login": [
                            "method": "POST",
                            "path": "/login"
                        ]
                    ]
                ],
                "boot": ["message": "Hello, World!"],
                "environment": "development",
                "token": 123456,
                "license": ["Yaml", "PathKit", "StencilSwiftKit"],
                "isDebug": false,
                "pi": 3.14159265358979
                ] as [AnyHashable: Any]
            let data = try! PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
            context("success") {
                let file = File(path: path + "Testcase.swift")
                let contents = file?.contents
                do {
                    let actual = try Generator(data: data).run()
                    XCTAssertEqual(actual, contents, diff(between: actual, and: contents))
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }

        context("nested data empty") {
            let content = [
                "a_struct": [:],
                "b_struct": ["hoge": "fuga"]
                ] as [AnyHashable: Any]
            let data = try! PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
            context("success") {
                let file = File(path: path + "EmptyNestCase.swift")
                let contents = file?.contents
                do {
                    let actual = try Generator(data: data).run()
                    XCTAssertEqual(actual, contents, diff(between: actual, and: contents))
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }

        context("empty data") {
            let content = [:] as [AnyHashable: Any]
            let data = try! PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
            context("success") {
                let file = File(path: path + "EmptyCase.swift")
                let contents = file?.contents
                do {
                    let actual = try Generator(data: data).run()
                    XCTAssertEqual(actual, contents, diff(between: actual, and: contents))
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }

        try context("invalid data") {
            let data = "string".data(using: .utf8)!
            try context("fail") {
                XCTAssertThrowsError(try Generator(data: data).run()) {
                    guard case .invalidData = $0 as? GeneratorError else {
                        XCTFail($0.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}
