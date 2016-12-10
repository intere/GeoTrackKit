//
//  CLLocationExtension.swift
//  Pods
//
//  Created by Eric Internicola on 12/10/16.
//
//

import CoreLocation


public extension CLLocation {

    var string: String {
        let result = "[\(timestamp)][POINT]: \(self)"
        return result
    }

    static func from(map: [String: Any]) -> CLLocation? {
        guard let lat = map["lat"] as? CLLocationDegrees else {
            elog("We didn't get a valid latitude for a point")
            return nil
        }
        guard let lon = map["lon"] as? CLLocationDegrees else {
            elog("We didn't get a valid longitude for a point")
            return nil
        }
        guard let altitude = map["alt"] as? CLLocationDistance else {
            elog("We didn't get a valid altitude for a point")
            return nil
        }
        guard let horizontalAccuracy = map["hAcc"] as? CLLocationAccuracy else {
            elog("We didn't get a valid horizontal accuracy for a point")
            return nil
        }
        guard let verticalAccuracy = map["vAcc"] as? CLLocationAccuracy else {
            elog("We didn't get a valid vertical accuracy for a point")
            return nil
        }
        guard let course = map["course"] as? CLLocationDirection else {
            elog("We didn't get a valid course for a point")
            return nil
        }
        guard let speed = map["speed"] as? CLLocationSpeed else {
            elog("We didn't get a valid speed for a point")
            return nil
        }
        guard let msse = map["timestamp"] as? Double else {
            elog("We didn't get a valid timestamp for a point")
            return nil
        }

        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: Date.from(msse: msse))
        return location
    }

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
