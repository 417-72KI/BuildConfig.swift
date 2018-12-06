import SourceKittenFramework
import PathKit
import Quick
import Nimble

@testable import Parser

final class ParserTests: QuickSpec {
    override func spec() {
        describe("Parser") {
            let parser = Parser(directoryPath: path)
            describe("detect") {
                it("yaml") {
                    let file = File(path: path + "test.yaml")!
                    expect { try parser.detectParser(file) }.to(beAKindOf(YamlParser.self))
                }
                it("json") {
                    let file = File(path: path + "test.json")!
                    expect { try parser.detectParser(file) }.to(beAKindOf(JSonParser.self))
                }
                it("invalid") {
                    let file = File(path: path + "test.txt")!
                    expect { try parser.detectParser(file) }.to(throwError(ParserError.invalidFile(file.path!)))
                }
            }
            describe("getFileList") {
                describe("\(path)") {
                    context("environment is nil") {
                        it("detects 6 files") {
                            let files = ["test.yaml", "test.json", "test.txt",
                                         "d1/test.txt", "d2/test.txt", "d2/d1/test.txt"]
                            let expected = files.map { path + $0 }.sorted()
                            expect { try parser.getFileList(at: path).sorted() }.to(equal(expected))
                        }
                    }
                    context("environment is staging") {
                        it("detects 7 files") {
                            let files = ["test.yaml", "test.json", "test.txt",
                                         "d1/test.txt", "d2/test.txt", "d2/d1/test.txt", ".env/staging.json"]
                            let expected = files.map { path + $0 }.sorted()
                            expect { try parser.getFileList(at: path, environment: "staging").sorted() }.to(equal(expected))
                        }
                    }
                    context("environment is production") {
                        it("detects 7 files") {
                            let files = ["test.yaml", "test.json", "test.txt",
                                         "d1/test.txt", "d2/test.txt", "d2/d1/test.txt", ".env/production.yaml"]
                            let expected = files.map { path + $0 }.sorted()
                            expect { try parser.getFileList(at: path, environment: "production").sorted() }.to(equal(expected))
                        }
                    }
                }
            }
            describe("sort") {
                it("sorted") {
                    let files = [
                        "test.yaml",
                        "test.json",
                        "d1/.env/hoge.yml",
                        "test.txt",
                        "d1/test.txt",
                        ".env/staging.yaml",
                        "d2/test.txt",
                        "d2/d1/test.txt",
                        ".env/production.yaml",
                        "aaa.txt",
                        "abc.txt",
                        "1.txt"
                        ].map { path + $0 }
                    let expected = [
                        "1.txt",
                        "aaa.txt",
                        "abc.txt",
                        "d1/test.txt",
                        "d2/d1/test.txt",
                        "d2/test.txt",
                        "test.json",
                        "test.txt",
                        "test.yaml",
                        ".env/production.yaml",
                        ".env/staging.yaml",
                        "d1/.env/hoge.yml"
                        ].map { path + $0 }
                    expect { files.sorted(by: { parser.comparePath($0, $1) }) }.to(equal(expected))
                }
            }
        }
    }
}
