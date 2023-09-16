import SourceKittenFramework
import Foundation
import PathKit
import XCTest
import MirrorDiffKit

@testable import Generator

final class GeneratorTests: XCTestCase {
    func testGenerator() throws {
        try context("valid data") {
            let content = [
                "API": [
                    "domain": "http://192.168.0.1",
                    "path": [
                        "login": [
                            "method": "POST",
                            "path": "/login"
                        ]
                    ]
                ] as [String : Any],
                "boot": ["message": "Hello, World!"],
                "environment": "development",
                "token": 123456,
                "license": ["Yaml", "PathKit", "StencilSwiftKit"],
                "isDebug": false,
                "pi": 3.14159265358979
            ] as [String: Any]
            let data = try JSONSerialization.data(withJSONObject: content, options: .sortedKeys)
            try context("success") {
                let file = try XCTUnwrap(File(path: path + "Testcase.swift"))
                let contents = file.contents
                    .split(separator: "\n")

                let actual = try Generator(data: data).run()
                    .split(separator: "\n")

                XCTAssertEqual(contents.count, actual.count)
                let zipped = zip(actual, contents)

                zipped
                    .dropLast()
                    .enumerated()
                    .forEach {
                        XCTAssertEqual($1.0, $1.1, "Line \($0)\n" + diff(between: $1.0, and: $1.1))
                    }

                try context("rawData") {
                    let (actual, expected) = try XCTUnwrap(zipped.suffix(1).first)
                    let base64String = (actual: String(actual.dropFirst(43).dropLast(3)), expected: String(expected.dropFirst(43).dropLast(3)))
                    XCTAssertEqual(base64String.actual, base64String.expected)
                    let actualDic = try JSONSerialization.jsonObject(with: try XCTUnwrap(Data(base64Encoded: base64String.actual))) as? NSDictionary
                    let expectedDic = try JSONSerialization.jsonObject(with: try XCTUnwrap(Data(base64Encoded: base64String.expected))) as? NSDictionary
                    XCTAssertEqual(actualDic, expectedDic, diff(between: actualDic, and: expectedDic))
                }
            }
        }

        try context("nested data empty") {
            let content = [
                "a_struct": [:] as [String: Any],
                "b_struct": ["hoge": "fuga"]
                ] as [String: Any]
            let data = try JSONSerialization.data(withJSONObject: content, options: .sortedKeys)
            try context("success") {
                let file = try XCTUnwrap(File(path: path + "EmptyNestCase.swift"))
                let contents = file.contents
                    .split(separator: "\n")

                let actual = try Generator(data: data).run()
                    .split(separator: "\n")

                XCTAssertEqual(contents.count, actual.count)

                let zipped = zip(actual, contents)

                zipped
                    .dropLast()
                    .enumerated()
                    .forEach {
                        XCTAssertEqual($1.0, $1.1, "Line \($0)\n" + diff(between: $1.0, and: $1.1))
                    }

                try context("rawData") {
                    let (actual, expected) = try XCTUnwrap(zipped.suffix(1).first)
                    let base64String = (actual: String(actual.dropFirst(43).dropLast(3)), expected: String(expected.dropFirst(43).dropLast(3)))
                    XCTAssertEqual(base64String.actual, base64String.expected)
                    let actualDic = try JSONSerialization.jsonObject(with: try XCTUnwrap(Data(base64Encoded: base64String.actual))) as? NSDictionary
                    let expectedDic = try JSONSerialization.jsonObject(with: try XCTUnwrap(Data(base64Encoded: base64String.expected))) as? NSDictionary
                    XCTAssertEqual(actualDic, expectedDic, diff(between: actualDic, and: expectedDic))
                }
            }
        }

        try context("empty data") {
            let content = [:] as [AnyHashable: Any]
            let data = try JSONSerialization.data(withJSONObject: content, options: .sortedKeys)
            try context("success") {
                let file = try XCTUnwrap(File(path: path + "EmptyCase.swift"))
                let contents = file.contents
                let actual = try Generator(data: data).run()
                XCTAssertEqual(actual, contents, diff(between: actual, and: contents))
            }
        }

        try context("invalid data") {
            let data = "string".data(using: .utf8)!
            try context("fail") {
                XCTAssertThrowsError(try Generator(data: data).run()) {
                    guard case GeneratorError.invalidData = $0 else {
                        XCTFail($0.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}
