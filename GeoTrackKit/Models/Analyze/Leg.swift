//
//  Leg.swift
//  Pods
//
//  Created by Internicola, Eric on 3/1/17.
//
//

import CoreLocation

public class Stat {
    /// Minimum altitude in meters
    private(set) public var minimumAltitude: CLLocationDistance = 0
    /// Maximum altitude in meters
    private(set) public var maximumAltitude: CLLocationDistance = 0
    /// The distance travelled
    private(set) public var distance: CLLocationDistance = 0
    /// The maximum recorded speed (in meters per second)
    private(set) public var maximumSpeed: CLLocationSpeed = 0
    /// What is the change in vertical?
    public var verticalDelta: CLLocationDistance {
        return maximumAltitude - minimumAltitude
    }
    fileprivate var initialized = false
    
    /// Updates the stats using the provided point
    ///
    /// - Parameter point: The point to track
    func track(point: CLLocation, distance: CLLocationDistance) {
        guard initialized else {
            minimumAltitude = point.altitude
            maximumAltitude = point.altitude
            self.distance += distance
            maximumSpeed = point.speed
            initialized = true
            return
        }
        self.distance += distance
        maximumAltitude = max(maximumAltitude, point.altitude)
        minimumAltitude = min(minimumAltitude, point.altitude)
        maximumSpeed = max(maximumSpeed, point.speed)
    }
    
    
    func combine(with stat: Stat) {
        distance += stat.distance
        maximumAltitude = max(maximumAltitude, stat.maximumAltitude)
        minimumAltitude = min(minimumAltitude, stat.minimumAltitude)
        maximumSpeed = max(maximumSpeed, stat.maximumSpeed)
        initialized = initialized || stat.initialized
    }
}

public class TrackStat: Stat {
    /// The number of "ski runs" (aka the number of times descended)
    let runs: Int = 0
}

/// The direction that we're going
///
/// - unknown: Unknown direction (e.g. the first point
/// - up: The upward direction
/// - down: The downward direction
public enum Direction: String {
    case unknown
    case up
    case down
}

/// A relative minima or maxima
public class Leg {

    /// The starting index of the leg
    public let index: Int
    /// The starting point of the leg
    public let point: CLLocation
    /// The overridden direction of the leg
    private var _direction: Direction = .unknown
    public var direction: Direction {
        set {
            _direction = newValue
        }
        get {
            if Int(altitudeChange) == 0 {
                return .unknown
            } else if Int(altitudeChange) > 0 {
                return .up
            }
            return .down
        }
    }
    /// The ending index of the leg
    public var endIndex: Int
    /// The ending point of the leg
    public var endPoint: CLLocation?
    /// The current stats for the leg
    public var stat = Stat()

    /// The Altitude at the referred to point
    public var altitude: CLLocationDistance {
        return point.altitude
    }

    /// The calculated change in altitude between the start and end point
    public var altitudeChange: CLLocationDistance {
        guard let endPoint = endPoint else {
            return 0
        }
        return endPoint.altitude - point.altitude
    }

    public init(index: Int, point: CLLocation, direction: Direction = .unknown, endIndex: Int = -1, endPoint: CLLocation? = nil) {
        self.index = index
        self.point = point
        _direction = direction
        self.endIndex = endIndex
        self.endPoint = endPoint
    }

    /// Tells you if the trending direction has changed compared to the current direction.  This function does have side effects (if the current direction is "unknown", it will change to whatever the provided direction is).
    ///
    /// - Parameter point: The point to inspect
    /// - Returns: true if the trend has changed from up to down or down to up.
    func trendChanged(direction: Direction) -> Bool {
        guard self.direction != .unknown else {
            self.direction = direction
            return false
        }
        guard abs(self.altitudeChange) > GeoTrackAnalyzer.altitudeSensitivity else {
            return false
        }

        return direction != self.direction
    }

    /// Compares the current relative point to the provided point to tell you the direction.
    ///
    /// - Parameter point: The point to compare with this relative point.
    /// - Returns: the direction
    func compare(to anotherPoint: CLLocation) -> Direction {
//        guard abs(altitude - point.altitude) > 25 else {
//            return .unknown
//        }
        return point.compare(to: anotherPoint)
    }

    /// Tells you if this relative should be combined with another relative
    ///
    /// - Parameter anotherLeg: the leg to compare with for combination.
    /// - Returns: true if they should be combined, false if not.
    func shouldCombine(with anotherLeg: Leg) -> Bool {
        return direction == anotherLeg.direction
    }

    func isBetween(left: Leg, right: Leg) -> Bool {
        if left.altitude <= altitude && altitude <= right.altitude {
            return true
        }
        if left.altitude >= altitude && altitude >= right.altitude {
            return true
        }
        return false
    }
}

// MARK: - Equatable

extension Leg: Equatable {

    public static func ==(lhs: Leg, rhs: Leg) -> Bool {
        guard lhs.index == rhs.index, Int(lhs.altitude) == Int(rhs.altitude), lhs.direction == rhs.direction, lhs.endIndex == rhs.endIndex else {
            return false
        }
        return true
    }
}
