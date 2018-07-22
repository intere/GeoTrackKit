//
//  DefaultMapZoom.swift
//  GeoTrackKit
//
//  Created by Internicola, Eric on 3/14/17.
//
//

import CoreLocation
import MapKit

/// This is an implementation of the default map zooming.  It basically just states that you should always zoom to fit the points (whenever a redraw on the map is requested) and it calculates a zoom region that has a very tiny amount of padding around the points
open class DefaultMapZoom: ZoomDefining {

    /// Yes, let's zoom in
    public var shouldZoom: Bool {
        return true
    }

    /// Provides a zoom region for the provided points
    ///
    /// - Parameter points: The points to calculate the zoom region for.
    /// - Returns: The zoom region that allows you to see all of the points.
    public func zoomRegion(for points: [CLLocation]) -> MKCoordinateRegion {
        return getZoomRegion(points)
    }

    /// helper that will figure out what region on the map should be visible, based on your current points.
    ///
    /// - Parameter points: the points to analyze to determine the zoom window.
    /// - Returns: A zoom region.
    func getZoomRegion(_ points: [CLLocation]) -> MKCoordinateRegion {
        var region = MKCoordinateRegion()
        var maxLat: CLLocationDegrees = -90
        var maxLon: CLLocationDegrees = -180
        var minLat: CLLocationDegrees = 90
        var minLon: CLLocationDegrees = 180

        for point in points {
            maxLat = max(maxLat, point.coordinate.latitude)
            maxLon = max(maxLon, point.coordinate.longitude)
            minLat = min(minLat, point.coordinate.latitude)
            minLon = min(minLon, point.coordinate.longitude)
        }

        region.center.latitude = (maxLat + minLat) / 2
        region.center.longitude = (maxLon + minLon) / 2
        region.span.latitudeDelta = maxLat - minLat + 0.01
        region.span.longitudeDelta = maxLon - minLon + 0.01

        if points.count < 4 {
            region.span.latitudeDelta = 0.0005
            region.span.longitudeDelta = 0.001
        }

        return region
    }

}
