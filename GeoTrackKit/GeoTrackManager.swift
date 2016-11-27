//
//  GeoTrackManager.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import Foundation
import CoreLocation

public class GeoTrackManager: NSObject {
    public static let shared = GeoTrackManager()

    // GeoTrackService stuff
    internal var trackingState: GeoTrackState = .notTracking
    internal var appName: String = "No Application Name"

    // Other stuff
    internal var locationManager: CLLocationManager?
    internal var _lastPoint: CLLocation?
    internal var _authorized: Bool = false

    internal var _track: GeoTrack?
}

// MARK: - API

extension GeoTrackManager: GeoTrackService {

    public var applicationName: String {
        get {
            return appName
        }
        set {
            appName = newValue
        }
    }

    /// Gives you the current track
    public var track: GeoTrack? {
        return _track
    }

    /// Gives you the last received location point
    public var lastPoint: CLLocation? {
        return _lastPoint
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

    public func stopTracking() {
        GTInfo(message: "User requested Stop Tracking")

        endLocationUpdates()
        trackingState = .notTracking
    }
}

extension GeoTrackManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .authorizedAlways:
            GTDebug(message: "Authorization has been updated, starting location updates")
            locationManager?.startUpdatingLocation()
            _authorized = true

        case .denied:
            GTError(message: "User denied location updates")
            _track?.error(message: "Location access denied")
            _authorized = false

        case .notDetermined:
            GTDebug(message: "Could not determine access to location updates")
            _track?.error(message: "Location access not determined")
            _authorized = false

        case .restricted:
            GTError(message: "Restricted from access to location updates")
            _track?.error(message: "Location access restricted")
            _authorized = false

        default:
            GTError(message: "Other access to location updates (unacceptable)")
            _track?.error(message: "Location access not acceptable")
            _authorized = false
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if trackingState == .awaitingFix {
            trackingState = .tracking
        }
        GTDebug(message: "New Locations: \(locations)")
        guard let location = locations.last else {
            _lastPoint = nil
            return
        }
        _lastPoint = location

        guard let track = _track else {
            GTError(message: "No current track to store points within")
            return
        }
        track.add(locations: locations)
    }

    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // TODO: Implement me
        GTDebug(message: "Paused Location Updates")
        track?.pauseTracking(message: "locationManagerDidPauseLocationUpdates event")
    }

    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // TODO: Implement me
        GTDebug(message: "Resumed Location Updates")
        track?.startTracking(message: "locationManagerDidResumeLocationUpdates event")
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Impelement me
        GTError(message: "Failed to perform location tracking: \(error.localizedDescription), \(error)")
        _track?.error(error: error)
    }

    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // TODO: Implement me
        GTError(message: "Failed Deffered Updates: \(error?.localizedDescription), \(error)")
        if let error = error {
            _track?.error(error: error)
        } else {
            _track?.error(message: "locationManager:didFinishDeferredUpdatesWithError: nil error")
        }
    }

}

// MARK: - Helpers

fileprivate extension GeoTrackManager {

    func initializeLocationManager() {
        guard self.locationManager == nil else {
            return
        }

        let locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Until we come up with a heuristic to unpause it
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        // only give us updates when we have 10 meters of change
        locationManager.distanceFilter = 10
        locationManager.delegate = self

        self.locationManager = locationManager
    }

    func beginLocationUpdates() {
        guard let locationManager = locationManager else {
            return
        }

        if _track == nil {
            GTDebug(message: "Created new GeoTrack object")
            _track = GeoTrack()
        }
        _track?.startTracking()

        if !_authorized {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    func endLocationUpdates() {
        guard let locationManager = locationManager else {
            return
        }
        _track?.stopTracking()
        locationManager.stopUpdatingLocation()
    }
    
}
