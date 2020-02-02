//
//  Logging.swift
//  WatchExample Extension
//
//  Created by Eric Internicola on 2/2/20.
//  Copyright © 2020 Eric Internicola. All rights reserved.
//

import Foundation

func ELog(_ msg: @autoclosure () -> String, _ file: String = #file, _ line: Int = #line) {
    let fileString = file as NSString
    let fileLastPathComponent = fileString.lastPathComponent as NSString
    let filename = fileLastPathComponent.deletingPathExtension
    NSLog("ERROR: [%@:%d] %@\n", filename, line, msg())
}

func DLog(_ msg: @autoclosure () -> String, _ file: String = #file, _ line: Int = #line) {
    let fileString = file as NSString
    let fileLastPathComponent = fileString.lastPathComponent as NSString
    let filename = fileLastPathComponent.deletingPathExtension
    NSLog("[%@:%d] %@\n", filename, line, msg())
}

// swiftlint:disable:next identifier_name
func Trace(_ msg: @autoclosure () -> String, _ file: String = #file, _ line: Int = #line) {

    #warning("Need a mechanism to disable tracing")
//    guard AppConfig.showTraces else {
//        return
//    }

    let fileString = file as NSString
    let fileLastPathComponent = fileString.lastPathComponent as NSString
    let filename = fileLastPathComponent.deletingPathExtension
    NSLog("[%@:%d] %@\n", filename, line, msg())
}

extension Error {

    var logMessage: String {
        return localizedDescription
    }

    /// Error logs the provided message along with the localizedDescription for this error.
    /// - Parameter message: The message to accompany this error.
    func elog(_ message: String) {
        ELog("\(message): \(logMessage)")
    }
}
