//
//  GameViewController.swift
//  Scene Visualizer
//
//  Created by Eric Internicola on 5/11/19.
//  Copyright © 2019 iColasoft. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {

    /// Gets you the polyline nodes from the scene.
    var polylineNodes: [SCNNode]? {
        guard let view = view as? SCNView, let scene = view.scene,
            let container = scene.rootNode.childNode(withName: "Container", recursively: true) else {
            return nil
        }

        return container.childNodes.filter({ $0.name?.starts(with: "Polyline") ?? false })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ARCL-Saved.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        // retrieve the conotainer node
        guard let container = scene.rootNode.childNode(withName: "Container", recursively: true)
            ?? scene.rootNode.childNodes.filter({ !$0.childNodes.isEmpty }).first else {
                return assertionFailure("Failed to find a list of nodes")
        }
        patchPolylines(container: container)


        // retrieve the SCNView
        guard let scnView = self.view as? SCNView else {
            return
        }
        scnView.debugOptions = [.showBoundingBoxes, .showSkeletons]
        scnView.autoenablesDefaultLighting = true
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers

//        guard let nodes = polylineNodes else {
//            return assertionFailure("Womp. Womp.")
//        }
//        nodes.forEach {
//            $0.runAction(SCNAction.repeat(SCNAction.rotateBy(x: -1, y: 0, z: 0, duration: 5), count: 50))
//        }
        polylineNodes?.forEach({ $0.eulerAngles.x = 0 - $0.eulerAngles.x })
    }

    /// This function attempts to move each polyline node to where each
    ///
    /// - Parameter container: the Node container to get the points and polyline nodes from.
    func patchPolylines(container: SCNNode) {
        let points = container.childNodes.filter({ $0.name?.starts(with: "point ") ?? false })
        guard points.count > 0 else {
            return print("No point nodes found, no patching will be performed")
        }

        for idx in 0..<points.count - 1 {
            guard let polyline = container.childNodes.filter({ $0.name == "Polyline\(idx)" }).first,
                let point = container.childNodes.filter({ $0.name == "point \(idx)" }).first else {
                    print("Index \(idx) not found")
                    continue
            }
            polyline.position = point.position
        }
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        guard let scnView = self.view as? SCNView else {
            return
        }
        
        // check what nodes are clicked
        let point = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(point, options: [:])
        // check that we clicked on at least one object

        guard let result = hitResults.first else {
            return
        }

        print("Before Box Eulers: \(result.node.eulerAngles.radiansToDegrees)")
//        result.node.eulerAngles.x += 5.degreesToRadians
//        print("After Box Eulers: \(result.node.eulerAngles.radiansToDegrees)")

        pointBox(at: result.node)

        // get its material
        guard let material = result.node.geometry?.firstMaterial else {
            return
        }

        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5

        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5

            material.emission.contents = NSColor.black

            SCNTransaction.commit()
        }

        material.emission.contents = NSColor.red

        SCNTransaction.commit()
    }

    func pointBox(at anotherNode: SCNNode) {
        guard let sceneView = self.view as? SCNView else {
            return assertionFailure("Failed to get the scene view")
        }
        guard let scene = sceneView.scene else {
            return assertionFailure("Failed to get the scene")
        }
        guard let box = scene.rootNode.childNode(withName: "box", recursively: false) else {
            return print("Failed to find the box")
        }

        box.look(at: anotherNode)
    }
}


extension SCNNode {

    /// Performs a rotation of this node to point at the provided node.
    ///
    /// - Parameter node: The node that this node should be pointing at.
    func look(at node: SCNNode) {
        if node.name == nil, let parent = node.parent, let parentName = parent.name, parentName != "Container" {
            return look(at: parent)
        }
        look(at: node.position, up: SCNVector3.yAxisUp, localFront: SCNVector3.yAxisUp)

        if let name = node.name {
            print("Looking at \(name)")
        }
    }

}

// MARK: - Math Extensions

extension SCNVector3 {

    static let yAxisUp = SCNVector3(0, 1, 0)

    var radiansToDegrees: SCNVector3 {
        return SCNVector3Make(x.radiansToDegrees, y.radiansToDegrees, z.radiansToDegrees)
    }

    var degreesToRadians: SCNVector3 {
        return SCNVector3Make(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians)
    }

}

extension CGFloat {
    public var degreesToRadians: CGFloat { return self * .pi / 180 }
    public var radiansToDegrees: CGFloat { return self * 180 / .pi }
}

extension Int {
    public var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
    public var radiansToDegrees: CGFloat { return CGFloat(self) * 180 / .pi }
}
