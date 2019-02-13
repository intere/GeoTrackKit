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

// MARK: - API

extension ArrowLocationNode {

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
