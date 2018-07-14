//
//  GeoTrackLocationEventTests.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 11/27/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import XCTest
import GeoTrackKit
import GeoTrackKitExample

class GeoTrackLocationEventTests: XCTestCase {

    func testCreateTrackingEvent() {
        let event = GeoTrackLocationEvent.startedTracking(message: "hello world")
        XCTAssertEqual(event.type, GeoTrackLocationEvent.EventType.startedTrack)
        XCTAssertNotNil(event.timestamp)
        XCTAssertEqual("hello world", event.message)
        XCTAssertNil(event.index)
    }

    func testSerializeTrackingEvent() {
        let event = GeoTrackLocationEvent.startedTracking(message: "hello world")
        let map = event.map
        XCTAssertNotNil(map)

        // required values
        XCTAssertEqual(map["type"] as? Int, event.type.rawValue)
        XCTAssertEqual(map["timestamp"] as? TimeInterval, event.timestamp.msse)

        // optional values
        XCTAssertEqual(map["message"] as? String, event.message)
        XCTAssertNil(map["index"])
    }

    func testDeserializeTrackingEventEmptyMap() {
        let event = GeoTrackLocationEvent.from(map: [:])
        XCTAssertNil(event)
    }

    func testDeserializeTrackingEvent() {
        let date = Date()
        let map: [String:Any] = [
            "type": GeoTrackLocationEvent.EventType.custom.rawValue,
            "timestamp": date.msse,
            "message": "hello world",
            "index": 12
        ]
        let event = GeoTrackLocationEvent.from(map: map)
        XCTAssertNotNil(event)
        XCTAssertEqual(GeoTrackLocationEvent.EventType.custom, event?.type)
        XCTAssertEqual(date.msse, event?.timestamp.msse)
        XCTAssertEqual("hello world", event?.message)
        XCTAssertEqual(12, event?.index)
    }
}
