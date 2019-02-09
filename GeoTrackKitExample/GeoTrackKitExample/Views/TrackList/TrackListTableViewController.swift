//
//  TrackListTableViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/4/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class TrackListTableViewController: UITableViewController {

    var tracks = TrackService.shared.trackFiles

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TrackCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTrackList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tracks = tracks else {
            return 0
        }
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        guard let tracks = tracks, indexPath.row < tracks.count else {
            return cell
        }
        guard let trackCell = cell as? TrackCell else {
            return cell
        }
        trackCell.track = tracks[indexPath.row]

        return trackCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tracks = tracks, indexPath.row < tracks.count else {
            return
        }
        guard let track = load(trackUrl: tracks[indexPath.row]) else {
            return
        }
        // swiftlint:disable:next force_cast
        let mapVC = UIStoryboard(name: "TrackView", bundle: nil).instantiateViewController(withIdentifier: "TrackMapViewController") as! TrackMapViewController
        mapVC.useDemoTrack = false
        mapVC.model = track

        navigationController?.pushViewController(mapVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .normal, title: "Rename") { _, indexPath in
                self.showRename(for: indexPath)
            }
        ]
    }

    @IBAction
    func didPullToRefresh(_ source: UIRefreshControl) {
        updateTrackList()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }

}

// MARK: - Implementation

extension TrackListTableViewController {

    func showRename(for indexPath: IndexPath) {
        guard let tracks = tracks, indexPath.row < tracks.count else {
            return
        }
        let track = tracks[indexPath.row]

        let inputController = UIAlertController(title: "Rename", message: "Enter the new name for the track file", preferredStyle: .alert)

        inputController.addTextField { textField in
            textField.text = track.filenameNoExtension
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .yes
            textField.clearButtonMode = .always
        }

        inputController.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                guard let textField = inputController.textFields?.first,
                    let filename = textField.text,
                    !filename.isEmpty else {
                    return
                }

                TrackService.shared.rename(fileUrl: track, to: filename)
                self.updateTrackList()
                inputController.dismiss(animated: true, completion: nil)
            }
        )
        inputController.addAction(UIAlertAction(title: "Cancel", style: .cancel))



        present(inputController, animated: true, completion: nil)
    }

    func updateTrackList() {
        tracks = TrackService.shared.trackFiles
        tableView.reloadData()
    }

    func load(trackUrl: URL) -> UIGeoTrack? {
        guard let data = try? Data(contentsOf: trackUrl) else {
            return nil
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json = jsonObject as? [String: Any] else {
            return nil
        }
        guard let track = GeoTrack.fromMap(map: json) else {
            return nil
        }

        return UIGeoTrack(with: track)
    }

}

class TrackCell: UITableViewCell {
    var track: URL? {
        didSet {
            textLabel?.text = track?.filenameNoExtension
        }
    }
}

extension URL {

    var filenameNoExtension: String? {
        return lastPathComponent.removingPercentEncoding?.replacingOccurrences(of: ".track", with: "")
    }

}
