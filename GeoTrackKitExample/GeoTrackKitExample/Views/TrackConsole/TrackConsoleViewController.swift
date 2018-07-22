//
//  TrackConsoleViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import UIKit
import CoreLocation
import GeoTrackKit

class TrackConsoleViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var accuracyLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var eventLog: UITextView!
    @IBOutlet weak var speedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        eventLog.text = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate(_:)), name: Notification.Name.GeoTrackKit.didUpdateLocations, object: nil)
    }

    @IBAction
    func clickedTrackButton(_ sender: UIButton) {
        handleTrackingClick()
    }
}

// MARK: - Listeners

extension TrackConsoleViewController {

    @objc
    func locationDidUpdate(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.updateLabels()
        }
    }

}

// MARK: - Helpers

fileprivate extension TrackConsoleViewController {

    func handleTrackingClick() {
        if GeoTrackManager.shared.isTracking {
            GeoTrackManager.shared.stopTracking()
        } else {
            GeoTrackManager.shared.startTracking()
        }
        updateButtonText()
        updateLabels()
    }

    func updateButtonText() {
        button.setTitle(GeoTrackManager.shared.isTracking ? "Stop Tracking" : "Start Tracking", for: .normal)
    }

    func updateLabels() {
        updateButtonText()
        let track = GeoTrackManager.shared.track
        updatePointCount(track: track)
        updateEventLog(track: track)

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
        updateSpeed(location: currentPoint)
    }

    func awaitingFix() {
        altitudeLabel.text = "Awaiting fix"
        locationLabel.text = nil
        accuracyLabel.text = nil
        speedLabel.text = nil
        pointsLabel.text = nil
    }

    func notTracking() {
        altitudeLabel.text = "Not Tracking"
        locationLabel.text = nil
        accuracyLabel.text = nil
        speedLabel.text = nil
        pointsLabel.text = nil
    }

    func updateEventLog(track: GeoTrack?) {
        guard let track = track else {
            eventLog.text = ""
            return
        }
        eventLog.text = track.log(withPoints: true).reversed().joined(separator: "\n")
        eventLog.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
    }

    func updatePointCount(track: GeoTrack?) {
        guard let track = track else {
            pointsLabel.text = "no track found"
            return
        }
        pointsLabel.text = "Points: \(track.points.count)"
    }

    /// Updates the speed label
    ///
    /// - Parameter location: The location point to fetch the speed from.
    func updateSpeed(location: CLLocation) {
        let mph = String(format: "%.1f", location.speed.metersPerSecondToMilesPerHour)
        let kmph = String(format: "%.1f", location.speed.metersPerSecondToKilometersPerHour)
        speedLabel.text = "Speed: \(mph) mph / \(kmph) kmph"
    }

    /// Updates the Accuracy label and displays the horizontal and veritcal accuracies.
    ///
    /// - Parameter location: The location point to fetch the accuracies from.
    func updateAccuracy(location: CLLocation) {
        let hAcc = String(format: "%.2f", location.horizontalAccuracy)
        let vAcc = String(format: "%.2f", location.verticalAccuracy)
        accuracyLabel.text = "hAcc/vAcc: \(hAcc) / \(vAcc)"
    }

    /// Updates the Location label.
    ///
    /// - Parameter location: The location to fetch the location from.
    func updateLocation(location: CLLocation) {
        let lat = String(format: "%.5f", location.coordinate.latitude)
        let lon = String(format: "%.5f", location.coordinate.longitude)
        locationLabel.text = "Lat/Lon: \(lat) / \(lon)"
    }

    /// Updates the Altitude label and displays it to the user.
    ///
    /// - Parameter location: The location to fetch the altitude from.
    func updateAltitude(location: CLLocation) {
        let feet = Int(location.altitude.metersToFeet)
        let meters = Int(location.altitude)
        altitudeLabel.text = "Altitude: \(feet) ft / \(meters) m"
    }

}

// MARK: - Unit Conversions

extension CLLocationSpeed {

    /// Converts "meters per second" to "miles per hour".
    var metersPerSecondToMilesPerHour: Double {
        return self * 2.23694
    }

    /// Converts "meters per second" to "kilometers per hour"
    var metersPerSecondToKilometersPerHour: Double {
        return self * 3.6
    }
}

extension CLLocationDistance {

    /// Converts meters to feet
    var metersToFeet: Double {
        return self * 3.28084
    }

}
