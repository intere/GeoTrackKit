//
//  EventLogAppender.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 7/19/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import GeoTrackKit

/// A Log Appender that collects logs and stores them in an array
/// This implementation allows you to get the most recent event as well
/// as the entire list of events
class EventLogAppender: GeoTrackLogAppender {

    /// The shared instance
    static let shared = EventLogAppender()

    var uniqueId: String {
        return "EventLogAppender"
    }

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
