//
//  CoreLocationExtension.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 1/4/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import CoreLocation

// MARK: - Unit Conversions

extension CLLocationSpeed {

    /// Converts "meters per second" to "miles per hour".
    var metersPerSecondToMilesPerHour: Double {
        return self * 2.23694
    }

    /// Converts "meters per second" to "kilometers per hour"
    var metersPerSecondToKilometersPerHour: Double {
        return self * 3.6
    }
}

extension CLLocationDistance {

    /// Converts meters to feet
    var metersToFeet: Double {
        return self * 3.28084
    }

    /// Converts meters to miles.
    var metersToMiles: Double {
        return self * 0.000621371
    }

}
