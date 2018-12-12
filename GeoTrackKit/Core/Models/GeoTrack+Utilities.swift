//
//  GeoTrack+Utilities.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/9/18.
//

import CoreLocation
import Foundation

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
