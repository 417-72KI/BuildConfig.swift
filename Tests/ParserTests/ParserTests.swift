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
                let file = File(path: path + "ignored.txt")!
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
                    let expected = (
                        base: ["test.yaml", "test.json"],
                        env: [] as [String]
                    )
                    let actual = try parser.getFileList(at: path)
                    context("base") {
                        let expected = expected.base
                            .map(path.appending(_:))
                            .sorted()
                        let actual = actual.base
                            .compactMap(\.path)
                            .compactMap(Path.init(_:))
                            .sorted()
                        XCTAssertEqual(expected, actual, diff(between: expected.map(\.lastComponent), and: actual.map(\.lastComponent)))
                    }
                    context("env") {
                        let expected = expected.env
                            .map(path.appending(_:))
                            .sorted()
                        let actual = actual.env
                            .compactMap(\.path)
                            .compactMap(Path.init(_:))
                            .sorted()
                        XCTAssertEqual(expected, actual, diff(between: expected.map(\.lastComponent), and: actual.map(\.lastComponent)))
                    }
                }
            }
            try context("environment is staging") {
                try context("detects 7 files") {
                    let expected = (
                        base: ["test.yaml", "test.json"],
                        env: ["staging/test.json"]
                    )
                    let actual = try parser.getFileList(at: path,
                                                        environment: "staging")
                    context("base") {
                        let expected = expected.base
                            .map(path.appending(_:))
                            .sorted()
                        let actual = actual.base
                            .compactMap(\.path)
                            .compactMap(Path.init(_:))
                            .sorted()
                        XCTAssertEqual(expected, actual, diff(between: expected.map(\.lastComponent), and: actual.map(\.lastComponent)))
                    }
                    context("env") {
                        let expected = expected.env
                            .map(path.appending(_:))
                            .sorted()
                        let actual = actual.env
                            .compactMap(\.path)
                            .compactMap(Path.init(_:))
                            .sorted()
                        XCTAssertEqual(expected, actual, diff(between: expected.map(\.lastComponent), and: actual.map(\.lastComponent)))
                    }
                }
            }
            try context("environment is production") {
                try context("detects 7 files") {
                    let expected = (
                        base: ["test.yaml", "test.json"],
                        env: ["production/test.yaml"]
                    )
                    let actual = try parser.getFileList(at: path,
                                                        environment: "production")
                    context("base") {
                        let expected = expected.base
                            .map(path.appending(_:))
                            .sorted()
                        let actual = actual.base
                            .compactMap(\.path)
                            .compactMap(Path.init(_:))
                            .sorted()
                        XCTAssertEqual(expected, actual, diff(between: expected.map(\.lastComponent), and: actual.map(\.lastComponent)))
                    }
                    context("env") {
                        let expected = expected.env
                            .map(path.appending(_:))
                            .sorted()
                        let actual = actual.env
                            .compactMap(\.path)
                            .compactMap(Path.init(_:))
                            .sorted()
                        XCTAssertEqual(expected, actual, diff(between: expected.map(\.lastComponent), and: actual.map(\.lastComponent)))
                    }
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
