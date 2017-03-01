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
    public static var altitudeSensitivity: CLLocationDistance = 25

    fileprivate var _indices = [Leg]()

    public var indices: [Leg] {
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
        var legs = [Leg]()
        var leg = Leg(index: 0, point: points[0])

        for i in 0..<points.count {
            defer {
                leg.stat.track(point: points[i], distance: lastPoint?.distance(from: points[i]) ?? 0)
                lastPoint = points[i]
            }
            guard let last = lastPoint else {
                continue
            }
            leg.endIndex = i-1
            leg.endPoint = points[i-1]

            if leg.trendChanged(direction: last.compare(to: points[i])) {
                legs.append(leg)
                leg = Leg(index: i, point: points[i])
            }
        }
        leg.endIndex = points.count - 1
        leg.endPoint = points[points.count-1]
        legs.append(leg)

        legs = removeBetweeners(relatives: collapse(relatives: legs))

        print("Start,End,Direction,Altitude")
        for rPt in legs {
//            print("\(rPt.index),\(rPt.endIndex),\(rPt.direction),\(Int(rPt.altitude))-\(Int(rPt.endPoint!.altitude))")
            print("\(rPt.index), \(rPt.endIndex), \(rPt.direction), \(rPt.stat.string)")
        }

        _indices = legs
    }

}

fileprivate extension Stat {
    
    var string: String {
        return "\(Int(minimumAltitude))-\(Int(maximumAltitude)), \(Int(distance)), \(Int(verticalDelta))"
    }
    
}

// MARK: - Helpers

fileprivate extension GeoTrackAnalyzer {

    func collapse(relatives relativePoints: [Leg]) -> [Leg] {
        var collapsed = [Leg]()
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
            last = last.combine(with: relativePoints[i], direction: last.direction)
        }
        if last != collapsed.last {
            collapsed.append(last)
        }

        return collapsed
    }

    func removeBetweeners(relatives relativePoints: [Leg]) -> [Leg] {
        var collapsed = [Leg]()
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
                last = last.combine(with: relativePoints[i], direction: last.direction)
                continue
            }
            guard abs(relativePoints[i].altitude - last.altitude) > GeoTrackAnalyzer.altitudeSensitivity else {
                last = last.combine(with: relativePoints[i], direction: last.direction)
                continue
            }
            collapsed.append(last)
            last = relativePoints[i]
        }
        if last != collapsed.last {
            collapsed.append(last)
        }

        return collapsed
    }

}

extension Leg {
    
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

    func compare(to point: CLLocation) -> Direction {
        if altitude > point.altitude {
            return .down
        }
        return .up
    }

}
