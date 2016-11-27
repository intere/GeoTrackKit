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
    }

    /// Adds a Stop Tracking event to the track's event log.
    ///
    /// - Parameter message: Optional message that can be included with the event.
    func stopTracking(message: String? = nil) {
        let event = GeoTrackLocationEvent.stoppedTracking(message: message)
    }


}

// MARK: - Serialization

public extension GeoTrack {

}
