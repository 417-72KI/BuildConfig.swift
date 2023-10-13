#!/usr/bin/env swift

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func lint() throws -> [String] {
    let process = Process()
    let stdout = Pipe()
    let stderr = Pipe()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["swift", "run", "swiftlint", "lint", "--path", "."]
    process.standardOutput = stdout
    process.standardError = stderr
    try process.run()
    process.waitUntilExit()
    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else { return [] }
    return output.split(separator: "\n").map(String.init)
}

let result = try lint()
let regex = #/^.*\((?<rule>.*)\)$/#
let rules = result.lazy
    .compactMap { $0.wholeMatch(of: regex) }
    .map { String($0.rule) }
    .reduce(into: [:]) { $0[$1, default: 0] += 1 }
    .lazy
    .map { (rule: $0, count: $1) }
    .sorted { $0.count > $1.count }
rules.forEach { print("\u{001B}[0;31m\($0.count): \($0.rule)\u{001B}[0;0m") }
