//
//  TrackOverviewTableViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/28/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import HealthKit
import UIKit

class TrackOverviewTableViewController: UITableViewController {

    /// Should the "Save Track Cell" be visible?  (For Demo Track)
    var showSaveTrackCell = false

    /// Sets the Track Model
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

        NotificationCenter.default.addObserver(self, selector: #selector(saveTrack(_:)), name: SaveTrackCell.Constants.saveTrackNotification, object: nil)
    }

}

// MARK: - Notification Handlers

extension TrackOverviewTableViewController {

    @objc
    func saveTrack(_ notification: NSNotification) {
        print("You tapped Save Track")
        guard let model = model else {
            return
        }
        ActivityService.shared.saveTrack(model, for: HKWorkoutActivityType.downhillSkiing)
    }

}

// MARK: - Table view data source

extension TrackOverviewTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return showSaveTrackCell ? 1 : 0

        default:
            guard let analyzer = analyzer else {
                return 0
            }
            return analyzer.legs.count
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 1 else {
            return tableView.dequeueReusableCell(withIdentifier: "SaveTrackCell", for: indexPath)
        }
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
