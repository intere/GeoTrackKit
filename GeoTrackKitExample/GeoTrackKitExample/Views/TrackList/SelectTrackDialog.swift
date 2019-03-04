//
//  SelectTrackDialog.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 3/4/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class SelectTrackDialog: TrackListTableViewController {

    var selectedTrack: URL?

    override var tracks: [URL]? {
        get {
            return super.tracks?.filter({ $0 != selectedTrack })
        }
        set {
            super.tracks = newValue
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if navigationController == nil {

        }
        navigationItem.title = "Merge With:"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel(_:)))
    }

    /// Gets you an instance of the SelectTrackDialog from the storyboard.
    ///
    /// - Parameter selectedTrack: The track that's selected
    /// - Returns: A new `SelectTrackDialog`
    class func loadFromStoryboard(selectedTrack: URL) -> SelectTrackDialog {
        let trackDialogVC = UIStoryboard(name: "TrackList", bundle: nil).instantiateViewController(withIdentifier: "SelectTrackDialog") as! SelectTrackDialog
        // swiftlint:disable:previous force_cast
        trackDialogVC.selectedTrack = selectedTrack
        return trackDialogVC
    }

    @IBAction
    func cancel(_ source: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTrack = selectedTrack else {
            return assertionFailure("We need a selected track")
        }
        guard let tracks = tracks, indexPath.row < tracks.count else {
            return assertionFailure("we don't have that many rows!")
        }
        let mergeWithTrack = tracks[indexPath.row]

        guard let mergedTrack = TrackService.shared.mergeTracks(selectedTrack, with: mergeWithTrack) else {
            return assertionFailure("Failed to merge the tracks")
        }

        TrackService.shared.save(track: mergedTrack)
        cancel(self)
    }
}
