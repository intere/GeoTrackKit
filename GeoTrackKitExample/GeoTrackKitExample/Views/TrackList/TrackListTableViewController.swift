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
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard trackList.count > 0 else {
            return 1
        }
        return trackList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard trackList.count > 0 else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No tracks yet"
            cell.textLabel?.textAlignment = .center
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
        cell.textLabel?.text = trackList[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionConfig = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .normal, title: "Share") { _, _, _  in
                self.shareTrack(indexPath)
                tableView.setEditing(false, animated: true)
            }
        ])

        return actionConfig
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard trackList.count > 0 else {
            return
        }
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

// MARK: - Implementation

extension TrackListTableViewController {

    func shareTrack(_ indexPath: IndexPath) {
        guard let filename = filename(forIndex: indexPath) else {
            return print("No filename")
        }
        let fileURL = URL(fileURLWithPath: filename)
        print("User wants to share file: \(filename)")
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        self.present(activityVC, animated: true, completion: nil)

    }

    func filename(forIndex indexPath: IndexPath) -> String? {
        guard indexPath.row < trackList.count else {
            return nil
        }
        return "\(TrackFileService.shared.documents)/\(trackList[indexPath.row])"
    }
}
