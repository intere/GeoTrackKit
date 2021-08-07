//
//  GeoTrackManager.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - LocationServicing

public protocol LocationServicing {
    func requestAlwaysAuthorization()
    func requestWhenInUseAuthorization()

    func startUpdatingLocation()
    func stopUpdatingLocation()
}

// MARK: - CLLocationManager: LocationServicing

extension CLLocationManager: LocationServicing { }

// MARK: - GeoTrackManager

/// This class is responsible for managing (and brokering) everything related to tracking for you.
/// ### Sample Usage:
/// ```
/// GeoTrackManager.shared.startTracking(type: .whileInUse)
/// ```
public class GeoTrackManager: NSObject {

    /// The singleton instance (if you want to mock, you can set the shared var to
    /// another GeoTrackService implementation)
    public static var shared: GeoTrackService = GeoTrackManager()

    /// When we startup, if we find points to be older than this threshold, we toss them away.
    /// Defaults to 5 seconds, but you can adjust this as you see fit.
    public static var oldPointTimeThreshold: TimeInterval? = 5

    // MARK: - GeoTrackService Properties

    public var applicationName: String = "No Application Name"

    internal(set) public var trackingState: GeoTrackState = .notTracking

    public var shouldStorePoints = true

    public var pointFilter: PointFilterOptions = .defaultFilterOptions

    /// The last Geo Point to be tracked
    internal(set) public var lastPoint: CLLocation?

    /// Are we authorized for location tracking?
    internal(set) public var authorized: Bool = false

    /// The Track
    internal(set) public var track: GeoTrack?

    public var locationManager: LocationServicing?
}

// MARK: - GeoTrackService Implementation

extension GeoTrackManager: GeoTrackService {

    public var isTracking: Bool {
        return trackingState == .tracking
    }

    public var isAwaitingFix: Bool {
        return trackingState == .awaitingFix
    }

    public func startTracking(type: TrackingType) throws {
        GTInfo(message: "User requested Start Tracking")
        guard trackingState == .notTracking else {
            GTWarn(message: "We're already tracking or awaiting a fix")
            return
        }

        initializeLocationManager()
        try beginLocationUpdates(type: type)
    }

    public func stopTracking() {
        GTInfo(message: "User requested Stop Tracking")

        endLocationUpdates()
        trackingState = .notTracking
    }

    public func reset() {
        lastPoint = nil
        track = nil
        locationManager = nil
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
        locationManager(locationServicing: manager, didChangeAuthorization: status)
    }

    /// Handles location updates.  When the track is updated, it will send out a
    /// notification to NotificationCenter.
    /// See `Notification.Name.GeoTrackKit.didUpdateLocations`
    ///
    /// - Parameters:
    ///   - manager: The source of the event.
    ///   - locations: The location updates that happened.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager(locationServicing: manager, didUpdateLocations: locations)
    }

    /// Handles location tracking pauses
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        locationManagerDidPauseLocationUpdates(locationServicing: manager)
    }

    /// Handles location tracking resuming.
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        locationManagerDidResumeLocationUpdates(locationServicing: manager)
    }

    /// Handles location tracking errors
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager(locationServicing: manager, didFailWithError: error)
    }

    /// Handles deferred update errors.
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        locationManager(locationServicing: manager, didFinishDeferredUpdatesWithError: error)
    }

}

// MARK: - CLLocationManagerDelegate Clone

