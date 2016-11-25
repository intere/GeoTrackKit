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

    public var isTracking: Bool {
        return trackingState == .tracking
    }

    public func startTracking() {
        // TODO
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
        // TODO
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

        case .denied:
            GTError(message: "User denied location updates")

        case .notDetermined:
            GTDebug(message: "Could not determine access to location updates")

        case .restricted:
            GTError(message: "Restricted from access to location updates")

        default:
            GTError(message: "Other access to location updates (unacceptable)")

        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if trackingState == .awaitingFix {
            trackingState = .tracking
        }
        guard let location = locations.first else {
            return
        }
        GTDebug(message: "New Location: \(location)")
    }

    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // TODO: Implement me
        GTDebug(message: "Paused Location Updates")
    }

    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // TODO: Implement me
        GTDebug(message: "Resumed Location Updates")
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Impelement me
        GTError(message: "Failed to perform location tracking: \(error.localizedDescription), \(error)")
    }

    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // TODO: Implement me
        GTError(message: "Failed Deffered Updates: \(error?.localizedDescription), \(error)")
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

        locationManager.requestAlwaysAuthorization()
    }

    func endLocationUpdates() {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.stopUpdatingLocation()
    }
    
}
