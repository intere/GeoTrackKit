//
//  TrackMapViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/27/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class TrackMapViewController: UIViewController {

    @IBOutlet var mapView: GeoTrackMap!
    @IBOutlet var legContainerView: UIView!

    var model: UIGeoTrack? {
        didSet {
            modelUpdated()
        }
    }

    var useDemoTrack = true
    var legVisibleByDefault: Bool {
        return !useDemoTrack
    }

    var tableVC: TrackOverviewTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        if useDemoTrack {
            guard let track = TrackMapViewController.loadFromBundle(filename: "reference-track-1", type: "json") else {
                return assertionFailure("Couldn't load the test track")
            }
            model = UIGeoTrack(with: track)
            assert(model != nil, "There is no track")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(legVisiblityChanged(_:)), name: Notification.Name.GeoMapping.legVisibilityChanged, object: nil)

        modelUpdated()
    }

    /// Loads this view from a storyboard.
    ///
    /// - Returns: A new TrackMapViewController.
    class func loadFromStoryboard(useDemoTrack: Bool = false) -> TrackMapViewController {
        // swiftlint:disable:next force_cast
        let trackVC = UIStoryboard(name: "TrackView", bundle: nil).instantiateViewController(withIdentifier: "TrackMapViewController") as! TrackMapViewController
        trackVC.useDemoTrack = useDemoTrack
        return trackVC
    }

    static func loadFromBundle(filename: String, type: String) -> GeoTrack? {
        guard let path = Bundle(for: TrackMapViewController.self).path(forResource: filename, ofType: type) else {
            assertionFailure("Couldn't load file: \(filename).\(type)")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            assertionFailure("Couldn't read the data from the file: \(url)")
            return nil
        }
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []), let jsonMap = jsonData as? [String: Any] else {
            assertionFailure("Invalid data format in file \(path)")
            return nil
        }

        let track = GeoTrack(json: jsonMap)

        return track
    }

    private func modelUpdated() {
        model?.toggleAll(visibility: legVisibleByDefault)
        guard mapView != nil else {
            return
        }
        mapView.model = model
        tableVC?.model = model

        if !useDemoTrack {
            title = model?.track.name
        }
    }
}

// MARK: - Listeners

extension TrackMapViewController {

    @objc
    func legVisiblityChanged(_ notification: NSNotification) {
        mapView.renderTrack()
    }

}

// MARK: - Navigation

extension TrackMapViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TrackOverviewTableViewController else {
            return
        }
        tableVC = destinationVC
        tableVC?.model = model
    }

}
