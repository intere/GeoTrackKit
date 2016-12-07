//
//  GeoTrackConsoleAppender.swift
//  Pods
//
//  Created by Internicola, Eric on 12/7/16.
//
//

import Foundation

/// The Console Appender
public class GeoTrackConsoleAppender {

    public static let shared = GeoTrackConsoleAppender()

    var _logLevel: GeoTrackEvent.Level = .debug

    private init() {}
}

extension GeoTrackConsoleAppender: GeoTrackLogAppender {

    public var uniqueId: String {
        return "GeoTrackConsoleAppender"
    }

    public var logLevel: GeoTrackEvent.Level {
        get {
            return _logLevel
        }
        set {
            _logLevel = newValue
        }
    }

    public func logged(event someEvent: GeoTrackEvent) {
        print(someEvent.string)
    }
}
