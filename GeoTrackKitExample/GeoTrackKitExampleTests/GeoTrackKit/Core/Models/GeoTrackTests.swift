//
//  GeoTrackTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 11/9/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import XCTest

class GeoTrackTests: XCTestCase {

    var firstTrack = TrackReader(filename: "reference-track-1").track   //  1,349 points (winter park)
    var secondTrack = TrackReader(filename: "reference-track-2").track  //  6,443 points (berthoud pass)
    var thirdTrack = TrackReader(filename: "reference-track-3").track   // 11,702 points (berthoud pass)


    func testIntersectingShortTrack() {
        guard let track = secondTrack else {
            return XCTFail("No track")
        }
        let analyzer = GeoTrackAnalyzer(track: track)
        analyzer.calculate()
        guard let legs = analyzer.splitIntoLegs() else {
            return XCTFail("Failed to split the track into its legs")
        }
        XCTAssertEqual(4, legs.count, "Wrong number of legs")

        let first = legs[0]
        let second = legs[1]

        self.measure {
            XCTAssertTrue(first.intersects(another: second))
        }
    }

    func testNonIntersectingBestCase() {
        guard let firstTrack = firstTrack, let secondTrack = secondTrack else {
            return XCTFail("Failed to get the two tracks")
        }

        self.measure {
            XCTAssertFalse(firstTrack.intersects(another: secondTrack))
        }
    }

    func testNonIntersectingWorstCase() {
        guard let secondTrack = secondTrack, let thirdTrack = thirdTrack else {
            return XCTFail("Failed to get the two tracks")
        }

        self.measure {
            XCTAssertFalse(secondTrack.intersects(another: thirdTrack))
        }
    }

}
