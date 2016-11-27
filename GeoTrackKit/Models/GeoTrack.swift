//
//  GeoTrack.swift
//  Pods
//
//  Created by Eric Internicola on 11/27/16.
//
//

import CoreLocation


public class GeoTrack {
    internal var _points = [CLLocation]()
    internal var _events = [GeoTrackLocationEvent]()
    var name = ""
    var description = ""
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

    /// Adds a Start Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    func startTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.startedTracking(message: message)
        _events.append(event)
    }

    /// Adds a Pause Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    func pauseTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.pausedTracking(message: message)
        _events.append(event)
    }

    /// Adds a Stop Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    func stopTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.stoppedTracking(message: message)
        _events.append(event)
    }

    /// Adds a custom error message to the track's event log.
    ///
    /// - Parameter message: The error message you want to display
    func error(message: String) {
        let event = GeoTrackLocationEvent.custom(message: message)
        _events.append(event)
    }

    /// Adds an error to the track's event log
    ///
    /// - Parameter error: The swift Error type to log the message for.
    func error(error: Error) {
        let event = GeoTrackLocationEvent.error(error: error)
        _events.append(event)
    }

}

// MARK: - Serialization

public extension GeoTrack {

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

// MARK: - CLLocation Helpers

fileprivate extension CLLocation {
    var string: String {
        let result = "[\(timestamp)][POINT]: \(self)"
        return result
    }
}
