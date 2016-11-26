//
//  ViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import UIKit
import CoreLocation
import GeoTrackKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var accuracyLabel: UILabel!
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func clickedTrackButton(_ sender: UIButton) {
        handleTrackingClick()
    }
}

// MARK: - Helpers

fileprivate extension ViewController {

    func handleTrackingClick() {
        if GeoTrackManager.shared.isTracking {
            GeoTrackManager.shared.stopTracking()
            timer?.invalidate()
        } else {
            GeoTrackManager.shared.startTracking()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
        }
        updateButtonText()
        updateLabels()
    }

    func updateButtonText() {
        button.setTitle(GeoTrackManager.shared.isTracking ? "Stop Tracking" : "Start Tracking", for: .normal)
    }

    @objc func updateLabels() {
        updateButtonText()
        if GeoTrackManager.shared.isAwaitingFix {
            awaitingFix()
            return
        }
        guard GeoTrackManager.shared.isTracking else {
            notTracking()
            return
        }
        guard let currentPoint = GeoTrackManager.shared.lastPoint else {
            awaitingFix()
            return
        }
        updateAltitude(location: currentPoint)
        updateLocation(location: currentPoint)
        updateAccuracy(location: currentPoint)
    }

    func awaitingFix() {
        altitudeLabel.text = "Awaiting fix"
        locationLabel.text = nil
        accuracyLabel.text = nil
    }

    func notTracking() {
        altitudeLabel.text = "Not Tracking"
        locationLabel.text = nil
        accuracyLabel.text = nil
    }

    func updateAccuracy(location: CLLocation) {
        let hAcc = String(format: "%.2f", location.horizontalAccuracy)
        let vAcc = String(format: "%.2f", location.verticalAccuracy)
        accuracyLabel.text = "hAcc/vAcc: \(hAcc) / \(vAcc)"
    }

    func updateLocation(location: CLLocation) {
        let lat = String(format: "%.5f", location.coordinate.latitude)
        let lon = String(format: "%.5f", location.coordinate.longitude)
        locationLabel.text = "Lat/Lon: \(lat) / \(lon)"
    }

    func updateAltitude(location: CLLocation) {
        let feet = Int(location.altitude.metersToFeet)
        let meters = Int(location.altitude)
        altitudeLabel.text = "Altitude: \(feet) ft / \(meters) m"
    }

}

// MARK: - Unit Conversions

extension CLLocationDistance {

    var metersToFeet: Double {
        return self * 3.28084
    }


}
