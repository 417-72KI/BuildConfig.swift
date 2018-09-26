import XCTest

import ConfigurationPlistTests

var tests = [XCTestCaseEntry]()
tests += ConfigurationPlistTests.allTests()
XCTMain(tests)