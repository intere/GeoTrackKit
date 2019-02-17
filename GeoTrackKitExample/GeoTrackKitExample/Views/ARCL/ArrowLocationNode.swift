//
//  ArrowLocationNode.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/13/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import ARCL
import CoreLocation
import SceneKit
import UIKit

class ArrowLocationNode: LocationNode {

    /// Factory creation function, responsible for building the `ArrowLocationNode`.
    ///
    /// - Parameter location: The location that the node is to be positioned at (real world point).
    /// - Returns: An ArrowLocationNode at the specified position.
    class func build(fromLocation location: CLLocation?) -> ArrowLocationNode {
        let node = ArrowLocationNode(location: location)
        guard let arrow = node.loadArrowModel() else {
            assertionFailure("Failed to load the arrow model")
            return node
        }
        node.addChildNode(arrow)
        node.showDeselected()

        return node
    }
}

// MARK: - API

extension ArrowLocationNode {

    /// Performs a rotation of this node to point at the provided node.
    ///
    /// - Parameter node: The node that this node should be pointing at.
    func look(at node: LocationNode) {
        look(at: node.position, up: SCNVector3.yAxisUp, localFront: SCNVector3.yAxisUp)
    }

    /// Renders the node as selected
    func showSelected() {
        guard let arrow = childNodes.filter({ $0.name == "arrow" }).first else {
            return
        }
        for childNode in arrow.childNodes {
            childNode.geometry?.materials = [Constants.selectedMaterial, Constants.metalness, Constants.roughness]
        }
    }

    /// Renders the node as deselected
    func showDeselected() {
        guard let arrow = childNodes.filter({ $0.name == "arrow" }).first else {
            return
        }
        for childNode in arrow.childNodes {
            childNode.geometry?.materials = [Constants.deselectedMaterial, Constants.metalness, Constants.roughness]
        }
    }

}

// MARK: - Implementation

private extension ArrowLocationNode {

    struct Constants {
        static let deselectedMaterial = SCNMaterial.diffuse(fromColor: .red)
        static let selectedMaterial = SCNMaterial.diffuse(fromColor: .blue)
        static let metalness = SCNMaterial.metalness(fromFloat: 0.5)
        static let roughness = SCNMaterial.roughness(fromFloat: 0.5)
    }

    /// Loads the arrow model from the arrow scene.
    ///
    /// - Returns: The arrow node from the arrow scene.
    func loadArrowModel() -> SCNNode? {
        guard let scene = SCNScene(named: "example.scnassets/arrow.scn") else {
            return nil
        }

        return scene.rootNode.childNodes.filter({ $0.name == "arrow" }).first
    }

}

extension SCNMaterial {

    class func diffuse(fromColor color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        return material
    }

    class func metalness(fromFloat value: Float) -> SCNMaterial {
        let material = SCNMaterial()
        material.metalness.contents = value
        return material
    }

    class func roughness(fromFloat value: Float) -> SCNMaterial {
        let material = SCNMaterial()
        material.roughness.contents = value
        return material
    }

}

// MARK: - Math Extensions

extension SCNVector3 {

    static let yAxisUp = SCNVector3(0, 1, 0)

}


extension Int {

    var radians: CGFloat {
        return CGFloat(self) * .pi / 180
    }

}

extension Float {

    var radians: Float {
        return self * .pi / 180
    }
}


extension CGFloat {

    var float: Float {
        return Float(self)
    }

}
