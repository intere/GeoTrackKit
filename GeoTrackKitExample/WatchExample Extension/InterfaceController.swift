//
//  InterfaceController.swift
//  WatchExample Extension
//
//  Created by Eric Internicola on 10/26/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit
import WatchKit


class InterfaceController: WKInterfaceController {

    var locationManager: CLLocationManager?
    var location: CLLocation? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var map: WKInterfaceMap!
    @IBOutlet weak var getCurrentLocationButton: WKInterfaceButton!
    @IBOutlet weak var latitudeLabel: WKInterfaceLabel!
    @IBOutlet weak var longitudeLabel: WKInterfaceLabel!
    @IBOutlet weak var elevationLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

}

// MARK: - Actions

extension InterfaceController {

    @IBAction
    func tappedGetCurrentLocation() {
        bootstrapLocationManager()
    }

}

// MARK: - CLLocationManagerDelegate

extension InterfaceController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.first else {
            return
        }
        print("Got the location: \(location)")
        locationManager?.stopUpdatingLocation()
        self.location = location
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Auth status: \(status)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("We are authorized")
            locationManager?.requestLocation()

        case .denied, .restricted:
            print("We don't have access")

        case .notDetermined:
            print("access is unknown")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Implementation

private extension InterfaceController {

    func updateUI() {
        guard let location = location else {
            return
        }
        latitudeLabel.setText("\(location.coordinate.latitude)")
        longitudeLabel.setText("\(location.coordinate.longitude)")
        elevationLabel.setText("\(location.altitude)")

        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        map.setRegion(region)
        map.addAnnotation(location.coordinate, with: .red)
    }

    func bootstrapLocationManager() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
        }
    }

}
