//
//  GeoTrackAnalyzerTests.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/26/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import XCTest
import GeoTrackKit

class GeoTrackAnalyzerTests: XCTestCase {

    var track: GeoTrack?

    override func setUp() {
        let reader = TrackReader(filename: "reference-track-1")
        track = reader.track
    }

    func testPerformanceExample() {
        guard let track = track else {
            return XCTFail("No track")
        }
        self.measure {
            let analyzer = GeoTrackAnalyzer(track: track)
            analyzer.calculate()
        }
    }

//    func testRewriteInOrder() {
//        guard let track = track else {
//            return XCTFail("No track")
//        }
//
//        guard let data = try? JSONSerialization.data(withJSONObject: track.map, options: .prettyPrinted) else {
//            return XCTFail("Failed to serialize the track into data")
//        }
//
//        let path = "/tmp/out.json"
//        do {
//            try data.write(to: URL(fileURLWithPath: path))
//        } catch {
//            XCTFail(error.localizedDescription)
//        }
//    }

    func testAnalyze() {
        guard let track = track else {
            return XCTFail("No track")
        }
        let analyzer = GeoTrackAnalyzer(track: track)
        analyzer.calculate()

        guard let stats = analyzer.stats else {
            return XCTFail("Failed to get stats")
        }
        XCTAssertEqual(6, stats.runs, "Wrong number of runs")
    }

}
