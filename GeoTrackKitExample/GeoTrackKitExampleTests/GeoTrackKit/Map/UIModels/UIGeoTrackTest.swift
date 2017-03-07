//
//  UIGeoTrackTest.swift
//  GeoTrackKitExample
//
//  Created by Internicola, Eric on 3/6/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import XCTest
import GeoTrackKit

class UIGeoTrackTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testModel() {
        guard let track = TrackReader(filename: "reference-track-1").track else {
            return XCTFail("Failed to load test track")
        }
        let model = UIGeoTrack(with: track)
        XCTAssertNotNil(model)
    }
    
}
