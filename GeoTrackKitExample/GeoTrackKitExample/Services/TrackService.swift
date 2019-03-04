//
//  TrackService.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/2/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import Foundation
import GeoTrackKit

/// Responsible for getting you the track files in the user's directory.
class TrackService {
    /// The shared instance
    static let shared = TrackService()

    /// Gets you all of the track files
    var trackFiles: [URL]? {
        return documentFiles(withExtension: ".track")
    }


    /// Saves the provided track to the user's documents folder.
    ///
    /// - Parameter track: the track to be saved.
    func save(track: GeoTrack) -> Bool {
        guard track.points.count > 1 else {
            print("ERROR: there must be more than 1 point to save a track")
            return false
        }
        guard let documentsFolder = documentsFolder else {
            print("ERROR: couldn't get the documents folder url")
            return false
        }
        guard let trackName = self.trackName(for: track)?.trackNameToFileSystemName else {
            print("ERROR: couldn't determine a track name for the track")
            return false
        }

        let filePath: URL
        if trackName.lowercased().hasSuffix(".track") {
            filePath = URL(fileURLWithPath: trackName, isDirectory: false, relativeTo: documentsFolder)
        } else {
            filePath = URL(fileURLWithPath: "\(trackName).track", isDirectory: false, relativeTo: documentsFolder)
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: track.map, options: .prettyPrinted)
            try data.write(to: filePath, options: .atomicWrite)
            return true
        } catch {
            print("ERROR trying to save track: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - Implementation

extension TrackService {

    /// Gets you the documents folder
    var documentsFolder: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    /// Gets you the name of the track (using it's start time).
    ///
    /// - Parameter track: the track to get the name for.
    /// - Returns: A string that represents the name of the track.
    func trackName(for track: GeoTrack) -> String? {
        if track.name.isEmpty {
            guard let date = track.startTime else {
                return nil
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

            return formatter.string(from: date) + ".track"
        }
        return track.name + ".track"
    }

    /// Gives you back all of the files that match the provided extension (ends with,
    /// case-insensitive).
    ///
    /// - Parameter fileExtension: The file extension that you want files for.
    /// - Returns: The list of files matching your extension, or in the case of an
    /// error,
    func documentFiles(withExtension fileExtension: String) -> [URL]? {
        guard let documentsFolder = documentsFolder else {
            return nil
        }

        do {
            let allFiles = try FileManager.default.contentsOfDirectory(at: documentsFolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return allFiles.filter { fileUrl in
                return fileUrl.absoluteString.lowercased().hasSuffix(fileExtension.lowercased())
            }
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return nil
        }
    }

}

// MARK: - Track extension

extension GeoTrack {

    /// Gets you the start time of the track
    var startTime: Date? {
        guard let firstPoint = points.first else {
            return nil
        }
        return firstPoint.timestamp
    }

}