extension GeoTrackManager {
    /// Handler for location authorization changes.
    ///
    /// - Parameters:
    ///   - manager: The source of the notification.
    ///   - status: The status change.
    public func locationManager(locationServicing manager: LocationServicing,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            GTDebug(message: "Authorization has been updated, starting location updates")
            locationManager?.startUpdatingLocation()
            trackingState = .awaitingFix
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

        @unknown default:
            GTDebug(message: "Unknown status: \(status)")
            authorized = false
            assertionFailure("Unknown status: \(status)")
        }
    }

    // LocationServicing

    /// Handles location updates.  When the track is updated, it will send out a
    /// notification to NotificationCenter.
    /// See `Notification.Name.GeoTrackKit.didUpdateLocations`
    ///
    /// - Parameters:
    ///   - manager: The source of the event.
    ///   - locations: The location updates that happened.
    public func locationManager(locationServicing manager: LocationServicing,
                                didUpdateLocations locations: [CLLocation]) {
        if trackingState == .awaitingFix {
            trackingState = .tracking
        }
        let locations = pointFilter.filter(points: locations, last: lastPoint)

        var recentLocations = [CLLocation]()

        // Ensure that the first point is recent (not old points which we often get when tracking begins):
        if lastPoint == nil {
            locations.forEach { location in
                if let oldPointTimeThreshold = GeoTrackManager.oldPointTimeThreshold {
                    guard abs(location.timestamp.timeIntervalSinceNow) < oldPointTimeThreshold else {
                        return GTDebug(message: "skipping point: \(location)")
                    }
                }
                recentLocations.append(location)
            }
            guard !recentLocations.isEmpty else {
                return
            }
        } else {
            recentLocations = locations
        }

        GTDebug(message: "New Locations: \(recentLocations)")
        guard let location = recentLocations.last else {
            lastPoint = nil
            return
        }
        lastPoint = location

        if shouldStorePoints {
            guard let track = track else {
                GTError(message: "No current track to store points within")
                return
            }
            track.add(locations: recentLocations)
        }
        Notification.GeoTrackManager.didUpdateLocations.notify(withObject: recentLocations)
    }

    /// Handles location tracking pauses
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidPauseLocationUpdates(locationServicing manager: LocationServicing) {
        GTDebug(message: "Paused Location Updates")
        track?.pauseTracking(message: "locationManagerDidPauseLocationUpdates event")
        Notification.GeoTrackManager.didPauseLocationUpdates.notify()
    }

    /// Handles location tracking resuming.
    ///
    /// - Parameter manager: the source of the event.
    public func locationManagerDidResumeLocationUpdates(locationServicing manager: LocationServicing) {
        GTDebug(message: "Resumed Location Updates")
        track?.startTracking(message: "locationManagerDidResumeLocationUpdates event")
        Notification.GeoTrackManager.didResumeLocationUpdates.notify()
    }

    /// Handles location tracking errors
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(locationServicing manager: LocationServicing, didFailWithError error: Error) {
        GTError(message: "Failed to perform location tracking: \(error.localizedDescription), \(error)")
        track?.error(error: error)
        Notification.GeoTrackManager.didFailWithError.notify(withObject: error)
    }

    /// Handles deferred update errors.
    ///
    /// - Parameters:
    ///   - manager: the source of the event.
    ///   - error: the error that occurred.
    public func locationManager(locationServicing manager: LocationServicing,
                                didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            GTError(message: "Failed Deffered Updates: \(error.localizedDescription)")
        }

        if let error = error {
            track?.error(error: error)
        } else {
            track?.error(message: "locationManager:didFinishDeferredUpdatesWithError: nil error")
        }
        Notification.GeoTrackManager.didFinishDeferredUpdatesWithError.notify()
    }
}

// MARK: - Implementation

private extension GeoTrackManager {

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

    /// Handles requesting authorization from location services
    func beginLocationUpdates(type: TrackingType) throws {
        // swiftlint:disable:previous cyclomatic_complexity
        guard let locationManager = locationManager else {
            return
        }

        if track == nil {
            GTDebug(message: "Created new GeoTrack object")
            track = GeoTrack()
        }
        track?.startTracking()

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            trackingState = .awaitingFix

        case .authorizedWhenInUse:
            switch type {
            case .always:
                locationManager.requestAlwaysAuthorization()

            case .whileInUse:
                locationManager.startUpdatingLocation()
                trackingState = .awaitingFix
            }

        case .denied, .restricted:
            throw NotAuthorizedError()

        case .notDetermined:
            switch type {
            case .always:
                locationManager.requestAlwaysAuthorization()

            case .whileInUse:
                locationManager.requestWhenInUseAuthorization()
            }
        @unknown default:
            GTDebug(message: "Unknown authorization status: \(CLLocationManager.authorizationStatus())")
            assertionFailure("Unknown authorization status: \(CLLocationManager.authorizationStatus())")
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

// MARK: - GeoTrackManager Notifications

public extension Notification {

    enum GeoTrackManager: String, Notifiable, CustomStringConvertible {
        case didUpdateLocations
        case didPauseLocationUpdates
        case didResumeLocationUpdates
        case didFailWithError
        case didFinishDeferredUpdatesWithError

        public static var notificationBase: String {
            return "com.geotrackkit.geotrackmanager"
        }

        public var description: String {
            return rawValue
        }
    }
}
