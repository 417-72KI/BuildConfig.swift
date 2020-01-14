import XCTest
import Quick

@testable import BuildConfig_swiftTests
@testable import GeneratorTests
@testable import ParserTests

//var tests = [XCTestCaseEntry]()
////tests += BuildConfigswiftTests.allTests
//tests += GeneratorTests.allTests
////tests += DictionaryExtensionTests.allTests
//XCTMain(tests)

Quick.QCKMain([
    GeneratorTests.self,
    DictionaryExtensionTests.self
    ],
testCases: [
    testCase(GeneratorTests.allTests),
    testCase(DictionaryExtensionTests.allTests),
    ]
)
