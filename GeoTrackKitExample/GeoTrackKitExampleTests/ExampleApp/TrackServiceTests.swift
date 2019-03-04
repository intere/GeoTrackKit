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

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    struct TestConstants {
        static let exampleTrack = TrackReader(filename: "reference-track-1").track
        static let trackNameWithDate: String = {
            guard let date = TestConstants.exampleTrack?.startTime else {
                return "2017-01-18_13-18-10.track"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

            return formatter.string(from: date) + ".track"
        }()
        static let testTrackName = "Test Track Name"
    }

}

// MARK: - Track Name

extension TrackServiceTests {

    func testTrackNameFirstTrackWithDate() {
        guard let exampleTrack = TestConstants.exampleTrack else {
            return XCTFail("Failed to load example track")
        }
        exampleTrack.name = ""
        guard let trackName = TrackService.shared.trackName(for: exampleTrack) else {
            return XCTFail("Failed to get a valid name for the track")
        }
        XCTAssertEqual(TestConstants.trackNameWithDate, trackName)
    }

    func testTrackNameFirstTrackWithName() {
        guard let exampleTrack = TestConstants.exampleTrack else {
            return XCTFail("Failed to load example track")
        }
        exampleTrack.name = TestConstants.testTrackName
        guard let trackName = TrackService.shared.trackName(for: exampleTrack) else {
            return XCTFail("Failed to get a valid name for the track")
        }
        XCTAssertEqual(TestConstants.testTrackName + ".track", trackName)
    }

}

// MARK: - Save Tracks

extension TrackServiceTests {

    func testSaveTrackFirstTrackWithDate() {
        guard let exampleTrack = TestConstants.exampleTrack else {
            return XCTFail("Failed to load example track")
        }
        exampleTrack.name = ""

        XCTAssertTrue(TrackService.shared.save(track: exampleTrack), "Failed to save example track")

        guard let trackFiles = TrackService.shared.trackFiles else {
            return XCTFail("Failed to get track files, see logging output")
        }

        XCTAssertNotEqual(0, trackFiles.count, "There are no tracks")

        XCTAssertTrue(trackFiles.contains(where: { url -> Bool in
            url.absoluteString.hasSuffix(TestConstants.trackNameWithDate)
        }))

        trackFiles.forEach { url in
            guard url.absoluteString.hasSuffix(TestConstants.trackNameWithDate) else {
                return
            }
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                XCTFail("Failed to delete test file: \(error.localizedDescription)")
            }
        }
    }

    func testSaveTrackFirstTrackWithName() {
        guard let exampleTrack = TestConstants.exampleTrack else {
            return XCTFail("Failed to load example track")
        }
        exampleTrack.name = TestConstants.testTrackName

        XCTAssertTrue(TrackService.shared.save(track: exampleTrack), "Failed to save example track")

        guard let trackFiles = TrackService.shared.trackFiles else {
            return XCTFail("Failed to get track files, see logging output")
        }

        XCTAssertNotEqual(0, trackFiles.count, "There are no tracks")

        XCTAssertTrue(trackFiles.contains(where: { url -> Bool in
            return url.absoluteString.hasSuffix(urlEscape(string: TestConstants.testTrackName) + ".track")
        }))

        trackFiles.forEach { url in
            guard url.absoluteString.hasSuffix(urlEscape(string: TestConstants.testTrackName) + ".track") else {
                return
            }
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                XCTFail("Failed to delete test file: \(error.localizedDescription)")
            }
        }
    }

}

// MARK: - Implementation

extension TrackServiceTests {

    func urlEscape(string: String) -> String {
        return string.replacingOccurrences(of: " ", with: "%20")
    }

}
