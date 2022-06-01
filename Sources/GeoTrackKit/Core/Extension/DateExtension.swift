//
//  DateExtension.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 12/10/16.
//
//

import Foundation

public extension Date {

    /// Gives you the MSSE (Milliseconds Since the Epoch) representation of this date
    var msse: Double {
        return timeIntervalSince1970 * 1000
    }

    /// Converts this date to an iso8601 string.
    ///
    /// The format looks something like this:
    /// ```text
    /// 2019-01-06T13:00:51Z
    /// ```
    var iso8601Date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        return formatter.string(from: self)
    }

    /// Gets you a Date from the provided MSSE (Milliseconds Since the Epoch)
    ///
    /// - Parameter msse: the number of milliseconds since the epoch (as a double)
    /// - Returns: A date that represents the date you provided
    static func from(msse: Double) -> Date {
        let timeInterval = TimeInterval(msse / 1000)
        return Date(timeIntervalSince1970: timeInterval)
    }
}
