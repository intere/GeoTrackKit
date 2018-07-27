//
//  GeoTrackState.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/25/16.
//
//

import Foundation


/// The states we keep track of for Geo Tracking
///
/// - unknown: We have no idea what's going on with tracking, hopefully we are never in this state!
/// - awaitingFix: We've requested tracking, but we're awaiting a GPS fix.
/// - tracking: We are currently tracking.
/// - notTracking: We are not tracking
public enum GeoTrackState: Int {
    /// Unknown tracking state
    case unknown
    /// Awaiting a location fix
    case awaitingFix
    /// Currently tracking
    case tracking
    /// Not currently tracking
    case notTracking
}
