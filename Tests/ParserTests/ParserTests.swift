import SourceKittenFramework
import PathKit
import XCTest
import MirrorDiffKit

@testable import Parser

final class ParserTests: XCTestCase {
    func testDetect() throws {
        let parser = Parser(directoryPath: path)
        try context("detect") {
            try context("yaml") {
                let file = File(path: path + "test.yaml")!
                XCTAssertNotNil(try parser.detectParser(file) as? YamlParser)
            }
            try context("json") {
                let file = File(path: path + "test.json")!
                XCTAssertNotNil(try parser.detectParser(file) as? JSonParser)
            }
            try context("invalid") {
                let file = File(path: path + "test.txt")!
                XCTAssertThrowsError(try parser.detectParser(file)) {
                    if let e = $0 as? ParserError {
                        XCTAssertEqual(e, ParserError.invalidFile(file.path!))
                    } else {
                        XCTFail($0.localizedDescription)
                    }
                }
            }
        }
    }

    func testGetFileList() throws {
        let parser = Parser(directoryPath: path)
        try context("\(path)") {
            try context("environment is nil") {
                try context("detects 6 files") {
                    let files = ["test.yaml", "test.json", "test.txt",
                                 "d1/test.txt", "d2/test.txt", "d2/d1/test.txt"]
                    let expected = files.map { path + $0 }.sorted()
                    let actual = try parser.getFileList(at: path).sorted()
                    XCTAssertEqual(try parser.getFileList(at: path).sorted(), expected, diff(between: expected, and: actual))
                }
            }
            try context("environment is staging") {
                try context("detects 7 files") {
                    let files = ["test.yaml", "test.json", "test.txt",
                                 "d1/test.txt", "d2/test.txt", "d2/d1/test.txt", ".env/staging.json"]
                    let expected = files.map { path + $0 }.sorted()
                    XCTAssertEqual(try parser.getFileList(at: path, environment: "staging").sorted(), expected)
                }
            }
            try context("environment is production") {
                try context("detects 7 files") {
                    let files = ["test.yaml", "test.json", "test.txt",
                                 "d1/test.txt", "d2/test.txt", "d2/d1/test.txt", ".env/production.yaml"]
                    let expected = files.map { path + $0 }.sorted()
                    XCTAssertEqual(try parser.getFileList(at: path, environment: "production").sorted(), expected)
                }
            }
        }
    }

    func testSort() {
        let parser = Parser(directoryPath: path)
        context("sorted") {
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
            XCTAssertEqual(files.sorted(by: { parser.comparePath($0, $1) }), expected)
        }
    }
}
