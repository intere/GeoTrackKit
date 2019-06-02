//
//  BearingAndSlopeTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 6/2/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import CoreLocation
import GeoTrackKit
import XCTest

class BearingAndSlopeTests: XCTestCase {

    func testSlope() {
        let first = CLLocation(x: 3, y: 3, altitude: 5)
        let second = CLLocation(x: 4, y: 4, altitude: 0)

        let slope = first.slope(between: second)

        XCTAssertEqual(74, Int(slope))
    }

    func testBearing() {
        let first = CLLocation(x: 3, y: 3, altitude: 5)
        let second = CLLocation(x: 4, y: 4, altitude: 0)

        let bearing = first.bearing(between: second)

        XCTAssertEqual(44, Int(bearing))
    }

}
