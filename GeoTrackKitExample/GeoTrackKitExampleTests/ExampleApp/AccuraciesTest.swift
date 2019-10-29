//
//  AccuraciesTest.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 10/29/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import GeoTrackKit
@testable import GeoTrackKitExample
import XCTest

class AccuraciesTest: XCTestCase {


    func testComputeAccuracies() {
        guard let trackFiles = TrackService.shared.trackFiles else {
            return XCTFail("No track files")
        }
        var accuracies = [TrackAccuracy]()

        for trackFile in trackFiles {
            guard let track = GeoTrack(url: trackFile) else {
                XCTFail("No track")
                continue
            }
            guard let accuracy = track.computeAccuracyReport() else {
                XCTFail("No accuracy report")
                continue
            }
            accuracies.append(TrackAccuracy(trackName: trackFile.lastPathComponent, accuracies: accuracy))
        }

        let sorted = accuracies.sorted { (first, last) -> Bool in
            return first.accuracies.hAccMax > last.accuracies.hAccMax
        }

        print("title, hAccMin, hAccMax, vAccMin, vAccMax")
        sorted.forEach { accuracy in
            print("\(accuracy.trackName), \(accuracy.accuracies.hAccMin), \(accuracy.accuracies.hAccMax), \(accuracy.accuracies.vAccMin), \(accuracy.accuracies.vAccMax)")
        }
    }

}

// MARK: - Sortable Type

struct TrackAccuracy {
    let trackName: String
    let accuracies: GeoTrack.AccuracyReport
}

// MARK: - GeoTrack helpers

extension GeoTrack {

    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        self.init(json: json)
    }

}
