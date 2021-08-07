//
//  UIGeoTrack.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 2/28/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

/// A UI Model for a track.  It keeps track of a Track (`GeoTrack`), a Track Analyzer (`GeoTrackAnalyzer`) and a
/// collection of Legs (ascents, descents) that are currently visible
public class UIGeoTrack {
    /// The Track
    public var track: GeoTrack {
        return analyzer.track
    }
    /// The Track analyzer (provides stats about the track)
    public let analyzer: GeoTrackAnalyzer
    /// The legs that are currently visible
    fileprivate var visibleLegs: [Leg] = []

    /// Initializes the UI Model with the provided track.  It then creates the analyzer and calculates the stats for it.
    ///
    /// - Parameter track: The track to initialize with.
    public init(with track: GeoTrack) {
        analyzer = GeoTrackAnalyzer(track: track)
        analyzer.calculate()
        enableAll()
    }

}

// MARK: - API

public extension UIGeoTrack {

    /// The current set of legs that are visible on the map
    var legs: [Leg] {
        return visibleLegs
    }

    /// The entire set of legs (including those that are hidden)
    var allLegs: [Leg] {
        return analyzer.legs
    }

    /// gets you an array of polylines to draw based on the array of legs
    var polylines: [MKPolyline] {
        var polys = [MKPolyline]()
        let points = track.points

        for leg in legs {
            var coordinates = [CLLocationCoordinate2D]()
            for index in leg.index...leg.endIndex {
                coordinates.append(points[index].coordinate)
            }
            let poly = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            poly.title = leg.direction.rawValue
            polys.append(poly)
        }

        return polys
    }

    /// Gets you the points for the provided leg.
    /// - Parameter leg: The leg that you want the points for.
    func points(for leg: Leg) -> [CLLocation]? {
        guard leg.index >= 0, leg.index < track.points.count, leg.endIndex < track.points.count else {
            return nil
        }

        return Array(track.points[leg.index...leg.endIndex])
    }

    func expandedPolyline(forLeg leg: Leg, size meters: CLLocationDistance) -> MKPolygon? {
        guard let points = points(for: leg),
              let coordinates = track.toPolygonPointArray(points: points, size: meters) else { return nil }

        return MKPolygon(coordinates: coordinates.map({ $0.coordinate }), count: coordinates.count)
    }

    /// Gets you an expanded polyline of the entire track.
    /// - Parameter meters: The distance outward from the line (in meters).
    func expandedPolyline(size meters: CLLocationDistance) -> MKPolygon? {
        guard let coordinates = track.toPolygonPointArray(size: meters) else { return nil }

        return MKPolygon(coordinates: coordinates.map({ $0.coordinate }), count: coordinates.count)
    }

    /// Toggles the visibility of all cells
    ///
    /// - Parameter visible: Whether they should all be visible or not.
    func toggleAll(visibility visible: Bool) {
        visibleLegs.removeAll()
        if visible {
            visibleLegs.append(contentsOf: allLegs)
        }
        NotificationCenter.default.post(name: Notification.Name.GeoMapping.legVisibilityChanged, object: self)
    }

    /// Tells you if the leg at the specified index is visible or not
    ///
    /// - Parameter index: The index to check for visibility
    /// - Returns: true if it's visible, false if it's not.
    func isVisible(at index: Int) -> Bool {
        guard index < allLegs.count else {
            return false
        }
        return visibleLegs.contains(where: { $0 == allLegs[index] })
    }

    /// Toggles the visibility and sends out a notification
    ///
    /// - Parameters:
    ///   - visible: The visibility to set for the
    ///   - leg: The leg to be toggled
    func set(visibility visible: Bool, for leg: Leg) {
        if visible {
            guard !visibleLegs.contains(where: { $0 == leg }) else {
                return
            }
            visibleLegs.append(leg)
        } else {
            guard let index = visibleLegs.firstIndex(of: leg) else {
                return
            }
            visibleLegs.remove(at: index)
        }
        NotificationCenter.default.post(name: Notification.Name.GeoMapping.legVisibilityChanged, object: self)
    }

    /// Make all of the legs visible
    func enableAll() {
        visibleLegs.removeAll()
        for leg in allLegs {
            visibleLegs.append(leg)
        }
    }

}

// MARK: - Geo Mapping Notification (for Map Updates)

public extension Notification.Name {

    /// A notification that tells us that a visibility of one or more legs has been toggled on the map.
    struct GeoMapping {

        /// Tells you that a leg's visibility has been toggle on or off and therefore the map should be updated
        public static let legVisibilityChanged = Notification.Name(rawValue: "geo.mapping.leg.visibility.changed")
    }
}
