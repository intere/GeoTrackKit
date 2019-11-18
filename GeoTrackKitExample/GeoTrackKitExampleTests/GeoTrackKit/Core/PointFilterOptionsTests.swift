//
//  PointFilterOptionsTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 11/17/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import CoreLocation
import GeoTrackKit
import XCTest

class PointFilterOptionsTests: XCTestCase {

    let points = TrackReader(bundleFilename: "reference-track-1").track?.points

}

// MARK: - defaultFilterOptions Tests

extension PointFilterOptionsTests {

    func testDefaultNoFilter() {
        guard let points = points, let first = points.first, let last = points.last else {
            return XCTFail("No points")
        }
        let filter = PointFilterOptions.defaultFilterOptions

        let expected = [first, last]
        let actual = filter.filter(points: expected)

        XCTAssertEqual(2, actual.count)
        XCTAssertEqual(expected, actual)
    }

    func testDefaultFilterByHorizontalAccuracy() {
        let filter = PointFilterOptions.defaultFilterOptions
        guard let minimumHorizontalAccuracy = filter.minimumHorizontalAccuracy else {
            return XCTFail("No minimum horizontal accuracy set")
        }

        guard let points = points, let first = points.first, let last = points.last?.clone(horizontalAccuracy: minimumHorizontalAccuracy + 0.1) else {
            return XCTFail("No points")
        }

        let expected = [first]
        let actual = filter.filter(points: [first, last])

        XCTAssertEqual(expected, actual)
    }

    func testDefaultFilterByVerticalAccuracy() {
        let filter = PointFilterOptions.defaultFilterOptions
        guard let minimumVerticalAccuracy = filter.minimumVerticalAccuracy else {
            return XCTFail("No minimum vertical accuracy set")
        }

        guard let points = points, let first = points.first, let last = points.last?.clone(verticalAccuracy: minimumVerticalAccuracy + 0.1) else {
            return XCTFail("No points")
        }

        let expected = [first]
        let actual = filter.filter(points: [first, last])

        XCTAssertEqual(expected, actual)
    }

    func testDefaultFilterByDistance() {
        let filter = PointFilterOptions.defaultFilterOptions
        guard let minimumDistance = filter.minimumDistanceBetweenPoints else {
            return XCTFail("No minimum distance set")
        }

        guard let points = points, points.count > 2, let first = points.first else {
            return XCTFail("No points")
        }
        let last = points[1]
        guard first.distance(from: last) > minimumDistance else {
            return XCTFail("points are too far from each other for this test")
        }

        let expected = [first]
        let actual = filter.filter(points: [first, last])

        XCTAssertEqual(expected, actual)
    }

    func testDefaultFilterByTimestamp() {
        let filter = PointFilterOptions.defaultFilterOptions
        guard let minimumElapsedTime = filter.minimumElapsedTime else {
            return XCTFail("No minimum vertical accuracy set")
        }

        guard let points = points, let first = points.first, let last = points.last?.clone(timestamp: first.timestamp.addingTimeInterval(minimumElapsedTime/2)) else {
            return XCTFail("No points")
        }

        let expected = [first]
        let actual = filter.filter(points: [first, last])

        XCTAssertEqual(expected, actual)
    }

    func testDefaultFilterAllPoints() {
        let filter = PointFilterOptions.defaultFilterOptions
        guard let points = points, points.count > 0 else {
            return XCTFail("No points")
        }

        let actual = filter.filter(points: points)
        XCTAssertNotEqual(0, actual.count)
    }

}

// MARK: - CLLocation Extension

extension CLLocation {

    func clone(coordinate: CLLocationCoordinate2D? = nil, altitude: CLLocationDistance? = nil, horizontalAccuracy: CLLocationAccuracy? = nil, verticalAccuracy: CLLocationAccuracy? = nil, course: CLLocationDegrees? = nil, speed: CLLocationSpeed? = nil, timestamp: Date? = nil) -> CLLocation {

        let coordinate = coordinate ?? self.coordinate
        let altitude = altitude ?? self.altitude
        let horizontalAccuracy = horizontalAccuracy ?? self.horizontalAccuracy
        let verticalAccuracy = verticalAccuracy ?? self.verticalAccuracy
        let course = course ?? self.course
        let speed = speed ?? self.speed
        let timestamp = timestamp ?? self.timestamp

        return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)
    }
}
