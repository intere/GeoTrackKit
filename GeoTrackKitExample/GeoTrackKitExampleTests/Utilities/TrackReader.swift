//
//  TrackReader.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/26/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import GeoTrackKit


class TrackReader {

    let filename: String
    let type: String

    init(filename: String, type: String = "json") {
        self.filename = filename
        self.type = type
    }

}

// MARK: - Helpers

fileprivate extension TrackReader {

    func loadFromBundle() -> GeoTrack? {
        guard let path = Bundle(for: TrackReader.self).path(forResource: filename, ofType: type) else {
            assertionFailure("Couldn't load file: \(filename).\(type)")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            assertionFailure("Couldn't read the data from the file: \(url)")
            return nil
        }
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []), let jsonMap = jsonData as? [String: Any] else {
            assertionFailure("Invalid data format in file \(path)")
            return nil
        }

        let track = GeoTrack(json: jsonMap)

        return track
    }

}
