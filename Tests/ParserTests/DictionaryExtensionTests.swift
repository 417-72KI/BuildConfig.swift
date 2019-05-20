import Foundation
import XCTest

import Common
@testable import Parser

final class DictionaryExtensionTests: XCTestCase {
    func testDictionary() throws {
        let json1 = """
            {
                "a": 1,
                "b": "2",
                "c": {
                    "d": 3
                },
                "f": 2,
                "h": {
                    "i": {
                        "j": 9,
                        "k": true,
                        "l": [1, 2, 3]
                    },
                    "n": 0
                }
            }
            """.data(using: .utf8)!
        let json2 = """
            {
                "b": 4,
                "c": {
                    "e": "5"
                },
                "f": {
                    "g": 6
                },
                "h": {
                    "i": {
                        "l": [4],
                        "m": 7
                    }
                }
            }
            """.data(using: .utf8)!
        let json3 = """
            {
                "a": 1,
                "b": 4.0,
                "c": {
                    "d": 3,
                    "e": "5"
                },
                "f": {
                    "g": 6
                },
                "h": {
                    "i": {
                        "j": 9,
                        "k": true,
                        "l": [1, 2, 3, 4],
                        "m": 7
                    },
                    "n": 0
                }
            }
            """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let dict1 = try decoder.decode(AnyParsable.self, from: json1).value as? [String: AnyParsable] ?? [:]
        let dict2 = try decoder.decode(AnyParsable.self, from: json2).value as? [String: AnyParsable] ?? [:]
        let dict3 = try decoder.decode(AnyParsable.self, from: json3).value as? [String: AnyParsable] ?? [:]
        try context("dict1") {
            XCTAssertEqual(dict1["a"]?.value as? Int, 1)
            XCTAssertEqual(dict1["b"]?.value as? String, "2")

            let c = try XCTUnwrap(dict1["c"]?.value as? [String: AnyParsable])
            XCTAssertEqual(c["d"]?.value as? Int, 3)
            XCTAssertNil(c["e"]?.value)
            XCTAssertEqual(dict1["f"]?.value as? Int, 2)

            let h = try XCTUnwrap(dict1["h"]?.value as? [String: AnyParsable])
            let i = try XCTUnwrap(h["i"]?.value as? [String: AnyParsable])
            XCTAssertEqual(i["j"]?.value as? Int, 9)
            XCTAssertEqual(i["k"]?.value as? Bool, true)

            let l = try XCTUnwrap(i["l"]?.value as? [AnyParsable])
            XCTAssertEqual(l.map { $0.value as? Int }, [1, 2, 3])
            XCTAssertNil(i["m"]?.value)
            XCTAssertEqual(h["n"]?.value as? Int, 0)
        }
        try context("dict2") {
            XCTAssertNil(dict2["a"]?.value)
            XCTAssertEqual(dict2["b"]?.value as? Int, 4)

            let c = try XCTUnwrap(dict2["c"]?.value as? [String: AnyParsable])
            XCTAssertNil(c["d"]?.value)
            XCTAssertEqual(c["e"]?.value as? String, "5")

            let f = try XCTUnwrap(dict2["f"]?.value as? [String: AnyParsable])
            XCTAssertEqual(f["g"]?.value as? Int, 6)

            let h = try XCTUnwrap(dict2["h"]?.value as? [String: AnyParsable])

            let i = try XCTUnwrap(h["i"]?.value as? [String: AnyParsable])
            XCTAssertNil(i["j"]?.value)
            XCTAssertNil(i["k"]?.value)

            let l = try XCTUnwrap(i["l"]?.value as? [AnyParsable])
            XCTAssertEqual(l.map { $0.value as? Int }, [4])
            XCTAssertEqual(i["m"]?.value as? Int, 7)
            XCTAssertNil(h["n"]?.value)
        }
        try context("dict3") {
            XCTAssertEqual(dict3["a"]?.value as? Int, 1)
            XCTAssertEqual(dict3["b"]?.value as? Double, 4.0)

            let c = try XCTUnwrap(dict3["c"]?.value as? [String: AnyParsable])
            XCTAssertEqual(c["d"]?.value as? Int, 3)
            XCTAssertEqual(c["e"]?.value as? String, "5")

            let f = try XCTUnwrap(dict3["f"]?.value as? [String: AnyParsable])
            XCTAssertEqual(f["g"]?.value as? Int, 6)

            let h = try XCTUnwrap(dict3["h"]?.value as? [String: AnyParsable])

            let i = try XCTUnwrap(h["i"]?.value as? [String: AnyParsable])
            XCTAssertEqual(i["j"]?.value as? Int, 9)
            XCTAssertEqual(i["k"]?.value as? Bool, true)

            let l = try XCTUnwrap(i["l"]?.value as? [AnyParsable])
            XCTAssertEqual(l.map { $0.value as? Int }, [1, 2, 3, 4])
            XCTAssertEqual(i["m"]?.value as? Int, 7)
            XCTAssertEqual(h["n"]?.value as? Int, 0)
        }
        context("dict1 + dict2 equal dict3") {
            XCTAssertEqual(AnyParsable(dict1 + dict2), AnyParsable(dict3))
        }
    }
}
