//
//  XCTestCaseExtensions.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 1/30/20.
//  Copyright © 2020 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import XCTest

extension XCTestCase {

    /// 1,349 points (winter park)
    static var referenceTrack1: GeoTrack? { TrackReader(bundleFilename: "reference-track-1").track }
    /// 1,349 points (winter park)
    var referenceTrack1: GeoTrack? { XCTestCase.referenceTrack1 }

    ///  6,443 points (berthoud pass)
    static var referenceTrack2: GeoTrack? { TrackReader(bundleFilename: "reference-track-2").track }
    ///  6,443 points (berthoud pass)
    var referenceTrack2: GeoTrack? { XCTestCase.referenceTrack2 }

    /// 11,702 points (berthoud pass)
    static var referenceTrack3: GeoTrack? { TrackReader(bundleFilename: "reference-track-3").track }
    /// 11,702 points (berthoud pass)
    var referenceTrack3: GeoTrack? { XCTestCase.referenceTrack3 }

    static var mergeTrack1: GeoTrack? { TrackReader(bundleFilename: "merge1").track }
    var mergeTrack1: GeoTrack? { XCTestCase.mergeTrack1 }

    static var mergeTrack2: GeoTrack? { TrackReader(bundleFilename: "merge2").track }
    var mergeTrack2: GeoTrack? { XCTestCase.mergeTrack2 }


}
