//
//  GeoTrack.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/27/16.
//
//

import CoreLocation


/// Data structure to keep track of points for a track
public class GeoTrack {

    /// The internal list of points
    fileprivate var iPoints = [CLLocation]()
    /// The Track Events that have occured that are related to this track
    fileprivate(set) public var events = [GeoTrackLocationEvent]()
    /// The track name (defaults to an empty string)
    public var name = ""
    /// A description for the track
    public var description = ""

    /// Default initializer, defaults all properties
    public init() { }

    /// Initializer that sets the name and description for the track
    ///
    /// - Parameters:
    ///   - name: The name
    ///   - description: The description
    public init(name: String? = nil, description: String? = nil) {
        self.name = name ?? ""
        self.description = description ?? ""
    }

    /// Initializer that will deserialize the provided json into CLLocation objects.  This is essentially the deserializer
    ///
    /// - Parameter json: The JSON to create a GeoTrack from
    public init(json: [String: Any]) {
        parse(json)
    }

    /// Create a GeoTrack from an array of `CLLocation` points and an optional name and description.
    ///
    /// - Parameters:
    ///   - points: The points to initialize this GeoTrack with.
    ///   - name: The name for the track (defaults to empty string)
    ///   - description: A description for the track (defaults to empty string).
    public init(points: [CLLocation], name: String = "", description: String = "") {
        self.iPoints = points
        self.name = name
        self.description = description
    }
}

// MARK: - API(Points)

public extension GeoTrack {

    /// Get the points in the Track
    var points: [CLLocation] {
        return iPoints.sorted { return $0.timestamp.timeIntervalSince1970 < $1.timestamp.timeIntervalSince1970 }
    }

    /// Adds a location to the track
    ///
    /// - Parameter location: The location point to add
    func add(location: CLLocation) {
        iPoints.append(location)
    }

    /// Adds an array of locations to the track
    ///
    /// - Parameter locations: The array of location points to add
    func add(locations: [CLLocation]) {
        iPoints.append(contentsOf: locations)
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
        events.append(event)
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

    /// Converts this Grack to a Map so you can serialize it
    public var map: [String: Any] {
        return [
            "name": name,
            "description": description,
            "points": points.map { $0.map },
            "events": events.map { $0.map }
        ]
    }

    /// Deserializes this track from a Map, or if there's a problem, it will return you nil.
    ///
    /// - Parameter map: The map that you want to deserialize into a GeoTrack.
    /// - Returns: A GeoTrack if it could be deserialized.
    static func fromMap(map: [String: Any]) -> GeoTrack? {
        let name = map["name"] as? String ?? ""
        let description = map["description"] as? String ?? ""
        guard let pointMaps = map["points"] as? [[String: Any]] else {
            elog("No points in the track")
            return nil
        }
        guard let eventMaps = map["events"] as? [[String: Any]] else {
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
            track.add(location: location)
        }
        for map in eventMaps {
            guard let event = GeoTrackLocationEvent.from(map: map) else {
                continue
            }
            track.events.append(event)
        }

        return track
    }
}

// MARK: - Helpers

fileprivate extension GeoTrack {

    struct PropertyKeys {
        static let name = "name"
        static let description = "description"
        static let points = "points"
        static let events = "events"
    }

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

    /// Parses the provided map to build out this data structure.
    ///
    /// - Parameter json: the JSON map to parse.
    func parse(_ json: [String: Any]) {
        self.name = json[PropertyKeys.name] as? String ?? ""
        self.description = json[PropertyKeys.description] as? String ?? ""
        guard let points = json[PropertyKeys.points] as? [[String: Any]] else {
            return
        }

        for pointMap in points {
            guard let location = CLLocation.from(map: pointMap) else {
                GTWarn(message: "Failed to deserialize a point from the map")
                continue
            }
            iPoints.append(location)
        }

        guard json[PropertyKeys.events] as? [[String: Any]] != nil else {
            return
        }

        // TODO(EGI): re-construct the events
    }

    func buildEventLog(showPoints: Bool) -> [String] {
        var events = self.events.map { Log(event: $0) }

        if showPoints {
            events.append(contentsOf: points.map({ Log(location: $0) }))
        }

        let sorted = events.sorted { $0.date<$1.date }

        return sorted.map { $0.message }
    }
}

func elog(_ message: String) {
    print("[\(Date())]: \(message)")
}
