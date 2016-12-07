//
//  GeoTrackEventLog.swift
//  GeoTrackKitExample
//
//  Created by Internicola, Eric on 12/7/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import XCTest
import Quick
import Nimble
import GeoTrackKit

class GeoTrackEventLogTests: QuickSpec {

    override func spec() {
        describe("Appenders") {
            afterEach {
                GeoTrackEventLog.shared.removeAllAppenders()
                GeoTrackEventLog.shared.add(appender: GeoTrackConsoleAppender.shared)
            }

            it("does load the Console Appender") {
                expect(GeoTrackEventLog.shared.appenders.count).to(equal(1))
                expect(GeoTrackEventLog.shared.appenders.first).to(be(GeoTrackConsoleAppender.shared))
            }

            it("does remove appenders") {
                GeoTrackEventLog.shared.remove(appender: GeoTrackConsoleAppender.shared)
                expect(GeoTrackEventLog.shared.appenders.count).to(equal(0))
            }

            it("does log events to the appenders") {
                GeoTrackEventLog.shared.removeAllAppenders()
                let mockAppender = MockAppender()
                GeoTrackEventLog.shared.add(appender: mockAppender)
                GeoTrackEventLog.shared.log(event: GeoTrackEvent.debug(message: "fake event"))
                guard let lastEvent = mockAppender.lastEvent else {
                    fail("We didn't get a last event")
                    return
                }
                expect(lastEvent.level).to(equal(GeoTrackEvent.Level.debug))
                expect(lastEvent.message).to(equal("fake event"))
            }
        }
    }
    
}

