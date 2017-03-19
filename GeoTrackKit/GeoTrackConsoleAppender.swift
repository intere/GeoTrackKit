//
//  GeoTrackConsoleAppender.swift
//  Pods
//
//  Created by Internicola, Eric on 12/7/16.
//
//

import Foundation

/// The Console Appender
public class GeoTrackConsoleAppender {

    /// Singelton instance of the Console Appender
    public static let shared = GeoTrackConsoleAppender()

    /// The current log level
    public var logLevel: GeoTrackEvent.Level = .debug

    private init() {}
}

extension GeoTrackConsoleAppender: GeoTrackLogAppender {

    /// The Unique ID of the appender (for comparison)
    public var uniqueId: String {
        return "GeoTrackConsoleAppender"
    }

    /// Handles the logging of an event (prints it to the console in this case).
    ///
    /// - Parameter someEvent: The event to log.
    public func logged(event someEvent: GeoTrackEvent) {
        print(someEvent.string)
    }
}
