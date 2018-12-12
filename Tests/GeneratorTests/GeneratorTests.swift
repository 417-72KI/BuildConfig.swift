import SourceKittenFramework
import Foundation
import PathKit
import Quick
import Nimble
import MirrorDiffKit

@testable import Generator

final class GeneratorTests: QuickSpec {
    override func spec() {
        describe("Generator") {
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
                it("success") {
                    let file = File(path: path + "Testcase.swift")
                    let contents = file?.contents
                    do {
                        let actual = try Generator(data: data).run()
                        expect { actual }.to(equal(contents), description: diff(between: actual, and: contents))
                    } catch {
                        fail(error.localizedDescription)
                    }
                }
            }

            context("nested data empty") {
                let content = [
                    "a_struct": [:],
                    "b_struct": ["hoge": "fuga"]
                    ] as [AnyHashable: Any]
                let data = try! PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
                it("success") {
                    let file = File(path: path + "EmptyNestCase.swift")
                    let contents = file?.contents
                    do {
                        let actual = try Generator(data: data).run()
                        expect { actual }.to(equal(contents), description: diff(between: actual, and: contents))
                    } catch {
                        fail(error.localizedDescription)
                    }
                }
            }

            context("empty data") {
                let content = [:] as [AnyHashable: Any]
                let data = try! PropertyListSerialization.data(fromPropertyList: content, format: .binary, options: 0)
                it("success") {
                    let file = File(path: path + "EmptyCase.swift")
                    let contents = file?.contents
                    do {
                        let actual = try Generator(data: data).run()
                        expect { actual }.to(equal(contents), description: diff(between: actual, and: contents))
                    } catch {
                        fail(error.localizedDescription)
                    }
                }
            }

            context("invalid data") {
                let data = "string".data(using: .utf8)!
                it("fail") {
                    expect { try Generator(data: data).run() }.to(throwError(GeneratorError.invalidData))
                }
            }
        }
    }
}
