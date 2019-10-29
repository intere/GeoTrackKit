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
    private let version = 1

    /// The shared instance
    static let shared = TrackService()

    init() {
        DispatchQueue.global(qos: .background).async {
            self.performMigration()
        }
    }

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

    /// Renames the provided fileUrl to the provided string (and adds a `.track`
    /// suffix if necessary)
    ///
    /// - Parameters:
    ///   - url: The File URL to be renamed.
    ///   - to: The name of the file to rename to.
    func rename(fileUrl url: URL, to newName: String) {
        let name = newName.lowercased().hasSuffix(".track") ? newName : newName + ".track"
        let newFile = URL(fileURLWithPath: name, relativeTo: url.deletingLastPathComponent())

        do {
            try FileManager.default.moveItem(at: url, to: newFile)
        } catch {
            print("ERROR trying to move file from \(url.lastPathComponent) to \(newFile.lastPathComponent)")
        }
    }

    /// Opens the two URLs, reads them as tracks and merges them into a new track.
    ///
    /// - Parameters:
    ///   - first: The URL of the first track.
    ///   - second: The URL of the second track.
    /// - Returns: A new GeoTrack that is the result of merging the two tracks.
    func mergeTracks(_ first: URL, with second: URL) -> GeoTrack? {
        do {
            guard let firstTrack = try GeoTrack.readTrackJsonFile(from: first),
                let secondTrack = try GeoTrack.readTrackJsonFile(from: second) else {
                    assertionFailure("There was an issue reading one of the tracks")
                    return nil
            }
            return merge(firstTrack, with: secondTrack)

        } catch {
            assertionFailure("Error reading one of the tracks: \(error.localizedDescription)")
            return nil
        }
    }

    /// Merges the two provided tracks into a new track.
    ///
    /// - Parameters:
    ///   - firstTrack: The first track to be merged.
    ///   - secondTrack: The second track to be merged.
    /// - Returns: A new track by combining the two provided tracks.
    func merge(_ firstTrack: GeoTrack, with secondTrack: GeoTrack) -> GeoTrack? {
        guard let firstTime = firstTrack.startTime, let secondTime = secondTrack.startTime else {
            assertionFailure("One of the tracks didn't have a start time")
            return nil
        }
        guard firstTime < secondTime else {
            return merge(secondTrack, with: firstTrack)
        }

        var points = firstTrack.points
        points.append(contentsOf: secondTrack.points)

        return GeoTrack(points: points, name: firstTrack.name, description: firstTrack.description)
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
    /// case-insensitive).  The files are sorted by their creation date, descending.
    ///
    /// - Parameter fileExtension: The file extension that you want files for.
    /// - Returns: The list of files matching your extension, or in the case of an
    /// error,
    func documentFiles(withExtension fileExtension: String) -> [URL]? {
        guard let documentsFolder = documentsFolder else {
            return nil
        }

        do {
            let properties: [URLResourceKey] = [.localizedNameKey, .creationDateKey,
                                                .contentModificationDateKey, .localizedTypeDescriptionKey]
            let allFiles = try FileManager.default.contentsOfDirectory(at: documentsFolder, includingPropertiesForKeys: properties, options: [.skipsHiddenFiles])

            var urlDictionary = [URL: Date]()

            for url in allFiles {
                guard let dict = try? url.resourceValues(forKeys: Set(properties)),
                    let creationDate = dict.creationDate else {
                        continue
                }
                guard url.absoluteString.lowercased().hasSuffix(fileExtension.lowercased()) else {
                    continue
                }
                urlDictionary[url] = creationDate
            }

            return urlDictionary.sorted(by: { (first, second) -> Bool in
                return first.value > second.value
            }).map({ $0.key })

        } catch {
            print("ERROR: \(error.localizedDescription)")
            return nil
        }
    }

}

// MARK: - Migration

private extension TrackService {

    private var migratedVersion: Int {
        get {
            return UserDefaults.standard.object(forKey: "TrackService.migratedVersion") as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "TrackService.migratedVersion")
        }
    }

    func performMigration() {
        let oldVersion = migratedVersion

        if oldVersion < 1 {

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
