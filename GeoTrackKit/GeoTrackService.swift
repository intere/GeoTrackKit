//
//  GeoTrackService.swift
//  Pods
//
//  Created by Internicola, Eric on 11/20/16.
//
//

import Foundation
import CoreLocation


/// This is a callback to let you know that the authorization state has been reached
public typealias GeoTrackAuthCallback = () -> ()


/// This is the protocol for the GeoTrackService.  It will handle starting and stopping tracking.
public protocol GeoTrackService {

    /** Application Name.  */
    var applicationName: String { get set }

    /** Is the service currently tracking?  */
    var isTracking: Bool { get }

    /** Starts tracking.  */
    func startTracking()

    /** Stops tracking.  */
    func stopTracking()
    
}
