//
//  GeoTrackAnalyzer.swift
//  Pods
//
//  Created by Eric Internicola on 2/26/17.
//
//

import CoreLocation

/// This class is used to generate statistics about your track.  Please note, this is a trivial implementation for ascent / descent detection.  This implementation does not (currently) do any sort of noise reduction or utilize the vertical accuracy of the data to remove potentially erronious points.  It might make sense (down the roade) to abstract a protocol from this and have multiple implementations to choose from that perform noise reduction or some sort of statistical smoothing to clean up the data for accuracy.
public class GeoTrackAnalyzer {

    /// The sensitivity of the "track" detection (in meters).  If you set this too high, it won't detect "runs" properly, if you set it too low, it will detect more "runs" than you actually have done
    public static var altitudeSensitivity: CLLocationDistance = 25

    /// The track that we're calculating the statistics from
    public let track: GeoTrack

    /// The statistics for the track
    public var stats: TrackStat?

    /// The [mutable] legs of the track (ascents and descents)
    fileprivate(set) public var legs = [Leg]()

    /// Initializes this Track Analyzer with a track.  You must still call `calculate()` to generate the statistics.  This isn't done on construction for performance reasons.
    ///
    /// - Parameter track: The track to initialize with
    public init(track: GeoTrack) {
        self.track = track
    }

}

// MARK: - API

public extension GeoTrackAnalyzer {

    /// Calculates the statistics from the data set.  It will populate the legs and the stats.
    func calculate() {
        let points = track.points
        guard points.count > 0 else {
            GTWarn(message: "No points to calculate statistics from")
            return
        }

        var direction = Direction.unknown
        var lastPoint: CLLocation?
        var legs = [Leg]()
        var leg = Leg(index: 0, point: points[0])

        for index in 0..<points.count {
            defer {
                leg.stat.track(point: points[index], distance: lastPoint?.distance(from: points[index]) ?? 0)
                lastPoint = points[index]
            }
            guard let last = lastPoint else {
                continue
            }
            leg.endIndex = index-1
            leg.endPoint = points[index-1]

            if leg.trendChanged(direction: last.compare(to: points[index])) {
                legs.append(leg)
                leg = Leg(index: index, point: points[index])
            }
        }
        leg.endIndex = points.count - 1
        leg.endPoint = points[points.count-1]
        legs.append(leg)

        legs = collapse(relatives: legs)

        print("Start,End,Direction,Altitude")
        for rPt in legs {
            print("\(rPt.index), \(rPt.endIndex), \(rPt.direction), \(rPt.stat.string)")
        }

        self.legs = legs
        self.stats = TrackStat.summarize(from: legs)
    }

}

// MARK: - Stat extensions

fileprivate extension Stat {

    /// String implementation for Stat (for debugging)
    var string: String {
        return "\(Int(minimumAltitude))-\(Int(maximumAltitude)), \(Int(distance)), \(Int(verticalDelta))"
    }

}

// MARK: - Helpers

fileprivate extension GeoTrackAnalyzer {

    /// Collapses the legs down when there are multiple segments in the same direction (the first pass of track analyzation generally will create multiple legs that are in the same direction).  Yes, it's an imperfect algorithm due to imperfect data.  This function will collapse the legs down by combining adjacent legs that are in the same direction.
    ///
    /// - Parameter relativePoints: The relative minima and maxima that have been detected, but need to be collapsed when there are multiple adjacent legs that are moving in the same direction.
    /// - Returns: a new set of legs that represents a reduced set of legs, such that there are no longer adjacent legs moving in the same direction.
    func collapse(relatives relativePoints: [Leg]) -> [Leg] {
        var collapsed = [Leg]()

        // if there are no legs, just return
        guard relativePoints.count > 0 else {
            return collapsed
        }

        var last = relativePoints[0]
        for index in 1..<relativePoints.count {
            guard last.isSameDirection(as: relativePoints[index]) else {
                // if the legs are not moving in the same direction, then just add the current leg to the collapsed list and move onto the next one
                collapsed.append(last)
                last = relativePoints[index]
                continue
            }

            // if the 2 legs are moving in the same direction, then combine them and set the last to be the combination of the last and the current and then move on to the next.
            last = last.combine(with: relativePoints[index], direction: last.direction)
        }

        // If we haven't added the last one to the collapsed list yet, then do it now:
        if last != collapsed.last {
            collapsed.append(last)
        }

        return collapsed
    }

}

extension Leg {

    /// This function is responsible for combining the current leg with another leg (into a new Leg), setting the direction and returning that result.
    ///
    /// - Parameters:
    ///   - anotherLeg: the leg to combine with
    ///   - direction: the direction to set on the resulting leg
    /// - Returns: A new leg that is the result of combining this leg with another leg
    func combine(with anotherLeg: Leg, direction: Direction) -> Leg {
        let leg: Leg
        if index < anotherLeg.index {
            leg = Leg(index: index, point: point, direction: direction, endIndex: anotherLeg.endIndex, endPoint: anotherLeg.endPoint)

        } else {
            leg = Leg(index: anotherLeg.index, point: anotherLeg.point, direction: direction, endIndex: endIndex, endPoint: endPoint)
        }
        leg.stat = stat
        stat.combine(with: anotherLeg.stat)

        return leg
    }

}
extension CLLocation {

    /// Tells you if this point is above, below or at the same altitude as another point
    ///
    /// - Parameter point: The point to compare this point with
    /// - Returns: `unknown` if the altitude is the same (very, very unlikely), `down` if the provided point is below this point and `up` if the provided point is above this point.
    func compare(to point: CLLocation) -> Direction {
        if altitude == point.altitude {
            return .unknown
        } else if altitude > point.altitude {
            return .downward
        }
        return .upward
    }

}
