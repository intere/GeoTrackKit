//
//  GeoTrack+Utilities.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/9/18.
//

import CoreLocation
import MapKit

public extension GeoTrack {

    /// Gets you a mercator MBR
    var mbrMercator: CGRect {
        return buildMbr()
    }

    /// Tells you if this track intersects with the provided track.
    ///
    /// - Parameters:
    ///   - track: The track to check for intersection.
    ///   - distance: The distance threshold in meters (defaults to two (2) meters)
    /// - Returns: True if this track intersects with the other, false if not.
    func intersects(another track: GeoTrack, threshold distance: CLLocationDistance = 2) -> Bool {
        guard mbrMercator.intersects(track.mbrMercator) else {
            // If the bounding boxes of the two tracks don't intersect:
            // Then they don't intersect.
            return false
        }

        // Now, to figure out if the tracks intersect at all.
        for myPoint in points {
            for theirPoint in track.points where myPoint.distance(from: theirPoint) < distance {
                return true
            }
        }

        return false
    }

    /// Tells you if this track butts up against another track.  Note: This only
    /// checks the first and last points of the two tracks
    ///
    /// - Parameters:
    ///   - another: The track to check a connection with.
    ///   - distance: The distance threshold in meters (defaults to 5 meters)
    /// - Returns: True if the ends of the two trails connect, false if not.
    func endsAdjacent(with another: GeoTrack, threshold distance: CLLocationDistance = 5) -> Bool {
        guard let firstPoint = points.first, let lastPoint = points.last,
            let anotherFirst = another.points.first, let anotherLast = another.points.last else {
                return false
        }

        if firstPoint.distance(from: anotherFirst) <= distance ||
            firstPoint.distance(from: anotherLast) <= distance {
            return true
        }
        if lastPoint.distance(from: anotherFirst) <= distance ||
            lastPoint.distance(from: anotherLast) <= distance {
            return true
        }

        return false
    }

}

// MARK: - Throwaway

public extension GeoTrack {

    // TODO: probably throw this away
    /// Gets you a (mercator-based) path for this track.
    var path: CGPath? {
        guard points.count > 1 else {
            return nil
        }

        let mutablePath = CGMutablePath()
        // Doesn't seem to work

        var last: CGPoint?
        for point in points {
            defer {
                last = point.coordinate.latLonPoint
            }
            guard let last = last else {
                continue
            }
            mutablePath.addLines(between: [last, point.coordinate.latLonPoint])
        }

        return mutablePath
    }

    /// Creates a polygon from the track that expands the line by the `size` meters you provide.
    /// - Parameter meters: The distance to expand outwards.
    func toPolygonPointArray(size meters: CLLocationDistance) -> [CLLocation]? {
        guard points.count > 2 else {
            return nil
        }

        var result = [CLLocation]()
        var bottomResult = [CLLocation]()

        for idx in 1..<points.count {
            let last = points[idx - 1]
            let point = points[idx]

            helpPolygonArrayMethod1(meters: meters, last: last, point: point) { (direction, resultPoint, bottomResultPoint) in
                if idx == 1 {
                    computeEdgePoints(meters: meters, direction: direction, point: last) { (_, resultPoint, bottomResultPoint) in
                        result.append(resultPoint)
                        bottomResult.append(bottomResultPoint)
                    }
                }

                result.append(resultPoint)
                bottomResult.append(bottomResultPoint)

                if idx + 1 == points.count {
                    computeEdgePoints(meters: meters, direction: direction, point: point) { (_, resultPoint, bottomResultPoint) in
                        result.append(resultPoint)
                        bottomResult.append(bottomResultPoint)
                    }
                }
            }
        }

        result.append(contentsOf: bottomResult.reversed())
        return result
    }

    enum Direction {
        case north
        case south
        case east
        case west
        case northEast
        case northWest
        case southEast
        case southWest
    }

    /// A block that handles a direction, forward location and reverse location for polygon creation.
    typealias PolygonHelpBlock = (Direction, CLLocation, CLLocation) -> Void

    private func computeEdgePoints(meters: CLLocationDistance, direction: Direction, point: CLLocation, completion: PolygonHelpBlock) {

        switch direction {
        case .north:
            completion(.north, CLLocation(x: point.x - meters, y: point.y - meters),
                       CLLocation(x: point.x + meters, y: point.y - meters))
        case .south:
            completion(.south, CLLocation(x: point.x + meters, y: point.y - meters),
                       CLLocation(x: point.x - meters, y: point.y - meters))
        case .east:
            completion(.east, CLLocation(x: point.x - meters, y: point.y + meters),
                       CLLocation(x: point.x - meters, y: point.y - meters))
        case .west:
            completion(.west, CLLocation(x: point.x + meters, y: point.y + meters),
                       CLLocation(x: point.x + meters, y: point.y - meters))
        default:
            break
        }
    }

