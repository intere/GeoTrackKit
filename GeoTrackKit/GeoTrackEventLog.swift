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
    /// Singleton instance
    public static let shared = GeoTrackEventLog()

    // TODO: Rip out the eventLog and create an appender that collects events.

    /// The Event Log
    fileprivate(set) public var eventLog = [GeoTrackEvent]()
    /// The Appenders
    fileprivate(set) public var appenders = [GeoTrackLogAppender]()

    private init() {
        add(appender: GeoTrackConsoleAppender.shared)
    }
}

// MARK: - API

public extension GeoTrackEventLog {

    /// Gets you the most recent event in the event log
    var mostRecentEvent: GeoTrackEvent? {
        guard eventLog.count > 0 else {
            return nil
        }
        return eventLog[eventLog.count-1]
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
        appenders.append(appender)
    }

    /// Removes an appender from the appender list.
    ///
    /// - Parameter appender: The appender to be removed.
    func remove(appender: GeoTrackLogAppender) {
        for index in 0..<appenders.count where appenders[index].uniqueId == appender.uniqueId {
            appenders.remove(at: index)
        }
    }

    /// Removes all of the appenders that we have loaded
    func removeAllAppenders() {
        appenders.removeAll()
    }
}

// MARK: - Helpers

internal extension GeoTrackEventLog {

    /// Adds an event to the event log and notifies the appenders.
    ///
    /// - Parameter event: The event that occurred
    func add(event: GeoTrackEvent) {
        eventLog.append(event)
        for appender in appenders {
            appender.logged(event: event)
        }
    }
}
