//
//  TrackOverviewTableViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/28/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class TrackOverviewTableViewController: UITableViewController {

    var model: UIGeoTrack? {
        didSet {
            tableView.reloadData()
        }
    }

    var analyzer: GeoTrackAnalyzer? {
        return model?.analyzer
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableViewAutomaticDimension
    }

}

// MARK: - Table view data source

extension TrackOverviewTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let analyzer = analyzer else {
            return 0
        }
        return analyzer.legs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LegSwitchCell", for: indexPath)

        guard let model = model, let legCell = cell as? LegSwitchCell else {
            return cell
        }

        legCell.toggleSwitch.isOn = model.isVisible(at: indexPath.row)
        legCell.label.text = analyzer?.legs[indexPath.row].string
        legCell.indexPath = indexPath
        legCell.model = model

        return cell
    }

}

// MARK: - GeoTrackAnalyzer Helpers

extension Leg {

    var string: String {
        var result = String(index) + " - "
        result += String(endIndex) + ", "
        result += direction.rawValue + ", "
        result += String(Int(altitude)) + "-" + String(Int(endPoint!.altitude)) + ", "
        result += String(Int(altitudeChange)) + "m"

        return result
    }

}
