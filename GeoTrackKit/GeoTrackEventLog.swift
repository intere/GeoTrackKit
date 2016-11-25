//
//  GeoTrackEventLog.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import Foundation



func GTTrace(message: String) {
    GeoTrackEventLog.shared.addEvent(GeoTrackEvent.trace(message: message))
}
func GTDebug(message: String) {
    GeoTrackEventLog.shared.addEvent(GeoTrackEvent.debug(message: message))
}
func GTInfo(message: String) {
    GeoTrackEventLog.shared.addEvent(GeoTrackEvent.info(message: message))
}
func GTWarn(message: String) {
    GeoTrackEventLog.shared.addEvent(GeoTrackEvent.warn(message: message))
}
func GTError(message: String) {
    GeoTrackEventLog.shared.addEvent(GeoTrackEvent.error(message: message))
}

// TODO: Delegate

public class GeoTrackEventLog {
    public static let shared = GeoTrackEventLog()

    internal var _eventLog = [GeoTrackEvent]()
}

// MARK: - API

public extension GeoTrackEventLog {

    var eventLog: [GeoTrackEvent] {
        return _eventLog
    }

    var mostRecentEvent: GeoTrackEvent? {
        guard _eventLog.count > 0 else {
            return nil
        }
        return _eventLog[_eventLog.count-1]
    }

    func log(event someEvent: GeoTrackEvent) {
        addEvent(someEvent)
    }

}

// MARK: - Helpers

fileprivate extension GeoTrackEventLog {

    func addEvent(_ event: GeoTrackEvent) {
        _eventLog.append(event)
        print(event.string)
    }
}
