//
//  MockAppender.swift
//  GeoTrackKitExample
//
//  Created by Internicola, Eric on 12/7/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import GeoTrackKit

class MockAppender: GeoTrackLogAppender {

    var lastEvent: GeoTrackEvent?
    var uniqueId: String { return "MockAppender" }
    var logLevel: GeoTrackEvent.Level = .trace

    func logged(event someEvent: GeoTrackEvent) {
        lastEvent = someEvent
    }

}
