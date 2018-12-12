//
//  CLLocationExtension.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 12/10/16.
//
//  A set of convenience extensions to provide a friendly string value and then serialization functions

import CoreLocation

public extension CLLocation {

    var string: String {
        let result = "[\(timestamp)][POINT]: \(self)"
        return result
    }

}

// MARK: - x / y

public extension CLLocationCoordinate2D {

    /// Converts the longitutude from this point to mercator x value.
    var mercatorX: CLLocationDistance {
        return longitude.radians * Constants.earthRadius
    }

    /// Converts the latitude from this point to a mercator y value.
    var mercatorY: CLLocationDistance {
        return log(tan(.pi / 4 + latitude.radians / 2)) * Constants.earthRadius
    }

    /// Gets you the mercator point for this coordinate.
    var mercatorPoint: CGPoint {
        return CGPoint(x: mercatorX, y: mercatorY)
    }

    /// Converts this to a lat / lon point (where it's x = longitude, y = latitude).
    var latLonPoint: CGPoint {
        return CGPoint(x: longitude, y: latitude)
    }

    private struct Constants {
        static let earthRadius = 6378137.0
    }
}

// MARK: - Serialization

public extension CLLocation {

    /// Attempts to re-constitute a CLLocation object from a map.  Deserialization.
    ///
    /// - Parameter map: the map to attempt to create the location from.
    /// - Returns: A CLLocation object if it could be created, nil if not.
    static func from(map: [String: Any]) -> CLLocation? {
        guard let lat = map["lat"] as? CLLocationDegrees
            ?? map["latitude"] as? CLLocationDegrees else {
            elog("We didn't get a valid latitude for a point")
            return nil
        }
        guard let lon = map["lon"] as? CLLocationDegrees
            ?? map["longitude"] as? CLLocationDegrees else {
            elog("We didn't get a valid longitude for a point")
            return nil
        }
        guard let altitude = map["alt"] as? CLLocationDistance
            ?? map["altitude"] as? CLLocationDistance else {
            elog("We didn't get a valid altitude for a point")
            return nil
        }
        guard let horizontalAccuracy = map["hAcc"] as? CLLocationAccuracy
            ?? map["horizontalAccuracy"] as? CLLocationAccuracy else {
            elog("We didn't get a valid horizontal accuracy for a point")
            return nil
        }
        guard let verticalAccuracy = map["vAcc"] as? CLLocationAccuracy
            ?? map["verticalAccuracy"] as? CLLocationAccuracy else {
            elog("We didn't get a valid vertical accuracy for a point")
            return nil
        }
        guard let speed = map["speed"] as? CLLocationSpeed else {
            elog("We didn't get a valid speed for a point")
            return nil
        }
        guard let msse = map["timestamp"] as? Double
            ?? map["time"] as? Double else {
            elog("We didn't get a valid timestamp for a point")
            return nil
        }

        let course = map["course"] as? CLLocationDirection ?? 0

        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: Date.from(msse: msse))
        return location
    }

    /// Converts this CLLocation object to a Map (for serialization).  Please note: we use MSSE (Milliseconds Since the Epoch) format for the date.
    var map: [String: Any] {
        return [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude,
            "alt": altitude,
            "hAcc": horizontalAccuracy,
            "vAcc": verticalAccuracy,
            "speed": speed,
            "course": course,
            "timestamp": timestamp.msse
        ]
    }

}
