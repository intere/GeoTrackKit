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

public class PolylineNode {
    public private(set) var locationNodes = [LocationNode]()

    public let polyline: MKPolyline?
    public let altitude: CLLocationDistance?
    public let elevatedPoints: [CLLocation]?

    private let lightNode: SCNNode = {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = .ambient
        if #available(iOS 10.0, *) {
            node.light!.intensity = 25
        }
        node.light!.attenuationStartDistance = 100
        node.light!.attenuationEndDistance = 100
        node.position = SCNVector3(x: 0, y: 10, z: 0)
        node.castsShadow = false
        node.light!.categoryBitMask = 3
        return node
    }()

    private let lightNode3: SCNNode = {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = .omni
        if #available(iOS 10.0, *) {
            node.light!.intensity = 100
        }
        node.light!.attenuationStartDistance = 100
        node.light!.attenuationEndDistance = 100
        node.light!.castsShadow = true
        node.position = SCNVector3(x: -10, y: 10, z: -10)
        node.castsShadow = false
        node.light!.categoryBitMask = 3
        return node
    }()

    public init(polyline: MKPolyline, altitude: CLLocationDistance) {
        self.polyline = polyline
        self.altitude = altitude
        self.elevatedPoints = nil

        contructNodesFromPolyline()
    }

    @available(iOS 11.0, *)
    public init(pointsWithElevation points: [CLLocation]) {
        self.polyline = nil
        self.altitude = nil
        self.elevatedPoints = points
        constructNodesFromPoints()
    }

}

// MARK: - Implementation

private extension PolylineNode {

    @available(iOS 11.0, *)
    func constructNodesFromPoints() {
        guard let elevatedPoints = elevatedPoints else {
            return assertionFailure("No elevated points set")
        }

        for i in 0 ..< elevatedPoints.count - 1 {
            let currentLocation = elevatedPoints[i]
            let nextLocation = elevatedPoints[i+1]

            let distance = currentLocation.distance(from: nextLocation)
            let altitudeDiff = currentLocation.altitude - nextLocation.altitude
            let slope = atan(altitudeDiff / distance)
            let bearing = -currentLocation.bearing(between: nextLocation)

            let box = SCNBox(width: 1, height: 0.2, length: CGFloat(distance), chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor(red: 47.0/255.0, green: 125.0/255.0, blue: 255.0/255.0, alpha: 1.0)

            let boxNode = SCNNode(geometry: box)
            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            // Rotate about the y-axis (up / down) to point the box in the correct direction
            // (toward the next point)
            boxNode.eulerAngles.y = Float(bearing).degreesToRadians
            boxNode.categoryBitMask = 3
            boxNode.addChildNode(lightNode)
            boxNode.addChildNode(lightNode3)

            let locationNode = LocationNode(location: currentLocation)
            locationNode.addChildNode(boxNode)
            locationNode.eulerAngles.x = Float(slope)

            locationNodes.append(locationNode)
        }
    }

    func contructNodesFromPolyline() {
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

            let box = SCNBox(width: 1, height: 0.2, length: CGFloat(distance), chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor(red: 47.0/255.0, green: 125.0/255.0, blue: 255.0/255.0, alpha: 1.0)

            let bearing = -currentLocation.bearing(between: nextLocation)

            let boxNode = SCNNode(geometry: box)
            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            boxNode.eulerAngles.y = Float(bearing).degreesToRadians
            boxNode.categoryBitMask = 3
            boxNode.addChildNode(lightNode)
            boxNode.addChildNode(lightNode3)

            let locationNode = LocationNode(location: currentLocation)
            locationNode.addChildNode(boxNode)

            locationNodes.append(locationNode)
        }
    }
}
