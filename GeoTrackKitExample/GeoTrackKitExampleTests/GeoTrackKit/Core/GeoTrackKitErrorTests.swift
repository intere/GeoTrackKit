//
//  GeoTrackKitErrorTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 7/29/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

@testable import GeoTrackKit
import XCTest

class GeoTrackKitErrorTests: XCTestCase {

    func testLocalizedDescription() {
        let error = GeoTrackKitError.iOS11Required

        XCTAssertNotNil(GeoTrackKitError.iOS11Required.errorDescription)
        XCTAssertEqual(GeoTrackKitError.iOS11Required.errorDescription, error.localizedDescription)
        XCTAssertEqual(GeoTrackKitError.iOS11Required.errorDescription, error.humanReadableDescription)
    }

}
