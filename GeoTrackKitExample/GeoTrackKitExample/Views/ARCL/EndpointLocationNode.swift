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

    /// Factory creation function for the EndpointLocationNode.  It creates the object and adds
    /// the scenekit children for you and renders it ass you specify (start / end).
    ///
    /// - Parameters:
    ///   - location: The real world location for the point.
    ///   - isStart: Is this a start point?  True = start, False = end.
    /// - Returns: A fully configured EndpointLocationNode object.
    class func build(fromLocation location: CLLocation?, isStart: Bool = true) -> EndpointLocationNode {
        let node = EndpointLocationNode(location: location)
        guard let arrow = node.loadEndpointModel() else {
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

    /// Loads the arrow model from the arrow scene.
    ///
    /// - Returns: The arrow node from the arrow scene.
    func loadEndpointModel() -> SCNNode? {
        guard let scene = SCNScene(named: "example.scnassets/endpoint.scn") else {
            return nil
        }

        return scene.rootNode.childNodes.filter({ $0.name == "endpoint" }).first
    }

}
