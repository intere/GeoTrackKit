//
//  DateExtension.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 12/10/16.
//
//

import Foundation

public extension Date {

    /// Gets you a Date from the provided MSSE (Milliseconds Since the Epoch)
    ///
    /// - Parameter msse: the number of milliseconds since the epoch (as a double)
    /// - Returns: A date that represents the date you provided
    static func from(msse: Double) -> Date {
        let timeInterval = TimeInterval(msse / 1000)
        return Date(timeIntervalSince1970: timeInterval)
    }

    /// Gives you the MSSE (Milliseconds Since the Epoch) representation of this date
    var msse: Double {
        return timeIntervalSince1970 * 1000
    }

}
