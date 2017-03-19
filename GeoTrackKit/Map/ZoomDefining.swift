//
//  ZoomDefining.swift
//  Pods
//
//  Created by Internicola, Eric on 3/14/17.
//
//

import CoreLocation
import MapKit

/// A protocol that tells us the implementer can define the size of the zoom area.
public protocol ZoomDefining: class {

    /// Should the map re-zoom?
    var shouldZoom: Bool { get }

    /// Provides a zoom region for the provided points
    ///
    /// - Parameter points: The points to calculate the zoom region for.
    /// - Returns: The zoom region that allows you to see all of the points.
    func zoomRegion(for points: [CLLocation]) -> MKCoordinateRegion

}
