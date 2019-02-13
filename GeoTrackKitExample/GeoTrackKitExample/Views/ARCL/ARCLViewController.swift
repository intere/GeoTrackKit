//
//  ARCLViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/7/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import ARCL
import CoreLocation
import GeoTrackKit
import SceneKit
import UIKit

class ARCLViewController: UIViewController {

    @IBOutlet weak var sceneView: SceneLocationView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var mapView: GeoTrackMap!

    var track: GeoTrack?
    var selectedNode: LocationNode?

    var displayDebugging = false
    var adjustNorthByTappingSidesOfScreen = true
    var updateInfoLabelTimer: Timer?
    var nodes = [LocationNode]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureARCL()

        if let track = track {
            mapView.model = UIGeoTrack(with: track)
            mapView.showsUserLocation = true
            mapView.showPoints = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(selectedAnnotationPoint(_:)), name: Notification.Name.GeoTrackKit.selectedAnnotationPoint, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.run()
        updateInfoLabelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateInfoLabel), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateInfoLabelTimer?.invalidate()
        sceneView.pause()
        super.viewWillDisappear(animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: sceneView)

        if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
            print("left side of the screen")
            sceneView.moveSceneHeadingAntiClockwise()
        } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
            print("right side of the screen")
            sceneView.moveSceneHeadingClockwise()
        }
    }

}

// MARK: - Notification Handlers

extension ARCLViewController {

    @objc
    func selectedAnnotationPoint(_ notification: NSNotification) {
        guard let annotation = notification.object as? PointAnnotation else {
            return assertionFailure("no object, or wrong object type")
        }
        for node in nodes where node.location.coordinate.latitude == annotation.coordinate.latitude && node.location.coordinate.longitude == annotation.coordinate.longitude {
            select(node: node)
            break
        }
    }

}

// MARK: - SceneLocationViewDelegate

@available(iOS 11.0, *)
extension ARCLViewController: SceneLocationViewDelegate {

    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
//        print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }

    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
//        print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }

    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        print("sceneLocationViewDidConfirmLocationOfNode: \(node)")
    }

    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        print("sceneLocationViewDidSetupSceneNode: \(sceneNode)")
    }

    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        //        print("sceneLocationViewDidUpdateLocationAndScaleOfLocationNode: \(locationNode)")
    }
}

// MARK: - Implementation

extension ARCLViewController {

    func select(node: LocationNode) {
        sceneView.scene.rootNode.childNodes.forEach { parentNode in
            parentNode.childNodes.filter({ $0 is LocationNode }).forEach { childNode in
                guard let arrowNode = childNode as? ArrowLocationNode else {
                    return
                }
                guard arrowNode != node else {
                    self.selectedNode = node
                    arrowNode.showSelected()
                    return
                }
                arrowNode.showDeselected()
            }
        }
    }

    func configureARCL() {
        sceneView.showAxesNode = true
        sceneView.locationDelegate = self
        //        sceneView.locationEstimateMethod = .coreLocationDataOnly

        if displayDebugging {
            sceneView.showFeaturePoints = true
            sceneView.debugOptions = [ .showWireframe, .showFeaturePoints, .showWorldOrigin, .showWireframe]
        }

        addTrackPoints()
    }

    /// Adds the track points to the scene (waits for the scene to have a real world location)
    ///
    func addTrackPoints() {
        guard sceneView.currentLocation() != nil else {
            print("Location fix not established yet, trying again shortly")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addTrackPoints()
            }
            return
        }

        guard let trackPointObjects = buildTrailData() else {
            return
        }

        trackPointObjects.forEach { pointNode in
            if let location = pointNode.location {
                print("Adding trail point: \(pointNode), \(pointNode.locationConfirmed), \(location)")
            }
            sceneView.addLocationNodeWithConfirmedLocation(locationNode: pointNode)
        }
        self.nodes = trackPointObjects
    }

    /// Takes the points from the track and creates an array of `LocationNode` objects (currently a
    /// half-meter red ball) and hands those back to you.
    ///
    /// - Returns: An arry of location nodes if there are trail points.
    func buildTrailData() -> [LocationNode]? {
        guard let track = track, track.points.count > 0 else {
            return nil
        }

        var nodes = [LocationNode]()

        for index in 0..<track.points.count {
            let point = track.points[index]
            let node: LocationNode

            if index == 0 {
                node = EndpointLocationNode.build(fromLocation: point, isStart: true)
            } else if index == track.points.count - 1 {
                node = EndpointLocationNode.build(fromLocation: point, isStart: false)
            } else {
                node = ArrowLocationNode.build(fromLocation: point)
            }
            nodes.append(node)
        }

        return nodes
    }

    @objc
    func updateInfoLabel() {
        var text = ""
        guard let location = sceneView.currentLocation() else {
            infoLabel.text = nil
            return
        }
        text += "hAcc: \(Int(location.horizontalAccuracy)), vAcc: \(Int(location.verticalAccuracy))\n"

        if let selectedNode = selectedNode {
            let distance = selectedNode.location.distance(from: location)
            text += "Distance: \(String(format: "%.2f", distance)) meters\n"
        }
        if let position = sceneView.currentScenePosition() {
            text += "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }

        if let eulerAngles = sceneView.currentEulerAngles() {
            text.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }

        if let heading = sceneView.locationManager.heading,
            let accuracy = sceneView.locationManager.headingAccuracy {
            text.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }

        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)

        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            text.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }

        infoLabel.text = text
    }

}
