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
    var track: GeoTrack?

    override func viewDidLoad() {
        super.viewDidLoad()

        track = TrackMapViewController.loadFromBundle(filename: "reference-track-1", type: "json")
        assert(track != nil, "There is no track")
        mapView.track = track
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
