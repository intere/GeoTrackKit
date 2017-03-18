//
//  GeoTrackEvent.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import Foundation

/// This class is used to track a GeoTrackEvent (for logging purposes).
public class GeoTrackEvent {

    /// The Logging Level
    public enum Level: Int {
        case trace = 1
        case debug
        case info
        case warn
        case error

        var name: String {
            switch self {
            case .trace:
                return "TRACE"
            case .debug:
                return "DEBUG"
            case .info:
                return "INFO"
            case .warn:
                return "WARN"
            case .error:
                return "ERROR"
            }
        }
    }

    public private(set) var level: Level = .info
    public private(set) var date: Date = Date()
    public private(set) var message: String = ""

    public init(level: Level, message: String) {
        self.level = level
        self.message = message
    }

    public init(level: Level, date: Date, message: String) {
        self.level = level
        self.date = date
        self.message = message
    }

    var string: String {
        return "\(date) [" + level.name + "]: " + message
    }
}

// MARK: - factory creation functions

public extension GeoTrackEvent {

    /// Log at the tracing level (potentially very chatty).
    ///
    /// - Parameter message: the message to be logged
    /// - Returns: The GeoTrackEvent
    static func trace(message: String) -> GeoTrackEvent {
        return GeoTrackEvent(level: .trace, message: message)
    }

    /// Log at the debug level (could be quite chatty).
    ///
    /// - Parameter message: The message to be logged
    /// - Returns: The GeoTrackEvent
    static func debug(message: String) -> GeoTrackEvent {
        return GeoTrackEvent(level: .debug, message: message)
    }

    /// Log at the info level (should not be very chatty)
    ///
    /// - Parameter message: The message to be logged
    /// - Returns: The GeoTrackEvent
    static func info(message: String) -> GeoTrackEvent {
        return GeoTrackEvent(level: .info, message: message)
    }

    /// Log at the warn level (should not happen very often)
    ///
    /// - Parameter message: The message to be logged
    /// - Returns: The GeoTrackEvent
    static func warn(message: String) -> GeoTrackEvent {
        return GeoTrackEvent(level: .warn, message: message)
    }

    /// Log at the error level (this should not happen very often at all)
    ///
    /// - Parameter message: The message to be logged
    /// - Returns: The GeoTrackEvent
    static func error(message: String) -> GeoTrackEvent {
        return GeoTrackEvent(level: .error, message: message)
    }

}
