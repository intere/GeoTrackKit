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

    var firstTrack = referenceTrack1
    var secondTrack = referenceTrack2
    var thirdTrack = referenceTrack3

}

// MARK: - endsAdjacent

extension GeoTrackTests {

    func testEndsNotAdjacent() {
        guard let firstTrack = firstTrack, let secondTrack = secondTrack else {
            return XCTFail("Failed to get the two tracks")
        }

        self.measure {
            XCTAssertFalse(firstTrack.endsAdjacent(with: secondTrack))
        }
    }

    func testEndsAdjacent() {
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
            XCTAssertTrue(first.endsAdjacent(with: second))
        }
    }

}

// MARK: - Intersects

extension GeoTrackTests {

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