    private func helpPolygonArrayMethod1(meters: CLLocationDistance, last: CLLocation, point: CLLocation, completion: PolygonHelpBlock) {

        // swiftlint:disable:next identifier_name
        let 𝛅x = point.x - last.x
        let 𝛅y = point.y - last.y
        // swiftlint:disable:previous identifier_name

        if abs(𝛅x) < abs(𝛅y) {
            // vertical 𝛅 is greater than horizontal 𝛅
            if 𝛅y > 0 {
                // moving north (up)
                computeEdgePoints(meters: meters, direction: .north, point: last, completion: completion)
//                completion(.north, CLLocation(x: last.x - meters, y: last.y - meters),
//                           CLLocation(x: last.x + meters, y: last.y - meters))
            } else {
                // moving south (down)
                computeEdgePoints(meters: meters, direction: .south, point: last, completion: completion)
//                completion(.south, CLLocation(x: last.x + meters, y: last.y - meters),
//                           CLLocation(x: last.x - meters, y: last.y - meters))
            }
        } else {
            // horizontal 𝛅 is greater than vertical 𝛅
            if 𝛅x > 0 {
                // moving east (right)
                computeEdgePoints(meters: meters, direction: .east, point: last, completion: completion)
//                completion(.east, CLLocation(x: last.x - meters, y: last.y + meters),
//                           CLLocation(x: last.x - meters, y: last.y - meters))
            } else {
                // moving west (left)
                computeEdgePoints(meters: meters, direction: .west, point: last, completion: completion)
//                completion(.west, CLLocation(x: last.x + meters, y: last.y + meters),
//                           CLLocation(x: last.x + meters, y: last.y - meters))
            }
        }
    }

    private func helpPolygonArrayMethod2(meters: CLLocationDistance, last: CLLocation, point: CLLocation, completion: PolygonHelpBlock) {

        // swiftlint:disable:next identifier_name
        let 𝛅x = point.x - last.x
        let 𝛅y = point.y - last.y
        // swiftlint:disable:previous identifier_name

        if 𝛅y > 0 {
            // north
            if 𝛅x > 0 {
                // east
                completion(.northEast, CLLocation(x: last.x - meters, y: last.y - meters),
                           CLLocation(x: last.x - meters, y: last.y + meters))
            } else {
                // west
                completion(.northWest, CLLocation(x: last.x + meters, y: last.y - meters),
                           CLLocation(x: last.x + meters, y: last.y + meters))
            }
        } else {
            // south
            if 𝛅x > 0 {
                // east
                completion(.southEast, CLLocation(x: last.x - meters, y: last.y + meters),
                           CLLocation(x: last.x - meters, y: last.y - meters))
            } else {
                // west
                completion(.southWest, CLLocation(x: last.x + meters, y: last.y + meters),
                           CLLocation(x: last.x + meters, y: last.y - meters))
            }
        }
    }

}

// MARK: - Implementation

private extension GeoTrack {

    /// Builds the minimum bounding rectangle (in Mercator x, y coordinates).
    ///
    /// - Returns: A CGRect that is Mercator coordinates.
    func buildMbr() -> CGRect {
        var minX = Double.greatestFiniteMagnitude
        var maxX = 0 - Double.greatestFiniteMagnitude
        var minY = Double.greatestFiniteMagnitude
        var maxY = 0 - Double.greatestFiniteMagnitude

        guard points.count > 0 else {
            return .zero
        }

        for point in points {
            let mercatorX = point.coordinate.mercatorX
            let mercatorY = point.coordinate.mercatorY

            minX = min(minX, mercatorX)
            maxX = max(maxX, mercatorX)
            minY = min(minY, mercatorY)
            maxY = max(maxY, mercatorY)
        }

        return CGRect(x1: minX, y1: minY, x2: maxX, y2: maxY)
    }

}

extension CLLocation {

    // swiftlint:disable:next identifier_name
    convenience init(x: CLLocationDegrees, y: CLLocationDegrees) {
        self.init(latitude: y.latFromMercatorY, longitude: x.lonFromMercatorX)
    }

    // swiftlint:disable:next identifier_name
    var x: CLLocationDegrees {
        return coordinate.mercatorX
    }

    // swiftlint:disable:next identifier_name
    var y: CLLocationDegrees {
        return coordinate.mercatorY
    }
}

// MARK: - MKPolygon Extension

extension MKPolygon {

    func contains(point: CLLocation) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint = MKMapPoint(point.coordinate)
        let polygonViewPoint = polygonRenderer.point(for: currentMapPoint)

        return polygonRenderer.path.contains(polygonViewPoint)
    }
}
