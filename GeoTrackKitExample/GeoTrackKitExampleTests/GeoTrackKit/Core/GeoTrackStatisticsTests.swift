//
//  GeoTrackStatisticsTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 10/12/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import CoreLocation
@testable import GeoTrackKit
import XCTest

class GeoTrackStatisticsTests: XCTestCase {

    var track: GeoTrack?

    override func setUp() {
        super.setUp()
        guard let referenceTrack = TrackReader(filename: "reference-track-1", type: "json").track else {
            return XCTFail("Failed to load the reference track")
        }
        track = referenceTrack
    }

    func testVerifyLegStats() {
        guard let track = track else {
            return XCTFail("No reference track")
        }
        let analyzer = GeoTrackAnalyzer(track: track)
        analyzer.calculate()

        guard let stats = analyzer.stats else {
            return XCTFail("No stats from the track")
        }
        XCTAssertEqual(6, stats.runs, "Wrong number of runs")
        XCTAssertEqual(12, stats.legs, "Wrong number of legs")
        XCTAssertTrue(stats.ascentDistance > 0, "The ascent distance is wrong")
        XCTAssertTrue(stats.descentDistance > 0, "The descent distance is wrong")
        XCTAssertTrue(stats.totalDistance > 0, "The total distance is wrong")
        XCTAssertTrue(stats.verticalAscent > 0, "The vertical ascent is wrong")
        XCTAssertTrue(stats.verticalDescent < 0, "The vertical descent is wrong")
        XCTAssertTrue(stats.totalDistance > 0, "The distance is wrong")
        XCTAssertTrue(stats.maximumAltitude > 0, "The maximum altitude is wrong")
        XCTAssertTrue(stats.maximumSpeed > 0, "The maximum speed is wrong")
        XCTAssertTrue(stats.minimumAltitude < CLLocationDistanceMax, "The minimum altitude is wrong")

        let total = Stat.zero
        var ascentDistance = CLLocationDistance(0)
        var descentDistance = CLLocationDistance(0)
        var verticalAscent = CLLocationDistance(0)
        var verticalDescent  = CLLocationDistance(0)

        for leg in analyzer.legs {
            total.combine(with: leg.stat)
            if leg.direction == .downward {
                descentDistance += leg.stat.distance
                verticalDescent += leg.stat.verticalDelta
            }
            if leg.direction == .upward {
                ascentDistance += leg.stat.distance
                verticalAscent += leg.stat.verticalDelta
            }
        }

        XCTAssertEqual(total.distance, stats.totalDistance, accuracy: 0.01)
        XCTAssertEqual(total.maximumAltitude, stats.maximumAltitude, accuracy: 0.01)
        XCTAssertEqual(total.minimumAltitude, stats.minimumAltitude, accuracy: 0.01)
        XCTAssertEqual(total.maximumSpeed, stats.maximumSpeed, accuracy: 0.01)
        XCTAssertEqual(ascentDistance, stats.ascentDistance, accuracy: 0.01)
        XCTAssertEqual(descentDistance, stats.descentDistance, accuracy: 0.01)
        XCTAssertEqual(verticalAscent, stats.verticalAscent, accuracy: 0.01)
        XCTAssertEqual(abs(verticalDescent), abs(stats.verticalDescent), accuracy: 0.01)
    }

}
