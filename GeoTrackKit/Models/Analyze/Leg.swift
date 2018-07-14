//
//  Leg.swift
//  Pods
//
//  Created by Internicola, Eric on 3/1/17.
//
//  Models that are used for Analyzing Tracks
//  TODO(EGI) Document Me!

import CoreLocation

/// This class keeps track of statistics for a Leg (ascent or descent) of a track.
public class Stat {
    /// Minimum altitude in meters
    fileprivate(set) public var minimumAltitude: CLLocationDistance = 0
    /// Maximum altitude in meters
    fileprivate(set) public var maximumAltitude: CLLocationDistance = 0
    /// The distance travelled
    fileprivate(set) public var distance: CLLocationDistance = 0
    /// The maximum recorded speed (in meters per second)
    fileprivate(set) public var maximumSpeed: CLLocationSpeed = 0
    /// What is the change in vertical?
    public var verticalDelta: CLLocationDistance {
        return maximumAltitude - minimumAltitude
    }
    fileprivate var initialized = false
    internal(set) public var direction: Direction = .unknown

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

    /// Combines this stat with another stat (it generally makes sense to do this with another leg that is in the same direction)
    ///
    /// - Parameter stat: The stat to combine with
    func combine(with stat: Stat) {
        distance += stat.distance
        maximumAltitude = max(maximumAltitude, stat.maximumAltitude)
        minimumAltitude = min(minimumAltitude, stat.minimumAltitude)
        maximumSpeed = max(maximumSpeed, stat.maximumSpeed)
        initialized = initialized || stat.initialized
    }
}

/// This class keeps track of statistics for an entire Geo Track.  It summarizes the stats of all of the legs that comprise it and it keeps trak of the number of runs.
public class TrackStat: Stat {
    /// The number of "ski runs" (aka the number of times descended)
    public let runs: Int
    /// The total vertical ascent for the entire track
    public let verticalAscent: CLLocationDistance
    /// The total vertical descent for the entire track
    public let verticalDescent: CLLocationDistance
    /// The total distance covered during ascents for this track
    public let ascentDistance: CLLocationDistance
    /// The total distance covered during descents for this track
    public let descentDistance: CLLocationDistance
    /// The total distance covered for this track
    public let totalDistance: CLLocationDistance

    /// Initialize this TrackStat with the required properties.  Generally you want to create this stat using the `summarize(from legs: [Leg])` factory creation function to create one of these objects.  That function will compute all of the required fields and delegate to this initializer.
    ///
    /// - Parameters:
    ///   - runs: the number of runs for the track
    ///   - ascent: the vertical ascent for the track
    ///   - descent: the vertical descent for this track
    ///   - ascentDistance: the total ascent distance for this track
    ///   - descentDistance: the total descent distance for this track
    ///   - totalDistance: the total distance for this track
    init(runs: Int, ascent: CLLocationDistance, descent: CLLocationDistance, ascentDistance: CLLocationDistance, descentDistance: CLLocationDistance, totalDistance: CLLocationDistance) {
        self.runs = runs
        verticalAscent = ascent
        verticalDescent = descent
        self.ascentDistance = ascentDistance
        self.descentDistance = descentDistance
        self.totalDistance = totalDistance
    }

    /// Using the provided array of Legs, this function will compute the track summary stats and provide you with a a summary TrackStat for the entire track.
    ///
    /// - Parameter legs: The legs to summarize
    /// - Returns: A TrackStat that contains the results of the overall stats for the track.
    public static func summarize(from legs: [Leg]) -> TrackStat {
        let baseOverallStat = Stat()
        var runs = 0
        var vAscent: CLLocationDistance = 0
        var vDescent: CLLocationDistance = 0
        var aDistance: CLLocationDistance = 0
        var dDistance: CLLocationDistance = 0
        var tDistance: CLLocationDistance = 0

        for leg in legs {
            let stat = leg.stat
            baseOverallStat.combine(with: stat)
            if leg.direction == .upward {
                vAscent += stat.verticalDelta
                aDistance += stat.distance
            } else if leg.direction == .downward {
                vDescent -= stat.verticalDelta
                dDistance += stat.distance
                runs += 1
            }
            tDistance += stat.distance
        }

        let stat = TrackStat(runs: runs, ascent: vAscent, descent: vDescent, ascentDistance: aDistance, descentDistance: dDistance, totalDistance: tDistance)
        stat.combine(with: baseOverallStat)
        return stat
    }
}

/// The direction that we're going
///
/// - unknown: Unknown direction (e.g. the first point
/// - upward: The upward direction
/// - downward: The downward direction
public enum Direction: String {
    /// Unknown direction
    case unknown

    /// Upward direction (ascent)
    case upward

    /// Downward direction (descent)
    case downward
}

/// A relative minima or maxima
public class Leg {

    /// The starting index of the leg
    public let index: Int
    /// The starting point of the leg
    public let point: CLLocation
    /// The overridden direction of the leg
    private var _direction: Direction = .unknown

    /// The direction of this leg (see Direction)
    public var direction: Direction {
        set {
            _direction = newValue
        }
        get {
            if Int(altitudeChange) == 0 {
                return .unknown
            } else if Int(altitudeChange) > 0 {
                return .upward
            }
            return .downward
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

    /// Initializes the Leg with an index, point, direction, endIndex and endPoint
    ///
    /// - Parameters:
    ///   - index: The index of the first point in the Track Points
    ///   - point: The first point
    ///   - direction: The direction we're headed: ascent vs. descent (see Direction)
    ///   - endIndex: The index of the last point in the Track Points
    ///   - endPoint: The end point
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
            return point.compare(to: anotherPoint)
    }

    /// Tells you if this leg is moving in the same direction as another leg
    ///
    /// - Parameter anotherLeg: The leg to compare with.
    /// - Returns: true if the directions are the same, false if not
    func isSameDirection(as anotherLeg: Leg) -> Bool {
        return direction == anotherLeg.direction
    }

    /// Is this leg between the two provided legs?
    ///
    /// - Parameters:
    ///   - left: The prior leg
    ///   - right: The next leg
    /// - Returns: True if our altitude is between the altitude on the left and right
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

    /// Tells us if two legs are "the same".  They are the same if their indices, altitude and direction are the same.
    ///
    /// - Parameters:
    ///   - lhs: The first Leg to compare
    ///   - rhs: The second leg to compare
    /// - Returns: True if the two legs seem to be the same, false if not.
    public static func == (lhs: Leg, rhs: Leg) -> Bool {
        guard lhs.index == rhs.index, Int(lhs.altitude) == Int(rhs.altitude), lhs.direction == rhs.direction, lhs.endIndex == rhs.endIndex else {
            return false
        }
        return true
    }
}
