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

    @IBAction
    func didPullToRefresh(_ source: UIRefreshControl) {
        updateTrackList()
    }

//    override func performSegue(withIdentifier identifier: String, sender: Any?) {
//        super.performSegue(withIdentifier: identifier, sender: sender)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        guard let destination = segue.destination as? TrackMapViewController,
//            let sender = sender as? TrackCell, let trackUrl = sender.track else {
//            return
//        }
//
//        destination.model = load(trackUrl: trackUrl)
//    }

}

// MARK: - Implementation

extension TrackListTableViewController {

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
            textLabel?.text = track?.lastPathComponent.removingPercentEncoding
        }
    }
}
