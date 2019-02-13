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

    func showSelected() {
        guard let arrow = childNodes.filter({ $0.name == "arrow" }).first else {
            return
        }
        for childNode in arrow.childNodes {
            childNode.geometry?.materials = [Constants.selectedMaterial]
        }
    }

    func showDeselected() {
        guard let arrow = childNodes.filter({ $0.name == "arrow" }).first else {
            return
        }
        for childNode in arrow.childNodes {
            childNode.geometry?.materials = [Constants.deselectedMaterial]
        }
    }

}

// MARK: - Implementation

private extension ArrowLocationNode {

    struct Constants {
        static let deselectedMaterial = SCNMaterial(fromColor: .red)
        static let selectedMaterial = SCNMaterial(fromColor: .blue)
    }

}

extension SCNMaterial {

    convenience init(fromColor color: UIColor) {
        self.init()
        diffuse.contents = color
    }

}
