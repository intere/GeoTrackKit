//
//  PolylineNode.swift
//  ARKit+CoreLocation
//
//  Created by Ilya Seliverstov on 11/08/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import MapKit

/// A block that will build an SCNBox with the provided distance.
/// Note: the distance should be aassigned to the length
public typealias BoxBuilder = (_ distance: CGFloat) -> SCNBox

/// A Node that is used to show directions in AR-CL.
public class PolylineNode {
    public private(set) var locationNodes = [LocationNode]()

    public let polyline: MKPolyline?
    public let altitude: CLLocationDistance?
    public let boxBuilder: BoxBuilder
    public let elevatedPoints: [CLLocation]?

    /// Creates a `PolylineNode` from the provided polyline, altitude (which is assumed to be uniform
    /// for all of the points) and an optional SCNBox to use as a prototype for the location boxes.
    ///
    /// - Parameters:
    ///   - polyline: The polyline that we'll be creating location nodes for.
    ///   - altitude: The uniform altitude to use to show the location nodes.
    ///   - boxBuilder: A block that will customize how a box is built.
    public init(polyline: MKPolyline, altitude: CLLocationDistance, boxBuilder: BoxBuilder? = nil) {
        self.polyline = polyline
        self.altitude = altitude
        self.boxBuilder = boxBuilder ?? Constants.defaultBuilder
        self.elevatedPoints = nil

        contructNodes()
    }

    @available(iOS 11.0, *)
    public init(pointsWithElevation points: [CLLocation], boxBuilder: BoxBuilder? = nil) {
        self.polyline = nil
        self.altitude = nil
        self.boxBuilder = boxBuilder ?? Constants.defaultBuilder
        self.elevatedPoints = points
        constructNodesFromPoints()
    }

}

// MARK: - Implementation

private extension PolylineNode {

    struct Constants {
        static let defaultBuilder: BoxBuilder = { (distance) -> SCNBox in
            let box = SCNBox(width: 1, height: 0.2, length: distance, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor(red: 47.0/255.0, green: 125.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            return box
        }
    }

    func constructNodesFromPoints() {
        guard let elevatedPoints = elevatedPoints else {
            return assertionFailure("Points with elevation are not set")
        }

        for i in 0 ..< elevatedPoints.count - 1 {
            let currentLocation = elevatedPoints[i]
            let nextLocation = elevatedPoints[i+1]

            let distance = currentLocation.distance(from: nextLocation)
            let altitudeDiff = currentLocation.altitude - nextLocation.altitude
            let slopeDegrees = atan(altitudeDiff / distance)
            let box = boxBuilder(CGFloat(distance))
            let boxNode = SCNNode(geometry: box)

            let bearingDegrees = -currentLocation.bearing(between: nextLocation)

            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            boxNode.eulerAngles.x = Float(slopeDegrees).degreesToRadians
            boxNode.eulerAngles.y = Float(bearingDegrees).degreesToRadians

            let locationNode = LocationNode(location: currentLocation)
            locationNode.addChildNode(boxNode)

            locationNodes.append(locationNode)
        }
    }


    /// This is what actually builds the SCNNodes and appends them to the
    /// locationNodes collection so they can be added to the scene and shown
    /// to the user.  If the prototype box is nil, then the default box will be used
    func contructNodes() {
        guard let polyline = polyline else {
            return assertionFailure("No polyline set")
        }
        guard let altitude = altitude else {
            return assertionFailure("No altitude set")
        }

        let points = polyline.points()

        for i in 0 ..< polyline.pointCount - 1 {
            let currentLocation = CLLocation(coordinate: points[i].coordinate, altitude: altitude)
            let nextLocation = CLLocation(coordinate: points[i + 1].coordinate, altitude: altitude)

            let distance = currentLocation.distance(from: nextLocation)

            let box = boxBuilder(CGFloat(distance))
            let boxNode = SCNNode(geometry: box)

            let bearing = -currentLocation.bearing(between: nextLocation)

            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            boxNode.eulerAngles.y = Float(bearing).degreesToRadians

            let locationNode = LocationNode(location: currentLocation)
            locationNode.addChildNode(boxNode)

            locationNodes.append(locationNode)
        }
    }

}
