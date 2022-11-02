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
                ],
                "boot": ["message": "Hello, World!"],
                "environment": "development",
                "token": 123456,
                "license": ["Yaml", "PathKit", "StencilSwiftKit"],
                "isDebug": false,
                "pi": 3.14159265358979
            ] as [AnyHashable: Any]
            let data = try PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
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
                    let actualDic = try PropertyListSerialization.propertyList(from: try XCTUnwrap(Data(base64Encoded: String(actual.dropFirst(43).dropLast(3)))), format: nil) as? NSDictionary
                    let expectedDic = try PropertyListSerialization.propertyList(from: try XCTUnwrap(Data(base64Encoded: String(expected.dropFirst(43).dropLast(3)))), format: nil) as? NSDictionary
                    XCTAssertEqual(actualDic, expectedDic, diff(between: actualDic, and: expectedDic))
                }
            }
        }

        try context("nested data empty") {
            let content = [
                "a_struct": [:],
                "b_struct": ["hoge": "fuga"]
                ] as [AnyHashable: Any]
            let data = try PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
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
                    let actualDic = try PropertyListSerialization.propertyList(from: try XCTUnwrap(Data(base64Encoded: String(actual.dropFirst(43).dropLast(3)))), format: nil) as? NSDictionary
                    let expectedDic = try PropertyListSerialization.propertyList(from: try XCTUnwrap(Data(base64Encoded: String(expected.dropFirst(43).dropLast(3)))), format: nil) as? NSDictionary
                    XCTAssertEqual(actualDic, expectedDic, diff(between: actualDic, and: expectedDic))
                }
            }
        }

        try context("empty data") {
            let content = [:] as [AnyHashable: Any]
            let data = try PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
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
                    guard case .invalidData = $0 as? GeneratorError else {
                        XCTFail($0.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}
