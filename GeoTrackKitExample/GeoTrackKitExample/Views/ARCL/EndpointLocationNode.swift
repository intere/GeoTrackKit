//
//  EndpointLocationNode.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/13/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import ARCL
import CoreLocation
import SceneKit
import UIKit

class EndpointLocationNode: LocationNode {

    class func build(fromLocation location: CLLocation?, isStart: Bool = true) -> EndpointLocationNode {
        let node = EndpointLocationNode(location: location)
        guard let arrow = node.loadArrowModel() else {
            assertionFailure("Failed to load the arrow model")
            return node
        }
        node.addChildNode(arrow)

        if isStart {
            node.showStart()
        } else {
            node.showEnd()
        }

        return node
    }


    /// Loads the arrow model from the arrow scene.
    ///
    /// - Returns: The arrow node from the arrow scene.
    func loadArrowModel() -> SCNNode? {
        guard let scene = SCNScene(named: "example.scnassets/endpoint.scn") else {
            return nil
        }

        return scene.rootNode.childNodes.filter({ $0.name == "endpoint" }).first
    }
}

// MARK: - API

extension EndpointLocationNode {

    /// Renders the node as selected
    func showStart() {
        guard let arrow = childNodes.filter({ $0.name == "endpoint" }).first else {
            return
        }
        for childNode in arrow.childNodes {
            childNode.geometry?.materials = [Constants.startMaterial, Constants.metalness, Constants.roughness]
        }
    }

    /// Renders the node as deselected
    func showEnd() {
        guard let arrow = childNodes.filter({ $0.name == "endpoint" }).first else {
            return
        }
        for childNode in arrow.childNodes {
            childNode.geometry?.materials = [Constants.endMaterial, Constants.metalness, Constants.roughness]
        }
    }

}

// MARK: - Implementation

private extension EndpointLocationNode {

    struct Constants {
        static let startMaterial = SCNMaterial.diffuse(fromColor: .green)
        static let endMaterial = SCNMaterial.diffuse(fromColor: .red)
        static let metalness = SCNMaterial.metalness(fromFloat: 0.5)
        static let roughness = SCNMaterial.roughness(fromFloat: 0.5)
    }

}
