//
//  AppDelegate.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 11/5/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {

        GeoTrackEventLog.shared.add(appender: EventLogAppender.shared)

        #if DEBUG
        GeoTrackEventLog.shared.add(appender: ConsoleLogAppender.shared)
        #endif

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}
