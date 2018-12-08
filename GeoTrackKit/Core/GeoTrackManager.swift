//
//  GeoTrackManager.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import Foundation
import CoreLocation

/// This class is responsible for managing (and brokering) everything related to tracking for you.
/// ### Sample Usage:
/// ```
/// GeoTrackManager.shared.startTracking()
///
/// ```
public class GeoTrackManager: NSObject {
    public static let shared: GeoTrackService = GeoTrackManager()

    // GeoTrackService stuff
    var trackingState: GeoTrackState = .notTracking
    /// Your app's name
    var appName: String = "No Application Name"

    // Other stuff
    var locationManager: CLLocationManager?

    /// The last Geo Point to be tracked
    fileprivate(set) public var lastPoint: CLLocation?

    /// Are we authorized for location tracking?
    fileprivate(set) public var authorized: Bool = false

    /// The Track
    fileprivate(set) public var track: GeoTrack?

    /// When we startup, if we find points to be older than this threshold, we toss them away.
    /// Defaults to 5 seconds, but you can adjust this as you see fit.
    public static var oldPointThreshold: TimeInterval = 5

    /// Sets the locationManager instance and then configures it to the needs
    /// of GeoTrackKit.
    ///
    /// - Parameter locationManager: The locationManager instance to set.
    public func setLocationManager(_ locationManager: CLLocationManager?) {
        self.locationManager = locationManager
        configureLocationManager()
    }
}

// MARK: - API

extension GeoTrackManager: GeoTrackService {

    /// The application name - do we really need this?
    public var applicationName: String {
        get {
            return appName
        }
        set {
            appName = newValue
        }
    }

    /// Are we currently tracking?
    public var isTracking: Bool {
        return trackingState == .tracking
    }

    /// Are we currently getting a location fix?
    public var isAwaitingFix: Bool {
        return trackingState == .awaitingFix
    }

    /// Resets the current track
    public func reset() {
        guard trackingState == .notTracking else {
            assertionFailure("reset() cannot be called when tracking")
            return GTError(message: "reset() cannot be called when tracking")
        }
        lastPoint = nil
        track = nil
    }

    /// Attempts to start tracking (if we're not already).
    public func startTracking() {
        GTInfo(message: "User requested Start Tracking")
        guard trackingState == .notTracking else {
            GTWarn(message: "We're already tracking or awaiting a fix")
            return
        }

        initializeLocationManager()
        beginLocationUpdates()
        trackingState = .awaitingFix
        NotificationCenter.default.post(name: Notification.GeoTrackKit.trackingStarted, object: nil)
    }

    /// Stops tracking
    public func stopTracking() {
        GTInfo(message: "User requested Stop Tracking")

        endLocationUpdates()
        trackingState = .notTracking
        NotificationCenter.default.post(name: Notification.GeoTrackKit.trackingStopped, object: nil)
    }
}

// MARK: - CLLocationManagerDelegate

extension GeoTrackManager: CLLocationManagerDelegate {

    /// Handler for location authorization changes.
    ///
    /// - Parameters:
    ///   - manager: The source of the notification.
    ///   - status: The status change.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            GTDebug(message: "Authorization has been updated, starting location updates")
            locationManager?.startUpdatingLocation()
            authorized = true

        case .denied:
            GTError(message: "User denied location updates")
            track?.error(message: "Location access denied")
            authorized = false

        case .notDetermined:
            GTDebug(message: "Could not determine access to location updates")
            track?.error(message: "Location access not determined")
            authorized = false

