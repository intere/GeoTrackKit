//
//  TrackListTableViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 8/5/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class TrackListTableViewController: UITableViewController {

    var trackList = [String]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackList = TrackFileService.shared.trackFiles
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
        cell.textLabel?.text = trackList[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filePath = "\(TrackFileService.shared.documents)/\(trackList[indexPath.row])"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return assertionFailure("Failed to open file: \(trackList[indexPath.row])")
        }
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return assertionFailure("Failed to read json content from: \(filePath)")
        }
        guard let jsonMap = jsonData as? [String: Any], let track = GeoTrack.fromMap(map: jsonMap) else {
            return assertionFailure("Wrong data type")
        }

        let map = TrackMapViewController.loadFromStoryboard()
        map.model = UIGeoTrack(with: track)
        map.useDemoTrack = false

        navigationController?.pushViewController(map, animated: true)
    }

}
