//
//  DirectionNode.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 5/11/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import ARCL
import CoreLocation
import SceneKit
import UIKit

class DirectionNode: LocationNode {

    class func build(startPoint: CLLocation, endPoint: CLLocation) -> DirectionNode {
        let node = DirectionNode(location: startPoint)
        let distance = startPoint.distance(from: endPoint)
        let arrow = node.loadDirectionModel(height: distance)
        node.addChildNode(arrow)

        return node
    }

    class func build(from points: [CLLocation]) -> [DirectionNode] {
        var nodes = [DirectionNode]()

        for idx in 0..<points.count - 1 {
            let current = points[idx]
            let next = points[idx+1]

            nodes.append(build(startPoint: current, endPoint: next))
        }

        return nodes
    }

    /// Performs a rotation of this node to point at the provided node.
    ///
    /// - Parameter node: The node that this node should be pointing at.
    func look(at node: LocationNode) {
        look(at: node.position, up: SCNVector3.yAxisUp, localFront: SCNVector3.yAxisUp)
    }

}

private extension DirectionNode {

    /// Loads the arrow model from the arrow scene.
    ///
    /// - Returns: The arrow node from the arrow scene.
    func loadDirectionModel(height: CLLocationDistance) -> SCNNode {

        let box = SCNBox(width: 1, height: CGFloat(height), length: 1, chamferRadius: 0.5)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        box.materials = [material]
        let node = SCNNode(geometry: box)
        node.position.y = Float(height / 2)

        return node
    }
}
