//
//  GeoTrack+Utilities.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/9/18.
//

import CoreLocation
import MapKit

// MARK: - GeoTrack

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

    func toPolygonPointArray(size meters: CLLocationDistance) -> [CLLocation]? {
        return toPolygonPointArray(points: points, size: meters)
    }

    /// Creates a polygon from the track that expands the line by the `size` meters you provide.
    /// - Parameter points: The points to convert to a polygon array
    /// - Parameter meters: The distance to expand outwards.
    func toPolygonPointArray(points: [CLLocation], size meters: CLLocationDistance) -> [CLLocation]? {
        // swiftlint:disable:previous cyclomatic_complexity
        guard points.count > 2 else {
            return nil
        }

        var result = [CLLocation]()
        var bottomResult = [CLLocation]()

        for idx in 1..<points.count {
            let last = points[idx - 1]
            let point = points[idx]

            let direction = last.direction(from: point)

            // swiftlint:disable identifier_name
            let x1: Double, x2: Double
            let y1: Double, y2: Double
            // swiftlint:enable identifier_name

            switch direction.vertical {
            case .north:
                switch direction.horizontal {
                case .east:
                    // North East
                    x1 = (last.x + point.x) / 2
                    y1 = (last.y + point.y) / 2 + meters
                    x2 = x1
                    y2 = (last.y + point.y) / 2 - meters
                case .west:
                    // North West
                    x1 = (last.x + point.x) / 2
                    y1 = (last.y + point.y) / 2 - meters
                    x2 = x1
                    y2 = (last.y + point.y) / 2 + meters
                case .none:
                    // North
                    x1 = last.x - meters
                    y1 = (last.y + point.y) / 2
                    x2 = last.x + meters
                    y2 = y1
                }
            case .south:
                switch direction.horizontal {
                case .east:
                    // South East
                    x1 = (last.x + point.x) / 2
                    y1 = (last.y + point.y) / 2 - meters
                    x2 = x1
                    y2 = (last.y + point.y) / 2 + meters
                case .west:
                    // South West
                    x1 = (last.x + point.x) / 2
                    y1 = (last.y + point.y) / 2 + meters
                    x2 = x1
                    y2 = (last.y + point.y) / 2 - meters
                case .none:
                    // South
                    x1 = last.x - meters
                    y1 = (last.y + point.y) / 2
                    x2 = last.x + meters
                    y2 = y1
                }
            case .none:
                switch direction.horizontal {
                case .east:
                    // East
                    x1 = (last.x + point.x) / 2
                    y1 = last.y + meters
                    x2 = x1
                    y2 = last.y - meters
                case .west:
                    // West
                    x1 = (last.x + point.x) / 2
                    y1 = last.y + meters
                    x2 = x1
                    y2 = last.y - meters

                case .none:
                    // Same point
                    assertionFailure()
                    return nil
                }
            }
            result.append(CLLocation(x: x1, y: y1))
            bottomResult.append(CLLocation(x: x2, y: y2))
        }

        result.append(contentsOf: bottomResult.reversed())
        return result
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

// MARK: - CLLocation extension

extension CLLocation {

    // swiftlint:disable:next identifier_name
    var x: CLLocationDegrees {
        return coordinate.mercatorX
    }

    // swiftlint:disable:next identifier_name
    var y: CLLocationDegrees {
        return coordinate.mercatorY
    }

    enum Horizontal {
        case east
        case west
        case none

        /// Tells you what direction the second point is from the first in the east/west direction.
        /// - Parameters:
        ///   - first: The first point.
        ///   - second: The second point.
        static func direction(from first: CLLocation, to second: CLLocation) -> Horizontal {
            if second.x < first.x {
                return .west
            } else if second.x > first.x {
                return .east
            } else {
                return .none
            }
        }
    }

    enum Vertical {
        case north
        case south
        case none

        /// Tells you what direction the second point is from the first in the north/west direction.
        /// - Parameters:
        ///   - first: The first point.
        ///   - second: The second point.
        static func direction(from first: CLLocation, to second: CLLocation) -> Vertical {
            if second.y < first.y {
                return .south
            } else if second.y > first.y {
                return .north
            } else {
                return .none
            }
        }
    }

    struct Direction {
        let horizontal: Horizontal
        let vertical: Vertical
    }

    // swiftlint:disable:next identifier_name
    convenience init(x: CLLocationDegrees, y: CLLocationDegrees) {
        self.init(latitude: y.latFromMercatorY, longitude: x.lonFromMercatorX)
    }

    /// Tells you what direction the provided point is from the provided point.
    /// - Parameter point: The point you want to know the direction from.
    func direction(from point: CLLocation) -> Direction {
        return Direction(horizontal: .direction(from: self, to: point),
                         vertical: .direction(from: self, to: point))
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
