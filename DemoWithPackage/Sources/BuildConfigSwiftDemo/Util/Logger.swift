//
//  Logger.swift
//  BuildConfigSwiftDemo
//
//  Created by 417.72KI on 2019/05/09.
//  Copyright © 2019 417.72KI. All rights reserved.
//

import Foundation
import XCGLogger

let log = XCGLogger()

func setupLog(isDebugMode: Bool) {
    if isDebugMode {
        log.setup(
            level: .debug,
            showLogIdentifier: true,
            showFunctionName: true,
            showThreadName: true,
            showLevel: true,
            showFileNames: true,
            showLineNumbers: true,
            showDate: true,
            writeToFile: nil,
            fileLevel: nil
        )
    } else {
        log.setup(
            level: .info,
            showLogIdentifier: false,
            showFunctionName: false,
            showThreadName: false,
            showLevel: true,
            showFileNames: false,
            showLineNumbers: false,
            showDate: true,
            writeToFile: nil,
            fileLevel: nil
        )
    }
}
