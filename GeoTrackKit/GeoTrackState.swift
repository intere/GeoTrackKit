//
//  GeoTrackState.swift
//  Pods
//
//  Created by Eric Internicola on 11/25/16.
//
//

import Foundation


public enum GeoTrackState: Int {
    case unknown
    case awaitingFix
    case tracking
    case notTracking
}
