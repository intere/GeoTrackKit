//
//  GeoTrackSerializationTests.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 12/10/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import XCTest
import Quick
import Nimble
import GeoTrackKit
import CoreLocation

class GeoTrackSerializationTests: QuickSpec {

    override func spec() {
        describe("serialization") {

            it("does serialize the track name") {
                let track = GeoTrack()
                track.name = "fake"
                expect(track.map["name"] as? String).to(equal("fake"))
            }

            it("does serialize the track description") {
                let track = GeoTrack()
                track.description = "fake"
                expect(track.map["description"] as? String).to(equal("fake"))
            }

            it("does serialize the track points") {
                let points = [
                    CLLocation(latitude: 1.234, longitude: 1.234),
                    CLLocation(latitude: 2.345, longitude: 2.345)
                ]
                let track = GeoTrack()
                points.forEach { track.add(location: $0) }
                guard let pointMaps = track.map["points"] as? [[String:Any]] else {
                    fail("Failed to get the right type of data from the map for the points")
                    return
                }
                expect(pointMaps.count).to(equal(2))
                expect(pointMaps.first?["lat"] as? CLLocationDegrees).to(equal(1.234))
                expect(pointMaps.first?["lon"] as? CLLocationDegrees).to(equal(1.234))
                expect(pointMaps.last?["lat"] as? CLLocationDegrees).to(equal(2.345))
                expect(pointMaps.last?["lon"] as? CLLocationDegrees).to(equal(2.345))

            }

            it("does serialze the track events") {
                let events = [
                    GeoTrackLocationEvent.startedTracking(message: "fake start"),
                    GeoTrackLocationEvent.error(message: "fake error"),
                    GeoTrackLocationEvent.custom(message: "fake custom")
                ]
                let track = GeoTrack()
                events.forEach { track.add(event: $0) }
                guard let eventMaps = track.map["events"] as? [[String:Any]] else {
                    fail("Failed to get the right type of data from the map for the events")
                    return
                }
                expect(eventMaps.count).to(equal(3))
                guard let first = eventMaps.first else {
                    fail("Failed to get the first event from the map array")
                    return
                }
                expect(first["type"] as? Int).to(equal(GeoTrackLocationEvent.EventType.startedTrack.rawValue))
                expect(first["timestamp"]).toNot(beNil())
                expect(first["message"] as? String).to(equal("fake start"))

                let second = eventMaps[1]
                expect(second["type"] as? Int).to(equal(GeoTrackLocationEvent.EventType.error.rawValue))
                expect(second["timestamp"]).toNot(beNil())
                expect(second["message"] as? String).to(equal("fake error"))

                guard let third = eventMaps.last else {
                    fail("Failed to get the third event from the map array")
                    return
                }
                expect(third["type"] as? Int).to(equal(GeoTrackLocationEvent.EventType.custom.rawValue))
                expect(third["timestamp"]).toNot(beNil())
                expect(third["message"] as? String).to(equal("fake custom"))
            }
        }
    }

}
