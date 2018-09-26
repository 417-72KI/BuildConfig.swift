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
            context("valid yaml for TestContent") {
                let file = File(path: path + Path("test.yaml"))!
                it("success") {
                    let expected = TestContent(api: TestContent.API(
                        domain: URL(string: "http://localhost")!,
                        api: [
                            "login": TestContent.API.Path(method: .post, path: "/login"),
                            "getList": TestContent.API.Path(method: .get, path: "/list")
                        ]))
                    expect { try parser.parse(TestContent.self, file: file) }.to(equal(expected))
                }
            }
            context("valid yaml for AnyParsable") {
                let file = File(path: path + Path("test.yaml"))!
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
                        }
                        it("count") {
                            expect(root.keys).to(contain("count"))
                            expect { root["count"]?.value }.to(beAKindOf(Int.self))
                            guard let count = root["count"]?.value as? Int else { return }
                            expect { count }.to(equal(0))
                        }
                    }
                } catch {
                    fail(error.localizedDescription)

                }
            }
        }
        describe("JSonParser") {
            let parser = JSonParser()
            context("valid json for TestContent") {
                let file = File(path: path + Path("test.json"))!
                it("success") {
                    let expected = TestContent(api: TestContent.API(
                        domain: URL(string: "http://localhost")!,
                        api: [
                            "login": TestContent.API.Path(method: .post, path: "/login"),
                            "getList": TestContent.API.Path(method: .get, path: "/list")
                        ]))
                    expect { try parser.parse(TestContent.self, file: file) }.to(equal(expected))
                }
            }
            context("valid json for AnyParsable") {
                let file = File(path: path + Path("test.json"))!
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
                        }
                        it("count") {
                            expect(root.keys).to(contain("count"))
                            expect { root["count"]?.value }.to(beAKindOf(Int.self))
                            guard let count = root["count"]?.value as? Int else { return }
                            expect { count }.to(equal(0))
                        }
                    }
                } catch {
                    fail(error.localizedDescription)
                }
            }
        }
    }
}

private struct TestContent: Codable, Equatable {
    let api: API

    struct API: Codable, Equatable {
        let domain: URL
        let api: [String: Path]

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
    }
}
