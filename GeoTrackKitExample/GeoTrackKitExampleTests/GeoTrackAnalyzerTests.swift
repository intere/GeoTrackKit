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
            return XCTFail("No track")
        }
        self.measure {
            let analyzer = GeoTrackAnalyzer(track: track)
            analyzer.calculate()
        }
    }
    
    func testRewriteInOrder() {
        let reader = TrackReader(filename: "reference-track-1")
        guard let track = reader.track else {
            return XCTFail("No track")
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: track.map, options: .prettyPrinted) else {
            return XCTFail("Failed to serialize the track into data")
        }
        
        let path = "/tmp/out.json"
        do {
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
