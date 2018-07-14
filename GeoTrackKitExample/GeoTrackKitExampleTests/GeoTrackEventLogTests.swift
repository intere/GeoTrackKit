//
//  GeoTrackEventLog.swift
//  GeoTrackKitExample
//
//  Created by Internicola, Eric on 12/7/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import XCTest
import GeoTrackKit

class GeoTrackEventLogTests: XCTestCase {

    override func tearDown() {
        GeoTrackEventLog.shared.removeAllAppenders()
        GeoTrackEventLog.shared.add(appender: GeoTrackConsoleAppender.shared)
        super.tearDown()
    }

    func testLoadConsoleAppender() {
        XCTAssertEqual(1, GeoTrackEventLog.shared.appenders.count)
        XCTAssertEqual(GeoTrackConsoleAppender.shared.uniqueId, GeoTrackEventLog.shared.appenders.first?.uniqueId)
    }

    func testRemoveAppenders() {
        XCTAssertEqual(1, GeoTrackEventLog.shared.appenders.count)
        GeoTrackEventLog.shared.remove(appender: GeoTrackConsoleAppender.shared)
        XCTAssertEqual(0, GeoTrackEventLog.shared.appenders.count)
    }

    func testLogEventsToAppenders() {
        GeoTrackEventLog.shared.removeAllAppenders()
        let mockAppender = MockAppender()
        GeoTrackEventLog.shared.add(appender: mockAppender)
        GeoTrackEventLog.shared.log(event: GeoTrackEvent.debug(message: "fake event"))

        guard let lastEvent = mockAppender.lastEvent else {
            return XCTFail("We didn't get a last event")
        }
        XCTAssertEqual(lastEvent.level, GeoTrackEvent.Level.debug)
        XCTAssertEqual(lastEvent.message, "fake event")
    }
}
