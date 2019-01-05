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

/// This is the protocol for the GeoTrackService.  It will handle starting and stopping tracking.
public protocol GeoTrackService {

    /// Application name
    var applicationName: String { get set }

    /// Is the service currently tracking?
    var isTracking: Bool { get }

    /// Are we awaiting our fix?
    var isAwaitingFix: Bool { get }

    /// The current track
    var track: GeoTrack? { get }

    /// The most recently tracked point
    var lastPoint: CLLocation? { get }

    /// If we already have the appropriate type of authorization, then begin tracking.  If not
    /// then request authorization and start tracking after we get it.
    ///
    /// - Parameter type: The type of authorization we need for our tracking.
    /// - Throws: A `NotAuthorizedError` if location service access is denied or restricted.
    func startTracking(type: TrackingType) throws

    /// Stops tracking
    func stopTracking()

}

// MARK: - Shared Behavior

public extension GeoTrackService {

    /// Opens the system settings for your app
    func openSettings() {
        guard let systemSettingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(systemSettingsUrl, options: [:], completionHandler: nil)
    }

}

/// This error is raised when you don't have proper authorization
public class NotAuthorizedError: Error {

}
