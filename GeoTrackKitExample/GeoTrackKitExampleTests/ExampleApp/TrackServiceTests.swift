//
//  TrackServiceTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 2/2/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import GeoTrackKit
@testable import GeoTrackKitExample
import XCTest

class TrackServiceTests: XCTestCase {

    var exampleTrack = TrackReader(filename: "reference-track-1").track

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSaveFirstTrackWithDate() {
        guard let exampleTrack = exampleTrack else {
            return XCTFail("Failed to load example track")
        }
        exampleTrack.name = ""
        guard let trackName = TrackService.shared.trackName(for: exampleTrack) else {
            return XCTFail("Failed to get a valid name for the track")
        }
        XCTAssertEqual("2017-01-18_13-18-10.track", trackName)
    }

    func testSaveFirstTrackWithName() {
        guard let exampleTrack = exampleTrack else {
            return XCTFail("Failed to load example track")
        }
        exampleTrack.name = "Winter Park 2017-01-18"
        guard let trackName = TrackService.shared.trackName(for: exampleTrack) else {
            return XCTFail("Failed to get a valid name for the track")
        }
        XCTAssertEqual("Winter Park 2017-01-18.track", trackName)
    }

}
