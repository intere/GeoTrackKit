//
//  ConsoleLogAppender.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 7/21/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import Foundation
import GeoTrackKit

/// An Appender that just logs to the console
class ConsoleLogAppender: GeoTrackLogAppender {

    /// The shared instance
    static let shared = ConsoleLogAppender()

    var uniqueId: String {
        return "ConsoleLogAppender"
    }

    var logLevel = GeoTrackEvent.Level.debug

    func logged(event: GeoTrackEvent) {
        DLog(event.string)
    }

}
