//
//  EventLotAppender.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 7/19/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import GeoTrackKit

class EventLogAppender: GeoTrackLogAppender {

    var uniqueId = type(of: self)

    var logLevel = GeoTrackEvent.Level.debug

    /// The Event Log
    fileprivate(set) public var eventLog = [GeoTrackEvent]()

    /// Gets you the most recent event in the event log
    var mostRecentEvent: GeoTrackEvent? {
        guard eventLog.count > 0 else {
            return nil
        }
        return eventLog[eventLog.count-1]
    }


    // MARK: - GeoTrackLogAppender API

    func logged(event: GeoTrackEvent) {
        eventLog.append(event)
    }

    
}
