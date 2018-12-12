//
//  GeoTrackService.swift
//  GeoTrackKit
//
//  Created by Internicola, Eric on 11/20/16.
//
//

import Foundation
import CoreLocation


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

    /// Starts tracking
    func startTracking()

    /// Stops tracking
    func stopTracking()

}
