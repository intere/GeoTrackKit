//
//  GeoTrackAnalyzer.swift
//  Pods
//
//  Created by Eric Internicola on 2/26/17.
//
//

import CoreLocation

public class GeoTrackAnalyzer {

    public let track: GeoTrack
    fileprivate var _indices = [Relative]()
    public var indices: [Relative] {
        return _indices
    }

    public init(track: GeoTrack) {
        self.track = track
    }

}

// MARK: - API

public extension GeoTrackAnalyzer {

    /// Calculates the statistics from the data set
    func calculate() {
        let points = track.points
        guard points.count > 0 else {
            // TODO(EGI): Log a warning or something
            return
        }

        var direction = Direction.unknown
        var lastPoint: CLLocation?
        var relativePoints = [Relative]()
        var relative = Relative(index: 0, point: points[0], direction: .unknown, endIndex: -1)

        for i in 0..<points.count {
            defer {
                lastPoint = points[i]
            }
            guard let last = lastPoint else {
                continue
            }

            if relative.shouldRecord(direction: last.compare(to: points[i])) {
                relative.endIndex = i-1
                relativePoints.append(relative)
                relative = Relative(index: i, point: points[i], direction: .unknown, endIndex: -1)
            }
        }
        relative.endIndex = points.count - 1
        relativePoints.append(relative)

//        relativePoints = collapse(relatives: removeBetweeners(relatives: relativePoints))
        relativePoints = collapse(relatives: removeBetweeners(relatives: collapse(relatives: relativePoints)))

        print("Start,End,Direction,Altitude")
        for rPt in relativePoints {
            print("\(rPt.index),\(rPt.endIndex),\(rPt.direction),\(rPt.altitude)")
        }

        _indices = relativePoints
    }

    public struct Stats {
        /// Minimum altitude in meters
        let minimumAltitude: CLLocationDistance
        /// Maximum altitude in meters
        let maximumAltitude: CLLocationDistance
        /// The number of "ski runs" (aka the number of times descended)
        let runs: Int
    }

    /// A relative minima or maxima
    public struct Relative {
        let index: Int
        let point: CLLocation
        var direction: Direction = .unknown
        var endIndex: Int

        /// The Altitude at the referred to point
        var altitude: CLLocationDistance {
            return point.altitude
        }

        /// Tells you if we should record this Relative reference based on the point to be analyzed
        ///
        /// - Parameter point: The point to inspect
        /// - Returns: true if we should record this point
        mutating func shouldRecord(direction: Direction) -> Bool {
            guard self.direction != .unknown else {
                self.direction = direction
                return false
            }

            return direction != self.direction
        }

        /// Compares the current relative point to the provided point to tell you the direction.
        ///
        /// - Parameter point: The point to compare with this relative point.
        /// - Returns: the direction
        func compare(to anotherPoint: CLLocation) -> Direction {
            guard abs(altitude - point.altitude) > 25 else {
                return .unknown
            }
            return point.compare(to: anotherPoint)
        }

        /// Tells you if this relative should be combined with another relative
        ///
        /// - Parameter anotherRelative: the relative to compare with for combination.
        /// - Returns: true if they should be combined, false if not.
        func shouldCombine(with anotherRelative: Relative) -> Bool {
            return direction == anotherRelative.direction
        }

        func isBetween(left: Relative, right: Relative) -> Bool {
            if left.altitude <= altitude && altitude <= right.altitude {
                return true
            }
            if left.altitude >= altitude && altitude >= right.altitude {
                return true
            }
            return false
        }
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

}

// MARK: - Helpers

fileprivate extension GeoTrackAnalyzer {

    func collapse(relatives relativePoints: [Relative]) -> [Relative] {
        var collapsed = [Relative]()
        guard relativePoints.count > 0 else {
            return collapsed
        }

        var last = relativePoints[0]
        for i in 0..<relativePoints.count {
            guard last.shouldCombine(with: relativePoints[i]) else {
                collapsed.append(last)
                last = relativePoints[i]
                continue
            }
            last.endIndex = relativePoints[i].endIndex
        }

        return collapsed
    }

    func removeBetweeners(relatives relativePoints: [Relative]) -> [Relative] {
        var collapsed = [Relative]()
        guard relativePoints.count > 0 else {
            return collapsed
        }

        var last = relativePoints[0]
        for i in 0..<relativePoints.count {
            guard i < relativePoints.count - 1 else {
                collapsed.append(last)
                last = relativePoints[i]
                continue
            }
            guard !relativePoints[i].isBetween(left: last, right: relativePoints[i+1]) else {
                last.endIndex = relativePoints[i].endIndex
                continue
            }
            guard abs(relativePoints[i].altitude - last.altitude) > 10 else {
                last.endIndex = relativePoints[i].endIndex
                continue
            }
            collapsed.append(last)
            last = relativePoints[i]
        }

        return collapsed
    }

}

fileprivate extension CLLocation {

    func compare(to point: CLLocation) -> GeoTrackAnalyzer.Direction {
        if altitude > point.altitude {
            return .down
        }
        return .up
    }

}
