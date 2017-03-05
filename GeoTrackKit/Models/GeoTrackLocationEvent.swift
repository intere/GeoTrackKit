//
//  GeoTrackLocationEvent.swift
//  Pods
//
//  Created by Eric Internicola on 11/27/16.
//
//

import CoreLocation

/**
 This class is responsible for keeping track of different types of track events.  For example when the user starts tracking, stops tracking, pauses tracking, and your own custom event types.
 */
public class GeoTrackLocationEvent {
    public enum EventType: Int {
        case startedTrack = 1
        case pausedTrack = 2
        case stoppedTrack = 3
        case error = 4
        case custom = 5
        case other = 6

        var string: String {
            switch self {
            case .startedTrack:
                return "Started Track"
            case .pausedTrack:
                return "Paused Track"
            case .stoppedTrack:
                return "Stopped Track"
            case .error:
                return "Error"
            case .custom:
                return "Custom"
            case .other:
                return "Other"
            }
        }
    }

    private(set) public var type: EventType = .other
    private(set) public var timestamp: Date = Date()
    private(set) public var message: String? = nil
    private(set) public var index: Int? = nil

    internal init(type: EventType, timestamp: Date? = nil, message: String? = nil, index: Int? = nil) {
        self.type = type
        if let timestamp = timestamp {
            self.timestamp = timestamp
        }
        self.message = message
        self.index = index
    }
}

// MARK: - API

public extension GeoTrackLocationEvent {

//    var type: EventType {
//        return iType
//    }
//
//    var timestamp: Date {
//        return iTimestamp
//    }
//
//    var message: String? {
//        return iMessage
//    }
//
//    var index: Int? {
//        return iIndex
//    }

    var string: String {
        var result = "[\(timestamp)] [\(type.string.uppercased())]"
        if let index = index {
            result += "[index=\(index)]"
        }
        if let message = message {
            result += " " + message
        }
        return result
    }

}

// MARK: - API (Factory Creation)

public extension GeoTrackLocationEvent {

    /// Creates you a GeoTrackLocationEvent of type startedTrack
    ///
    /// - Parameter message: optional message to accompany the Location Event.
    /// - Returns: The GeoTrackLocationEvent
    static func startedTracking(message: String? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .startedTrack, message: message)
        return event
    }

    /// Creates you a GeoTrackLocationEvent of type pausedTrack
    ///
    /// - Parameter message: optional message to accompany the Location Event.
    /// - Returns: The GeoTrackLocationEvent
    static func pausedTracking(message: String? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .pausedTrack, message: message)
        return event
    }

    /// Creates you a GeoTrackLocationEvent of type stoppedTrack
    ///
    /// - Parameter message: optional message to accompany the Location Event.
    /// - Returns: The GeoTrackLocationEvent
    static func stoppedTracking(message: String? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .stoppedTrack, message: message)
        return event
    }

    /// Creates you a GeoTrackLocationEvent of type error
    ///
    /// - Parameters:
    ///   - error: The Error object you want to associate with the track.
    ///   - index: the index of the point you want to associate with the error.
    ///   - date: The timestamp you want to set for the error (nil = current date and time).
    /// - Returns: The GeoTrackLocationEvent
    static func error(error: Error, at index: Int? = nil, timestamp date: Date? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .error, timestamp: date, message: error.localizedDescription, index: index)
        return event
    }

    /// Creates you a GeoTrackLocationEvent of type error
    ///
    /// - Parameters:
    ///   - error: The NSError object you want to associate with the track.
    ///   - index: the index of the point you want to associate with the error.
    ///   - date: The timestamp you want to set for the error (nil = current date and time).
    /// - Returns: The GeoTrackLocationEvent
    static func error(error: NSError, at index: Int? = nil, timestamp date: Date? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .error, timestamp: date, message: error.localizedDescription, index: index)
        return event
    }

    /// Creates you a GeoTrackLocationEvent of type error
    ///
    /// - Parameters:
    ///   - message: The custom error message you want to associate with the track.
    ///   - index: the index of the point you want to associate with the error.
    ///   - date: The timestamp you want to set for the error (nil = current date and time).
    /// - Returns: The GeoTrackLocationEvent
    static func error(message: String, at index: Int? = nil, timestamp date: Date? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .error, timestamp: date, message: message, index: index)
        return event
    }

    /// Creates you a custom GeoTrackLocationEvent.  You should make sure to provide either an index, a date, or both for context.
    ///
    /// - Parameters:
    ///   - message: The message to include with this track.
    ///   - index: The index that you want to associate this custom Event with.
    ///   - date: The date that you want to set for this custom message (nil = current date and time)
    /// - Returns: The GeoTrackLocationEvent
    static func custom(message: String, at index: Int? = nil, timestamp date: Date? = nil) -> GeoTrackLocationEvent {
        let event = GeoTrackLocationEvent(type: .custom, timestamp: date, message: message, index: index)
        return event
    }

}

// MARK: - API (Serialization / Deserialization)

public extension GeoTrackLocationEvent {

    fileprivate struct Constants {
        static let type = "type"
        static let timestamp = "timestamp"
        static let message = "message"
        static let index = "index"
    }


    /// Deserializes the provided map into a GeoTrackLocationEvent.
    ///
    /// - Parameter map: the map to be deserialized.
    /// - Returns: A GeoTrackLocationEvent if it could be deserialized or nil.
    static func from(map: [String: Any]) -> GeoTrackLocationEvent? {
        guard let rawType = map[Constants.type] as? Int,
            let type = EventType(rawValue: rawType),
            let msse = map[Constants.timestamp] as? TimeInterval else
        {
            return nil
        }
        let message = map[Constants.message] as? String
        let index = map[Constants.index] as? Int
        let timestamp = Date.from(msse: msse)

        let event = GeoTrackLocationEvent(type: type, timestamp: timestamp, message: message, index: index)
        return event
    }


    /// Serializes this GeoTrackLocationEvent into a map for serialization purposes.
    ///
    /// - Returns: A map of [String: Any]
    var map: [String: Any] {
        var dict: [String: Any] = [
            Constants.type: type.rawValue,
            Constants.timestamp: timestamp.msse
        ]
        if let message = message {
            dict[Constants.message] = message
        }
        if let index = index {
            dict[Constants.index] = index
        }

        return dict
    }
}
