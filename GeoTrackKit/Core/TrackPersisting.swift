//
//  TrackPersisting.swift
//  Pods
//
//  Created by Eric Internicola on 2/1/20.
//

import CoreLocation

// MARK: - TrackPersisting

/// Handles the persistence of a track
public protocol TrackPersisting {

    /// Gets the current track
    var track: GeoTrack? { get }

    /// Gets the last point
    var lastPoint: CLLocation? { get }

    /// Kicks off the tracking on the track
    func startTracking()

    /// Adds the provided points to the persistence manager.
    /// - Parameter locations: The location points to be added
    func addPoints(_ locations: [CLLocation])

    /// Resets the track and all of the points
    func reset()

}

// MARK: - NoTrackPersisting

/// Does not persist any track data, only keeps track of the most recent track point.  Only use this if
/// You plan on listening for `Notification.GeoTrackManager.didUpdateLocations` to collect the points yourself
public class NoTrackPersisting: TrackPersisting {

    public var track: GeoTrack? { return nil }

    public private(set) var lastPoint: CLLocation?

    public func startTracking() { }

    public func addPoints(_ locations: [CLLocation]) {
        lastPoint = locations.last
    }

    public func reset() {
        lastPoint = nil
    }

}

// MARK: - InMemoryTrackPersisting

/// Keeps a Track in memory with all of the points.  This can get large if you have enough points
public class InMemoryTrackPersisting: TrackPersisting {

    private(set) public var track: GeoTrack?

    public var lastPoint: CLLocation? {
        return track?.points.last
    }

    public func startTracking() {
        guard track == nil else {
            return assertionFailure("startTracking should only be called once")
        }
        track = GeoTrack()
        track?.startTracking()
    }

    public func addPoints(_ locations: [CLLocation]) {
        if let track = track {
            track.add(locations: locations)
        } else {
            track = GeoTrack(points: locations)
        }
    }

    public func reset() {
        track = nil
    }

}
