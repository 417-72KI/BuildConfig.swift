import Darwin
import Foundation

public func dumpInfo(_ message: @autoclosure () -> String) {
    fputs("\(tag)[Info] \(message())\n", stdout)
}

public func dumpError(_ message: @autoclosure () -> String) {
    fputs("\(tag)[Error] \(message())\n", stderr)
}

public func dumpError(_ error: @autoclosure () -> Error) {
    dumpError("\(error())")
}

public func dumpWarn(_ message: @autoclosure () -> String) {
    fputs("\(tag)[Warning] \(message())\n", stderr)
}

public func dumpWarn(_ error: @autoclosure () -> Error) {
    dumpWarn("\(error())")
}

private var tag: String {
    "[\(ApplicationInfo.name)(\(ApplicationInfo.version))] "
}
