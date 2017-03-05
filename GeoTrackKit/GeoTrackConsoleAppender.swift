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

    public var logLevel: GeoTrackEvent.Level = .debug

    private init() {}
}

extension GeoTrackConsoleAppender: GeoTrackLogAppender {

    public var uniqueId: String {
        return "GeoTrackConsoleAppender"
    }

//    public var logLevel: GeoTrackEvent.Level {
//        get {
//            return iLogLevel
//        }
//        set {
//            iLogLevel = newValue
//        }
//    }

    public func logged(event someEvent: GeoTrackEvent) {
        print(someEvent.string)
    }
}
