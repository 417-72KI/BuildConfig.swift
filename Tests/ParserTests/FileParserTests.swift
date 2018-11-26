import Foundation
import PathKit
import SourceKittenFramework

import Quick
import Nimble

import Common
@testable import Parser

final class FileParserTests: QuickSpec {
    override func spec() {
        describe("YamlParser") {
            let parser = YamlParser()
            context("valid yaml") {
                let f = File(path: path + Path("test.yaml"))
                it("found") {
                    expect { f }.notTo(beNil())
                }
                guard let file = f else { return }
                context("for TestContent") {
                    it("success") {
                        let expected = TestContent(
                            api: TestContent.API(
                                domain: URL(string: "http://localhost")!,
                                api: [
                                    "login": TestContent.API.Path(method: .post, path: "/login"),
                                    "getList": TestContent.API.Path(method: .get, path: "/list")
                                ],
                                timeout: 11.5
                            ),
                            count: 0,
                            isDebug: true
                        )
                        expect { try parser.parse(TestContent.self, file: file) }.to(equal(expected))
                    }
                }
                context("for AnyParsable") {
                    do {
                        let data = try parser.parse(file: file)
                        context("root") {
                            expect { data.value }.to(beAKindOf([String: AnyParsable].self))
                            guard let root = data.value as? [String: AnyParsable] else { return }
                            it("API") {
                                expect(root.keys).to(contain("API"))
                                expect { root["API"]?.value }.to(beAKindOf([String: AnyParsable].self))
                                guard let api = root["API"]?.value as? [String: AnyParsable] else { return }
                                expect(api.keys).to(contain("domain"))
                                expect { api["domain"]?.value }.to(beAKindOf(String.self))
                                guard let domain = api["domain"]?.value as? String else { return }
                                expect { domain }.to(equal("http://localhost"))

                                expect(api.keys).to(contain("timeout"))
                                expect { api["timeout"]?.value }.to(beAKindOf(Double.self))
                                guard let timeout = api["timeout"]?.value as? Double else { return }
                                expect { timeout }.to(equal(11.5))
                            }
                            it("count") {
                                expect(root.keys).to(contain("count"))
                                expect { root["count"]?.value }.to(beAKindOf(Int.self))
                                guard let count = root["count"]?.value as? Int else { return }
                                expect { count }.to(equal(0))
                            }
                            it("is_debug") {
                                expect(root.keys).to(contain("is_debug"))
                                expect { root["is_debug"]?.value }.to(beAKindOf(Bool.self))
                                guard let isDebug = root["is_debug"]?.value as? Bool else { return }
                                expect(isDebug).to(beTrue())
                            }
                        }
                    } catch {
                        fail(error.localizedDescription)

                    }
                }
            }
        }
        describe("JSonParser") {
            let parser = JSonParser()
            context("valid json") {
                let f = File(path: path + Path("test.json"))
                it("found") {
                    expect { f }.notTo(beNil())
                }
                guard let file = f else { return }
                context("for TestContent") {
                    it("success") {
                        let expected = TestContent(
                            api: TestContent.API(
                                domain: URL(string: "http://localhost")!,
                                api: [
                                    "login": TestContent.API.Path(method: .post, path: "/login"),
                                    "getList": TestContent.API.Path(method: .get, path: "/list")
                                ],
                                timeout: 10.5
                            ),
                            count: 0,
                            isDebug: true
                            )
                        expect { try parser.parse(TestContent.self, file: file) }.to(equal(expected))
                    }
                }
                context("for AnyParsable") {
                    do {
                        let data = try parser.parse(file: file)
                        context("root") {
                            expect { data.value }.to(beAKindOf([String: AnyParsable].self))
                            guard let root = data.value as? [String: AnyParsable] else { return }
                            it("API") {
                                expect(root.keys).to(contain("API"))
                                expect { root["API"]?.value }.to(beAKindOf([String: AnyParsable].self))
                                guard let api = root["API"]?.value as? [String: AnyParsable] else { return }
                                expect(api.keys).to(contain("domain"))
                                expect { api["domain"]?.value }.to(beAKindOf(String.self))
                                guard let domain = api["domain"]?.value as? String else { return }
                                expect { domain }.to(equal("http://localhost"))

                                expect(api.keys).to(contain("timeout"))
                                expect { api["timeout"]?.value }.to(beAKindOf(Double.self))
                                guard let timeout = api["timeout"]?.value as? Double else { return }
                                expect { timeout }.to(equal(10.5))
                            }
                            it("count") {
                                expect(root.keys).to(contain("count"))
                                expect { root["count"]?.value }.to(beAKindOf(Int.self))
                                guard let count = root["count"]?.value as? Int else { return }
                                expect { count }.to(equal(0))
                            }
                            it("is_debug") {
                                expect(root.keys).to(contain("is_debug"))
                                expect { root["is_debug"]?.value }.to(beAKindOf(Bool.self))
                                guard let isDebug = root["is_debug"]?.value as? Bool else { return }
                                expect(isDebug).to(beTrue())
                            }
                        }
                    } catch {
                        fail(error.localizedDescription)
                    }
                }
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

        struct Path: Codable, Equatable {
            let method: Method
            let path: String
        }

        enum Method: String, Codable {
            case get = "GET"
            case post = "POST"
        }
    }

    enum CodingKeys: String, CodingKey {
        case api = "API"
        case count
        case isDebug = "is_debug"
    }
}
