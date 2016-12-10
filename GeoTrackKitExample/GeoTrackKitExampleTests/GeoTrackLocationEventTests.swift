//
//  GeoTrackLocationEventTests.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 11/27/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import XCTest
import Quick
import Nimble
import GeoTrackKit
import GeoTrackKitExample

class GeoTrackLocationEventTests: QuickSpec {
    
    override func spec() {
        describe("Factory Creation") {
            it("does create a start tracking event") {
                let event = GeoTrackLocationEvent.startedTracking(message: "hello world")
                expect(event.type).to(equal(GeoTrackLocationEvent.EventType.startedTrack))
                expect(event.timestamp).toNot(beNil())
                expect(event.message).to(equal("hello world"))
                expect(event.index).to(beNil())
            }
        }

        describe("Serialization") {
            it("does serialize to a map") {
                let event = GeoTrackLocationEvent.startedTracking(message: "hello world")
                let map = event.map
                expect(map).toNot(beNil())

                // required values
                expect(map["type"] as? Int).to(equal(event.type.rawValue))
                expect(map["timestamp"] as? Date).to(equal(event.timestamp))

                // optional values
                expect(map["message"] as? String).to(equal(event.message))
                expect(map["index"]).to(beNil())
                expect(map["index"] as? Int).to(beNil())
            }
        }

        describe("Deserialization") {
            it("does not deserialize an empty map") {
                let event = GeoTrackLocationEvent.from(map: [:])
                expect(event).to(beNil())
            }

            it("does deserialize from a map") {
                let date = Date()
                let map: [String:Any] = [
                    "type": GeoTrackLocationEvent.EventType.custom.rawValue,
                    "timestamp": date,
                    "message": "hello world",
                    "index": 12
                ]
                let event = GeoTrackLocationEvent.from(map: map)
                expect(event).toNot(beNil())
                expect(event?.type).to(equal(GeoTrackLocationEvent.EventType.custom))
                expect(event?.timestamp).to(equal(date))
                expect(event?.message).to(equal("hello world"))
                expect(event?.index).to(equal(12))
            }
        }
    }
    
}
