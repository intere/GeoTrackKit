//
//  ARCLViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/7/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//


import ARCL
import ARKit
import CoreLocation
import GeoTrackKit
import SceneKit
import MapKit
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

    var currentLocation: CLLocation? {
        return sceneView.sceneLocationManager.currentLocation
    }

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

    }

    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {

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

    /// Handles selecting the provided node (and deselecting all others).
    ///
    /// - Parameter node: The node to be selected.
    func select(node: LocationNode) {
        // 1. Keep track of the selectedNode (for distance computation)
        selectedNode = node

        // 2. Iterate through all of the children in the scene's rootNode
        sceneView.scene.rootNode.childNodes.forEach { parentNode in
            // 3. Iterate on all grandchildren (of the rootNode) that are ArrowLocationNode objects
            parentNode.childNodes.compactMap({ $0 as? ArrowLocationNode }).forEach { arrowNode in
                // 4. Select / Deselect the node, depending on whether or not it's the newly selected node.
                if arrowNode == node {
                    arrowNode.showSelected()
                } else {
                    arrowNode.showDeselected()
                }
            }
        }
    }

    /// Configures the ARCL scene
    func configureARCL() {
        sceneView.showAxesNode = true
        sceneView.locationViewDelegate = self
        sceneView.locationEstimateMethod = .mostRelevantEstimate

        if displayDebugging {
            sceneView.showFeaturePoints = true
            sceneView.debugOptions = [ .showWireframe, .showFeaturePoints, .showWorldOrigin, .showWireframe]
        }

        addTrackPoints()
    }

    /// Adds the track points to the scene (waits for the scene to have a real world location)
    ///
    func addTrackPoints() {
        guard currentLocation != nil else {
            print("Location fix not established yet, trying again shortly")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addTrackPoints()
            }
            return
        }

        renderDirections()
//        renderFloatingArrows()
    }

    /// Renders directions to a specific location.
    func renderDirections() {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 39.9390932, longitude: -105.0150254)))
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: {(response, error) in
            if error != nil {
                return print("Error getting directions")
            }
            guard let response = response else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.sceneView.addRoutes(routes: response.routes)
            }
        })
    }

    func renderFloatingArrows() {
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
        makeArrowsPointToNextPoint()
    }

    /// Iterates through all of the points and if it's an arrow; makes it
    /// point to the next point in the track.
    func makeArrowsPointToNextPoint() {
        var last: LocationNode?

        nodes.forEach { node in
            defer {
                last = node
            }
            if let last = last {
                (last as? ArrowLocationNode)?.look(at: node)
            }
        }
    }

    /// Takes the points from the track and creates an array of `LocationNode` objects.
    /// and hands those back to you.
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
    /// Updates the info label and forces the arrows to point to their next point.
    func updateInfoLabel() {
        var text = ""
        guard let location = currentLocation else {
            infoLabel.text = nil
            return
        }
        text += "hAcc: \(Int(location.horizontalAccuracy)), vAcc: \(Int(location.verticalAccuracy))\n"

        if let selectedNode = selectedNode {
            let distance = selectedNode.location.distance(from: location)
            text += "Distance: \(String(format: "%.2f", distance)) meters\n"
        }
        if let position = sceneView.currentScenePosition {
            text += "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }

        if let eulerAngles = sceneView.currentEulerAngles {
            text.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }

        if let heading = sceneView.sceneLocationManager.locationManager.heading,
            let accuracy = sceneView.sceneLocationManager.locationManager.headingAccuracy {
            text.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }

        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)

        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            text.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }

        infoLabel.text = text

        makeArrowsPointToNextPoint()
    }

}
