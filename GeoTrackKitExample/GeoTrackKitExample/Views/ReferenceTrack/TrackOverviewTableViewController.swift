//
//  TrackOverviewTableViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/28/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import CoreLocation
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
        tableView.rowHeight = UITableView.automaticDimension
    }

}

// MARK: - Table view data source

extension TrackOverviewTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        guard let analyzer = analyzer else {
            return 0
        }
        return analyzer.legs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackOverviewCell", for: indexPath)
            guard let overviewCell = cell as? TrackOverviewCell else {
                return cell
            }
            overviewCell.analyzer = analyzer

            return overviewCell
        default:
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0, let analyzer = analyzer, indexPath.row < analyzer.legs.count else {
            return
        }
        let leg = analyzer.legs[indexPath.row]

        guard let points = leg.points(from: analyzer.track) else {
            return
        }

        let name = "\(leg.isAscent ? "Ascent" : "Descent") #\(indexPath.row / 2 + 1)"
        let track = GeoTrack(points: points, name: name, description: "")

        let trackMapVC = TrackMapViewController.loadFromStoryboard()
        trackMapVC.model = UIGeoTrack(with: track)
        navigationController?.pushViewController(trackMapVC, animated: true)
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }

}

// MARK: - GeoTrackAnalyzer Helpers

extension Leg {

    var isAscent: Bool {
        return direction == .upward
    }

    var isDescent: Bool {
        return direction == .downward
    }

    var string: String {
        var result = String(index) + " - "
        result += String(endIndex) + ", "
        result += direction.rawValue + ", "
        result += String(Int(altitude)) + "-" + String(Int(endPoint!.altitude)) + ", "
        result += String(Int(altitudeChange.metersToFeet)) + "ft"

        return result
    }

    /// Gets you the points for this leg from the track.
    /// - Parameter track: The track that you want the points for.
    func points(from track: GeoTrack) -> [CLLocation]? {
        guard index < track.points.count, endIndex < track.points.count, index < endIndex else {
            return nil
        }

        return Array(track.points[index...endIndex])
    }

}