        case .restricted:
            GTError(message: "Restricted from access to location updates")
            track?.error(message: "Location access restricted")
            authorized = false
        }
    }

    /// Handles location updates.  When the track is updated, it will send out a
    /// notification to NotificationCenter.
    /// See `Notification.Name.GeoTrackKit.didUpdateLocations`
    ///
    /// - Parameters:
    ///   - manager: The source of the event.
    ///   - locations: The location updates that happened.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if trackingState == .awaitingFix {
            trackingState = .tracking
        }

        var recentLocations = [CLLocation]()

        // Ensure that the first point is recent (not old points which we often get when tracking begins):
        if lastPoint == nil {
            locations.filter({ $0.isAccurateEnough }).forEach { location in
                guard abs(location.timestamp.timeIntervalSinceNow) < GeoTrackManager.oldPointThreshold else {
                    return
                }
                recentLocations.append(location)
            }
            guard !recentLocations.isEmpty else {
                return
            }
        } else {
            recentLocations = locations.filter { $0.isAccurateEnough }
        }

        GTDebug(message: "New Locations: \(recentLocations)")
        guard let location = recentLocations.last else {
            lastPoint = nil
            return
        }
        lastPoint = location

        guard let track = track else {
            GTError(message: "No current track to store points within")
            return
        }
        track.add(locations: recentLocations)
        NotificationCenter.default.post(name: Notification.GeoTrackKit.didUpdateLocations, object: recentLocations)
    }

    /// Handles location tracking pauses
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        GTDebug(message: "Paused Location Updates")
        track?.pauseTracking(message: "locationManagerDidPauseLocationUpdates event")
        NotificationCenter.default.post(name: Notification.GeoTrackKit.didPauseLocationUpdates, object: nil)
    }

    /// Handles location tracking resuming.
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        GTDebug(message: "Resumed Location Updates")
        track?.startTracking(message: "locationManagerDidResumeLocationUpdates event")
        NotificationCenter.default.post(name: Notification.GeoTrackKit.didResumeLocationUpdates, object: nil)
    }

    /// Handles location tracking errors
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        GTError(message: "Failed to perform location tracking: \(error.localizedDescription), \(error)")
        track?.error(error: error)
        NotificationCenter.default.post(name: Notification.GeoTrackKit.didFailWithError, object: error)
    }

    /// Handles deferred update errors.
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            GTError(message: "Failed Deffered Updates: \(error.localizedDescription)")
        }

        if let error = error {
            track?.error(error: error)
        } else {
            track?.error(message: "locationManager:didFinishDeferredUpdatesWithError: nil error")
        }
        NotificationCenter.default.post(name: Notification.GeoTrackKit.didFinishDeferredUpdatesWithError, object: error)
    }

}

// MARK: - Helpers

private extension GeoTrackManager {

    /// Initializes the location manager and sets the preferences
    func initializeLocationManager() {
        guard self.locationManager == nil else {
            return
        }

        let locationManager = CLLocationManager()
        setLocationManager(locationManager)
    }

    /// Configures the locationManager
    func configureLocationManager() {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Until we come up with a heuristic to unpause it
        locationManager.pausesLocationUpdatesAutomatically = false

        // only give us updates when we have 10 meters of change (otherwise we get way too much data)
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
    }

    /// Handles requesting always authorization from location services
    func beginLocationUpdates() {
        guard let locationManager = locationManager else {
            return
        }

        if track == nil {
            GTDebug(message: "Created new GeoTrack object")
            track = GeoTrack()
        }
        track?.startTracking()

        if !authorized {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    /// Handles stopping tracking
    func endLocationUpdates() {
        guard let locationManager = locationManager else {
            return
        }
        track?.stopTracking()
        locationManager.stopUpdatingLocation()
    }

}

// MARK: - CLLocation

extension CLLocation {

    /// Is the accuracy of the point within the acceptable range?
    var isAccurateEnough: Bool {
        return horizontalAccuracy <= 50
    }
}

// MARK: - Notifications

public extension Notification {

    /// GeoTrackKit notification constants
    public struct GeoTrackKit {

        /// Notification that the user has started tracking
        public static let trackingStarted = Notification.Name(rawValue: "com.geotrackkit.user.started.tracking")

        /// Notification that the user has stopped tracking
        public static let trackingStopped = Notification.Name(rawValue: "com.geotrackkit.user.stopped.tracking")

        /// Notofication that the location was updated
        public static let didUpdateLocations = Notification.Name(rawValue: "com.geotrackkit.did.update.locations")

        /// Notification that location updates were paused
        public static let didPauseLocationUpdates = Notification.Name(rawValue: "com.geotrackkit.did.pause.location.updates")

        /// Notification that location updates have been resumed
        public static let didResumeLocationUpdates = Notification.Name(rawValue: "com.geotrackkit.did.resume.location.updates")

        /// Notification that there was a failure tracking location updates
        public static let didFailWithError = Notification.Name(rawValue: "com.geotrackkit.did.fail.with.error")

        /// Notification that deferred updates have failed with an error
        public static let didFinishDeferredUpdatesWithError = Notification.Name(rawValue: "com.geotrackkit.did.finish.deferred.updates.with.error")
    }
}
