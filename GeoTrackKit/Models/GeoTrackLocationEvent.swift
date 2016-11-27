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
    }

    var _type: EventType = .other
    var _timestamp: Date = Date()
    var _message: String? = nil
    var _index: Int? = nil

    internal init(type: EventType, timestamp: Date? = nil, message: String? = nil, index: Int? = nil) {
        _type = type
        if let timestamp = timestamp {
            _timestamp = timestamp
        }
        _message = message
        _index = index
    }
}

// MARK: - API

public extension GeoTrackLocationEvent {

    var type: EventType {
        return _type
    }

    var timestamp: Date {
        return _timestamp
    }

    var message: String? {
        return _message
    }

    var index: Int? {
        return _index
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
    static func custom(message: String, at index: Int? = nil, timestamp date: Date?) -> GeoTrackLocationEvent {
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

    static func from(dictionary: [String: Any]) -> GeoTrackLocationEvent? {
        guard let rawType = dictionary[Constants.type] as? Int,
            let type = EventType(rawValue: rawType),
            let timestamp = dictionary[Constants.timestamp] as? Date else
        {
            return nil
        }
        let message = dictionary[Constants.message] as? String
        let index = dictionary[Constants.index] as? Int

        let event = GeoTrackLocationEvent(type: type, timestamp: timestamp, message: message, index: index)
        return event
    }


    /// Serializes this GeoTrackLocationEvent into a Dictionary for serialization purposes.
    ///
    /// - Returns: A hash of [String: Any]
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            Constants.type: _type.rawValue,
            Constants.timestamp: _timestamp
        ]
        if let message = _message {
            dict[Constants.message] = message
        }
        if let index = _index {
            dict[Constants.index] = index
        }

        return dict
    }
}
