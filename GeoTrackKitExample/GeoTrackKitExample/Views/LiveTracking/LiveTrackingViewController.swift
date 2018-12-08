//
//  LiveTrackingViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 7/22/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class LiveTrackingViewController: UIViewController {

    @IBOutlet weak var liveMapView: GeoTrackMap!

    var liveTrack: GeoTrack? {
        return GeoTrackManager.shared.track
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(trackUpdated), name: Notification.GeoTrackKit.didUpdateLocations, object: nil)
    }
}

// MARK: - Track Update notifications

extension LiveTrackingViewController {

    @objc
    func trackUpdated() {
        DispatchQueue.main.async { [weak self] in
            guard let liveTrack = self?.liveTrack else {
                return
            }
            self?.liveMapView.model = UIGeoTrack(with: liveTrack)
        }
    }
}
