//
//  TrackFileService.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 8/5/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import Foundation
import GeoTrackKit

class TrackFileService {
    static let shared = TrackFileService()

    var documents: String {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    }

    /// Gets you the track files in the folder
    ///
    /// - Returns: a list of track files in the folder
    var trackFiles: [String] {
        // Full path to documents directory
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path

        // List all contents of directory and return as [String] OR nil if failed
        let fileList = (try? fileManager.contentsOfDirectory(atPath: docs).filter({ $0.hasSuffix(Constants.trackSuffix) })) ?? []
        return fileList.sorted(by: { $0 > $1 })
    }

    /// Saves the provided track to a file.
    ///
    /// - Parameter track: The track to save.
    func save(track: UIGeoTrack) {
        guard let startDate = track.startDate else {
            return assertionFailure("Failed to get start date from track")
        }
        let fileName = Constants.formatter.string(from: startDate) + Constants.trackSuffix
        let fullPath = "\(documents)/\(fileName)"

        guard let jsonData = try? JSONSerialization.data(withJSONObject: track.track.map, options: []) else {
            return assertionFailure("Failed to create JSON Data for track")
        }

        let fileUrl = URL(fileURLWithPath: fullPath)
        do {
            try jsonData.write(to: fileUrl)
            print("Wrote new track file: \(fileUrl.absoluteString)")
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(stoppedTracking(_:)), name: Notification.GeoTrackKit.trackingStopped, object: nil)
    }
}

// MARK: - Event Handlers

extension TrackFileService {

    @objc
    func stoppedTracking(_ notification: NSNotification) {
        guard let track = GeoTrackManager.shared.track else {
            return assertionFailure("Failed to locate a track to save")
        }

        self.save(track: UIGeoTrack(with: track))
    }
}

// MARK: - Implementation

private extension TrackFileService {

    struct Constants {
        static let trackSuffix = "-track.json"
        static let formatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy_MMM_dd_HH_mm_ss"
            return dateFormatter
        }()
    }

    var fileManager: FileManager {
        return FileManager.default
    }

}
