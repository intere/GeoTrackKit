//
//  GeoTrackAnalyzerTests.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/26/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import XCTest
import GeoTrackKit

class GeoTrackAnalyzerTests: XCTestCase {
    
    func testPerformanceExample() {
        let reader = TrackReader(filename: "reference-track-1")
        guard let track = reader.track else {
            XCTFail("No track")
            return
        }
        self.measure {
            let analyzer = GeoTrackAnalyzer(track: track)
            analyzer.calculate()
        }
    }

}
