import Darwin
import Foundation

public func dumpInfo(_ message: @autoclosure () -> String) {
    fputs("\(tag) \(message())\n", stdout)
}

public func dumpError(_ message: @autoclosure () -> String) {
    fputs("error: \(tag) \(message())\n", stderr)
}

public func dumpError(_ error: @autoclosure () -> Error) {
    dumpError("\(error())")
}

public func dumpWarn(_ message: @autoclosure () -> String) {
    fputs("warning: \(tag) \(message())\n", stderr)
}

private var tag: String {
    "[\(ApplicationInfo.name)(\(ApplicationInfo.version))]"
}
