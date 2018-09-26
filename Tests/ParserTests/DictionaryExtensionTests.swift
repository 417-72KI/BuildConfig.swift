import Foundation
import Quick
import Nimble

import Common
@testable import Parser

final class DictionaryExtensionTests: QuickSpec {
    override func spec() {
        describe("Dictionary") {
            describe("merge") {
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
    "b": 4,
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
                do {
                    let decoder = JSONDecoder()
                    let dict1 = try decoder.decode(AnyParsable.self, from: json1).value as? [String: AnyParsable] ?? [:]
                    let dict2 = try decoder.decode(AnyParsable.self, from: json2).value as? [String: AnyParsable] ?? [:]
                    let dict3 = try decoder.decode(AnyParsable.self, from: json3).value as? [String: AnyParsable] ?? [:]
                    it("dict1") {
                        expect { dict1["a"]?.value as? Int }.to(equal(1))
                        expect { dict1["b"]?.value as? String }.to(equal("2"))
                        expect { dict1["c"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let c = dict1["c"]?.value as? [String: AnyParsable]
                        expect { c?["d"]?.value as? Int }.to(equal(3))
                        expect { c?["e"]?.value }.to(beNil())
                        expect { dict1["f"]?.value as? Int }.to(equal(2))
                        expect { dict1["h"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let h = dict1["h"]?.value as? [String: AnyParsable]
                        expect { h?["i"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let i = h?["i"]?.value as? [String: AnyParsable]
                        expect { i?["j"]?.value as? Int }.to(equal(9))
                        expect { i?["k"]?.value as? Bool }.to(beTrue())
                        expect { i?["l"]?.value }.to(beAKindOf([AnyParsable].self))
                        let l = i?["l"]?.value as? [AnyParsable]
                        expect { l?.map { $0.value as? Int } }.to(equal([1, 2, 3]))
                        expect { i?["m"]?.value }.to(beNil())
                        expect { h?["n"]?.value as? Int }.to(equal(0))
                    }
                    it("dict2") {
                        expect { dict2["a"]?.value }.to(beNil())
                        expect { dict2["b"]?.value as? Int }.to(equal(4))
                        expect { dict2["c"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let c = dict2["c"]?.value as? [String: AnyParsable]
                        expect { c?["d"]?.value }.to(beNil())
                        expect { c?["e"]?.value as? String }.to(equal("5"))
                        expect { dict2["f"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let f = dict2["f"]?.value as? [String: AnyParsable]
                        expect { f?["g"]?.value as? Int }.to(equal(6))
                        expect { dict2["h"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let h = dict2["h"]?.value as? [String: AnyParsable]
                        expect { h?["i"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let i = h?["i"]?.value as? [String: AnyParsable]
                        expect { i?["j"]?.value }.to(beNil())
                        expect { i?["k"]?.value }.to(beNil())
                        expect { i?["l"]?.value }.to(beAKindOf([AnyParsable].self))
                        let l = i?["l"]?.value as? [AnyParsable]
                        expect { l?.map { $0.value as? Int } }.to(equal([4]))
                        expect { i?["m"]?.value as? Int }.to(equal(7))
                        expect { h?["n"]?.value }.to(beNil())
                    }
                    it("dict3") {
                        expect { dict3["a"]?.value as? Int }.to(equal(1))
                        expect { dict3["b"]?.value as? Int }.to(equal(4))
                        expect { dict3["c"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let c = dict3["c"]?.value as? [String: AnyParsable]
                        expect { c?["d"]?.value as? Int }.to(equal(3))
                        expect { c?["e"]?.value as? String }.to(equal("5"))
                        expect { dict3["f"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let f = dict3["f"]?.value as? [String: AnyParsable]
                        expect { f?["g"]?.value as? Int }.to(equal(6))
                        expect { dict3["h"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let h = dict3["h"]?.value as? [String: AnyParsable]
                        expect { h?["i"]?.value }.to(beAKindOf([String: AnyParsable].self))
                        let i = h?["i"]?.value as? [String: AnyParsable]
                        expect { i?["j"]?.value as? Int }.to(equal(9))
                        expect { i?["k"]?.value as? Bool }.to(beTrue())
                        expect { i?["l"]?.value }.to(beAKindOf([AnyParsable].self))
                        let l = i?["l"]?.value as? [AnyParsable]
                        expect { l?.map { $0.value as? Int } }.to(equal([1, 2, 3, 4]))
                        expect { i?["m"]?.value as? Int }.to(equal(7))
                        expect { h?["n"]?.value as? Int }.to(equal(0))
                    }
                    it("dict1 + dict2 equal dict3") {
                        expect { AnyParsable(dict1 + dict2) }.to(equal(AnyParsable(dict3)))
                    }
                } catch {
                    fail(error.localizedDescription)
                }
            }
        }
    }
}
