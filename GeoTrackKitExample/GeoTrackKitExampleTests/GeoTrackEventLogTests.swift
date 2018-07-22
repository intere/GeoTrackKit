//
//  GeoTrackEventLog.swift
//  GeoTrackKitExample
//
//  Created by Internicola, Eric on 12/7/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

@testable import GeoTrackKitExample
import XCTest
import GeoTrackKit

class GeoTrackEventLogTests: XCTestCase {

    override func setUp() {
        super.setUp()
        GeoTrackEventLog.shared.removeAllAppenders()
        GeoTrackEventLog.shared.add(appender: EventLogAppender.shared)
        GeoTrackEventLog.shared.add(appender: ConsoleLogAppender.shared)
    }

    override func tearDown() {
        GeoTrackEventLog.shared.removeAllAppenders()
        GeoTrackEventLog.shared.add(appender: EventLogAppender.shared)
        GeoTrackEventLog.shared.add(appender: ConsoleLogAppender.shared)
        super.tearDown()
    }

    func testLoadConsoleAppender() {
        XCTAssertEqual(2, GeoTrackEventLog.shared.appenders.count)
        for appender in GeoTrackEventLog.shared.appenders {
            print("\(appender.uniqueId)")
        }
    }

    func testRemoveAppenders() {
        XCTAssertEqual(2, GeoTrackEventLog.shared.appenders.count)
        GeoTrackEventLog.shared.remove(appender: EventLogAppender.shared)
        XCTAssertEqual(1, GeoTrackEventLog.shared.appenders.count)
        GeoTrackEventLog.shared.remove(appender: ConsoleLogAppender.shared)
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
