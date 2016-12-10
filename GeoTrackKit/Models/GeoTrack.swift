//
//  GeoTrack.swift
//  Pods
//
//  Created by Eric Internicola on 11/27/16.
//
//

import CoreLocation


/// Data structure to keep track of points for a track
public class GeoTrack {
    internal var _points = [CLLocation]()
    internal var _events = [GeoTrackLocationEvent]()
    public var name = ""
    public var description = ""

    public init() { }

    public init(name: String? = nil, description: String? = nil) {
        self.name = name ?? ""
        self.description = description ?? ""
    }
}

// MARK: - API(Points)

public extension GeoTrack {

    /// Get the points in the Track
    var points: [CLLocation] {
        return _points
    }

    /// Adds a location to the track
    ///
    /// - Parameter location: The location point to add
    func add(location: CLLocation) {
        _points.append(location)
    }

    /// Adds an array of locations to the track
    ///
    /// - Parameter locations: The array of location points to add
    func add(locations: [CLLocation]) {
        _points.append(contentsOf: locations)
    }


    /// Gets you the event log, and will include the points if you want them.
    ///
    /// - Parameter showPoints: Whether or not to include the points in the event log.
    /// - Returns: A list of strings that is the event log.
    func log(withPoints showPoints: Bool) -> [String] {
        return buildEventLog(showPoints: showPoints)
    }

}

// MARK: - API(Events)

public extension GeoTrack {


    /// Lets you add a custom event.
    ///
    /// - Parameter event: The event to add to the event log.
    public func add(event: GeoTrackLocationEvent) {
        _events.append(event)
    }

    /// Adds a Start Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    public func startTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.startedTracking(message: message)
        add(event: event)
    }

    /// Adds a Pause Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    public func pauseTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.pausedTracking(message: message)
        add(event: event)
    }

    /// Adds a Stop Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    public func stopTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.stoppedTracking(message: message)
        add(event: event)
    }

    /// Adds a custom error message to the track's event log.
    ///
    /// - Parameter message: The error message you want to display
    public func error(message: String) {
        let event = GeoTrackLocationEvent.error(message: message)
        add(event: event)
    }

    /// Adds an error to the track's event log
    ///
    /// - Parameter error: The swift Error type to log the message for.
    public func error(error: Error) {
        let event = GeoTrackLocationEvent.error(error: error)
        add(event: event)
    }

}

// MARK: - Serialization

public extension GeoTrack {

    var map: [String: Any] {
        return [
            "name": name,
            "description": description,
            "points": points.map { $0.map },
            "events": _events.map { $0.map }
        ]
    }

    /// Deserializes this track from a Map, or if there's a problem, it will return you nil.
    ///
    /// - Parameter map: The map that you want to deserialize into a GeoTrack.
    /// - Returns: A GeoTrack if it could be deserialized.
    static func fromMap(map: [String: Any]) -> GeoTrack? {
        let name = map["name"] as? String ?? ""
        let description = map["description"] as? String ?? ""
        guard let pointMaps = map["points"] as? [[String:Any]] else {
            elog("No points in the track")
            return nil
        }
        guard let eventMaps = map["events"] as? [[String:Any]] else {
            elog("No events in the track")
            return nil
        }

        let track = GeoTrack()
        track.name = name
        track.description = description
        for map in pointMaps {
            guard let location = CLLocation.from(map: map) else {
                continue
            }
            track._points.append(location)
        }
        for map in eventMaps {
            guard let event = GeoTrackLocationEvent.from(map: map) else {
                continue
            }
            track._events.append(event)
        }

        return track
    }
}

// MARK: - Helpers

fileprivate extension GeoTrack {
    struct Log {
        let date: Date
        let message: String

        init(location: CLLocation) {
            date = location.timestamp
            message = location.string
        }

        init(event: GeoTrackLocationEvent) {
            date = event.timestamp
            message = event.string
        }
    }

    func buildEventLog(showPoints: Bool) -> [String] {
        var events = _events.map { Log(event:$0) }

        if showPoints {
            events.append(contentsOf: _points.map({ Log(location: $0) }))
        }

        let sorted = events.sorted { $0.date<$1.date }

        return sorted.map { $0.message }
    }
}

func elog(_ message: String) {
    print("[\(Date())]: \(message)")
}
