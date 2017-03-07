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
/// GeoTrackManager.shared.stopTracking()
///
/// ```
public class GeoTrackManager: NSObject {
    public static let shared = GeoTrackManager()

    // GeoTrackService stuff
    internal var trackingState: GeoTrackState = .notTracking
    internal var appName: String = "No Application Name"

    // Other stuff
    internal var locationManager: CLLocationManager?
    fileprivate(set) public var lastPoint: CLLocation?
    fileprivate(set) public var authorized: Bool = false
    fileprivate(set) public var track: GeoTrack?
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
    }

    /// Stops tracking
    public func stopTracking() {
        GTInfo(message: "User requested Stop Tracking")

        endLocationUpdates()
        trackingState = .notTracking
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
        case .authorizedAlways:
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

        default:
            GTError(message: "Other access to location updates (unacceptable)")
            track?.error(message: "Location access not acceptable")
            authorized = false
        }
    }

    /// Handles location updates.
    ///
    /// - Parameters:
    ///   - manager: The source of the event.
    ///   - locations: The location updates that happened.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if trackingState == .awaitingFix {
            trackingState = .tracking
        }
        GTDebug(message: "New Locations: \(locations)")
        guard let location = locations.last else {
            lastPoint = nil
            return
        }
        lastPoint = location

        guard let track = track else {
            GTError(message: "No current track to store points within")
            return
        }
        track.add(locations: locations)
        // TODO(EGI): send out a notification
    }

    /// Handles location tracking pauses
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        GTDebug(message: "Paused Location Updates")
        track?.pauseTracking(message: "locationManagerDidPauseLocationUpdates event")
        // TODO(EGI): send out a notification
    }

    /// Handles location tracking resuming.
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        GTDebug(message: "Resumed Location Updates")
        track?.startTracking(message: "locationManagerDidResumeLocationUpdates event")
        // TODO(EGI): send out a notification
    }

    /// Handles location tracking errors
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        GTError(message: "Failed to perform location tracking: \(error.localizedDescription), \(error)")
        track?.error(error: error)
        // TODO(EGI): send out a notification
    }

    /// Handles deferred update errors.
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        GTError(message: "Failed Deffered Updates: \(error?.localizedDescription), \(error)")
        if let error = error {
            track?.error(error: error)
        } else {
            track?.error(message: "locationManager:didFinishDeferredUpdatesWithError: nil error")
        }
        // TODO(EGI): send out a notification
    }

}

// MARK: - Helpers

fileprivate extension GeoTrackManager {

    /// Initializes the location manager and sets the preferences
    func initializeLocationManager() {
        guard self.locationManager == nil else {
            return
        }

        let locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Until we come up with a heuristic to unpause it
        locationManager.pausesLocationUpdatesAutomatically = false

        // only give us updates when we have 10 meters of change (otherwise we get way too much data)
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self

        self.locationManager = locationManager
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
