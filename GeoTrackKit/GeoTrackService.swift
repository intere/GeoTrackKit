//
//  GeoTrackService.swift
//  Pods
//
//  Created by Internicola, Eric on 11/20/16.
//
//

import Foundation
import CoreLocation

public typealias GeoTrackAuthCallback = () -> ()

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
