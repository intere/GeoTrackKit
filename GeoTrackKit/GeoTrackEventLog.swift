//
//  GeoTrackEventLog.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import Foundation

// TODO(EGI) provide a better logging implementation (NotificationCenter-based perhaps?)

/// Protocol that is used to define an appender
public protocol GeoTrackLogAppender {
    
    /// The unique identifier for the instance
    var uniqueId: String { get }

    /// The Log output level for this appender
    var logLevel: GeoTrackEvent.Level { get set }

    /// Notifies the appender that an event has occurred.
    ///
    /// - Parameter someEvent: The event that has occurred.
    func logged(event someEvent: GeoTrackEvent)
}


/// The Event Log for GeoTrackKit
public class GeoTrackEventLog {
    public static let shared = GeoTrackEventLog()

    // TODO: Rip this out and create an appender that collects events.
    internal var _eventLog = [GeoTrackEvent]()
    internal var _appenders = [GeoTrackLogAppender]()

    private init() {
        add(appender: GeoTrackConsoleAppender.shared)
    }
}

// MARK: - API

public extension GeoTrackEventLog {

    /// Gets you the event log
    var eventLog: [GeoTrackEvent] {
        return _eventLog
    }

    /// Gets you the list of appenders
    var appenders: [GeoTrackLogAppender] {
        return _appenders
    }

    /// Gets you the most recent event in the event log
    var mostRecentEvent: GeoTrackEvent? {
        guard _eventLog.count > 0 else {
            return nil
        }
        return _eventLog[_eventLog.count-1]
    }

    /// Logs an event
    ///
    /// - Parameter someEvent: The event to add to the log
    func log(event someEvent: GeoTrackEvent) {
        add(event: someEvent)
    }

    /// Adds an appender to the list of appenders
    ///
    /// - Parameter appender: The appender to be added.
    func add(appender: GeoTrackLogAppender) {
        _appenders.append(appender)
    }

    /// Removes an appender from the appender list.
    ///
    /// - Parameter appender: The appender to be removed.
    func remove(appender: GeoTrackLogAppender) {
        for index in 0..<_appenders.count {
            if _appenders[index].uniqueId == appender.uniqueId {
                _appenders.remove(at: index)
                return
            }
        }
    }

    /// Removes all of the appenders that we have loaded
    func removeAllAppenders() {
        _appenders.removeAll()
    }
}

// MARK: - Helpers

internal extension GeoTrackEventLog {

    /// Adds an event to the event log and notifies the appenders.
    ///
    /// - Parameter event: The event that occurred
    func add(event: GeoTrackEvent) {
        _eventLog.append(event)
        for appender in _appenders {
            appender.logged(event: event)
        }
    }
}
