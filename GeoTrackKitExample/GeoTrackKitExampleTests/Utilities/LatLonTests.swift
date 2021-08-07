//
//  LatLonTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 10/25/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import CoreLocation
import GeoTrackKit
import XCTest

class LatLonTests: XCTestCase {

    func testDegreesToRadians() {
        XCTAssertEqual(CLLocationDegrees.pi, 180.0.degreesToRadians)
    }

    func testRadiansToDegrees() {
        XCTAssertEqual(180.0, CLLocationDegrees.pi.radiansToDegrees)
    }

    func testLatToMercatorY() {
        XCTAssertEqual(4485399.4, 37.33138973.yFromLatitude, accuracy: 0.1)
    }

    func testLonToMercatorX() {
        XCTAssertEqual(-13584391.4, -122.03066431.xFromLongitude, accuracy: 0.1)
    }

    func testMercatorXToLon() {
        XCTAssertEqual(-122.03066060755671, -13584391.4.lonFromMercatorX, accuracy: 0.1)
    }

    func testMercatorYToLat() {
        XCTAssertEqual(37.33138647537632, 4485399.4.latFromMercatorY, accuracy: 0.1)
    }

}
