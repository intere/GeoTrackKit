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

    struct Constants {
        static let earthRadius = 6_378_137.0
    }
}

// MARK: - Bearing / Slope between points

public extension CLLocation {

    convenience init(x: Int, y: Int, altitude: CLLocationDistance = 0) {
        // swiftlint:disable:previous identifier_name
        let lon = (Double(x) / CLLocationCoordinate2D.Constants.earthRadius).radiansToDegrees
        let lat = ((2.0 * atan(exp(Double(y)/CLLocationCoordinate2D.Constants.earthRadius))) - .pi/2).radiansToDegrees

        self.init(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date())
    }

    /// Computes the bearing between two points (in degrees).
    ///
    /// - Parameter anotherPoint: the point you want to compute the bearing between.
    /// - Returns: The bearing between this poiont and the other point (in degrees).
    func bearing(between anotherPoint: CLLocation) -> CLLocationDegrees {
        let lat1 = coordinate.latitude.degreesToRadians
        let lon1 = coordinate.longitude.degreesToRadians

        let lat2 = anotherPoint.coordinate.latitude.degreesToRadians
        let lon2 = anotherPoint.coordinate.longitude.degreesToRadians

        let dLon = lon2 - lon1

        let yMeasure = sin(dLon) * cos(lat2)
        let xMeasure = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        return atan2(yMeasure, xMeasure).radiansToDegrees
    }

    /// Computes the slope between the elevation of another point (in degrees).
    ///
    /// - Parameter anotherPoint: The point to compute the slope between.
    /// - Returns: The sloope between this point and the provided point (in degrees).
    func slope(between anotherPoint: CLLocation) -> CLLocationDegrees {
        let distance = self.distance(from: anotherPoint)
        let altitudeDiff = altitude - anotherPoint.altitude
        let slope = atan(altitudeDiff / distance)

        return slope.radiansToDegrees
    }


}

public extension CGPoint {

    /// Converts the mercator-y from this point to latitude
    var latitude: CLLocationDistance {
        return ((2 * atan(exp(y.double / CLLocationCoordinate2D.Constants.earthRadius))) - .pi / 2).radiansToDegrees
    }

    /// Converts the mercator-x from this point to longitude
    var longitude: CLLocationDistance {
        return (x.double / CLLocationCoordinate2D.Constants.earthRadius).radiansToDegrees
    }

    var latLonLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}

public extension CGFloat {

    var double: Double {
        return Double(self)
    }
}

public extension Double {

    /// Assumes this number is in degrees and converts it to radians
    var degreesToRadians: Double {
        return self * .pi / 180
    }

    /// Assumes this number is in radians and converts it to degrees
    var radiansToDegrees: Double {
        return self * 180 / .pi
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
