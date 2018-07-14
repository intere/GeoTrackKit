//
//  GeoTrackSerializationTests.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 12/10/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import XCTest
import GeoTrackKit
import CoreLocation

class GeoTrackSerializationTests: XCTestCase {

    func testSerializeTrackName() {
        let track = GeoTrack()
        track.name = "fake"
        XCTAssertEqual(track.name, track.map["name"] as? String)
    }

    func testSerializeTrackDescription() {
        let track = GeoTrack()
        track.description = "fake"
        XCTAssertEqual(track.description, track.map["description"] as? String)
    }

    func testSerializeTrackPoints() {
        let points = [
            CLLocation(latitude: 1.234, longitude: 1.234),
            CLLocation(latitude: 2.345, longitude: 2.345)
        ]
        let track = GeoTrack()
        points.forEach { track.add(location: $0) }
        guard let pointMaps = track.map["points"] as? [[String:Any]] else {
            return XCTFail("Failed to get the right type of data from the map for the points")
        }

        XCTAssertEqual(2, pointMaps.count)
        XCTAssertEqual(points[0].coordinate.latitude, pointMaps.first?["lat"] as? CLLocationDegrees)
        XCTAssertEqual(points[0].coordinate.longitude, pointMaps.first?["lon"] as? CLLocationDegrees)
        XCTAssertEqual(points[1].coordinate.latitude, pointMaps.last?["lat"] as? CLLocationDegrees)
        XCTAssertEqual(points[1].coordinate.longitude, pointMaps.last?["lon"] as? CLLocationDegrees)
    }

    func testSerializeTrackEvents() {
        let events = [
            GeoTrackLocationEvent.startedTracking(message: "fake start"),
            GeoTrackLocationEvent.error(message: "fake error"),
            GeoTrackLocationEvent.custom(message: "fake custom")
        ]

        let track = GeoTrack()
        events.forEach { track.add(event: $0) }
        guard let eventMaps = track.map["events"] as? [[String:Any]] else {
            return XCTFail("Failed to get the right type of data from the map for the events")
        }

        XCTAssertEqual(3, eventMaps.count)
        guard let first = eventMaps.first else {
            return XCTFail("Failed to get the first event from the map array")
        }
        XCTAssertEqual(GeoTrackLocationEvent.EventType.startedTrack.rawValue, first["type"] as? Int)
        XCTAssertNotNil(first["timestamp"])
        XCTAssertEqual("fake start", first["message"] as? String)

        let second = eventMaps[1]
        XCTAssertEqual(GeoTrackLocationEvent.EventType.error.rawValue, second["type"] as? Int)
        XCTAssertNotNil(second["timestamp"])
        XCTAssertEqual("fake error", second["message"] as? String)

        guard let third = eventMaps.last else {
            return XCTFail("Failed to get the third event from the map array")
        }
        XCTAssertEqual(GeoTrackLocationEvent.EventType.custom.rawValue, third["type"] as? Int)
        XCTAssertNotNil(third["timestamp"])
        XCTAssertEqual("fake custom", third["message"] as? String)
    }

}

// MARK: - Deserialization Tests

extension GeoTrackSerializationTests {
    func testDeserializeTrackFile() {
        let reader = TrackReader(filename: "reference-track-1")
        XCTAssertNotNil(reader)
        XCTAssertNotNil(reader.track)

        guard let points = reader.track?.points else {
            return XCTFail("No points")
        }

        XCTAssertTrue(points.count > 0)

        var last: Date?
        for point in points {
            defer {
                last = point.timestamp
            }
            guard let lastTime = last else {
                continue
            }
            XCTAssertTrue(lastTime.timeIntervalSince1970 < point.timestamp.timeIntervalSince1970)
        }
    }

    func testValidateDeserializedTrack() {
        let reader = TrackReader(filename: "reference-track-1")
        guard let track = reader.track else {
            return XCTFail("No track")
        }
        let analyzer = GeoTrackAnalyzer(track: track)
        XCTAssertEqual(0, analyzer.legs.count)
        analyzer.calculate()
        XCTAssertEqual(12, analyzer.legs.count)
    }
}
