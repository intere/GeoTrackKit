//
//  GeoTrackService.swift
//  GeoTrackKit
//
//  Created by Internicola, Eric on 11/20/16.
//
//

import Foundation
import CoreLocation

/// The type of authorization we want to request if we don't yet have permission:
///
/// - whileInUse: We only want to track when the app is in use.
/// - always: We want to be able to track, even when the app is not in use.
public enum TrackingType {
    case whileInUse
    case always
}

/// This is a callback to let you know that the authorization state has been reached
public typealias GeoTrackAuthCallback = () -> Void

// MARK: - GeoTrackService

/// This is the protocol for the GeoTrackService.  It will handle starting and stopping tracking.
public protocol GeoTrackService {

    /// Application name
    var applicationName: String { get set }

    /// The LocationManager
    var locationManager: LocationServicing? { get set }

    /// Is the service currently tracking?
    var isTracking: Bool { get }

    /// Are we awaiting our fix?
    var isAwaitingFix: Bool { get }

    /// The current track
    var track: GeoTrack? { get }

    /// The most recently tracked point
    var lastPoint: CLLocation? { get }

    /// Should the service collect all of the points, or just ignore them and rebroadcast the events?
    /// If this is set to false, then the track will always be nil.
    var shouldStorePoints: Bool { get set }

    /// How should the service filter location points that come through?
    var pointFilter: PointFilterOptions { get set }

    /// If we already have the appropriate type of authorization, then begin tracking.  If not
    /// then request authorization and start tracking after we get it.
    ///
    /// - Parameter type: The type of authorization we need for our tracking.
    /// - Throws: A `NotAuthorizedError` if location service access is denied or restricted.
    func startTracking(type: TrackingType) throws

    /// Stops tracking
    func stopTracking()

    /// An implementer will nil out the track, nil out the lastPoint and reset everything to the initial state
    func reset()

}

// MARK: - Shared Behavior

public extension GeoTrackService {

    /// Opens the system settings for your app
    func openSettings() {
        guard let systemSettingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if #available(iOS 10, *) {
            UIApplication.shared.open(systemSettingsUrl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(systemSettingsUrl)
        }
    }

}

/// This error is raised when you don't have proper authorization
public class NotAuthorizedError: Error {

}
