//
//  GeoTrackManagerTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 11/17/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import XCTest

class GeoTrackManagerTests: XCTestCase {

    let mockManager = MockLocationManager()
    var manager: GeoTrackManager?
    var oldPointTimeThreshold: TimeInterval? = GeoTrackManager.oldPointTimeThreshold

    override func setUp() {
        super.setUp()
        GeoTrackManager.shared.reset()
        GeoTrackManager.shared.locationManager = mockManager
        manager = GeoTrackManager.shared as? GeoTrackManager
        GeoTrackManager.shared.shouldStorePoints = true
        oldPointTimeThreshold = GeoTrackManager.oldPointTimeThreshold

        XCTAssertNotNil(manager)
    }

    override func tearDown() {
        GeoTrackManager.oldPointTimeThreshold = oldPointTimeThreshold
        GeoTrackManager.shared.reset()
        GeoTrackManager.shared.pointFilter = .defaultFilterOptions
        GeoTrackManager.shared.shouldStorePoints = true
        super.tearDown()
    }

    func testFliteringAllPoints() {
        guard let manager = manager else {
            return XCTFail("cannot locate the manager")
        }
        GeoTrackManager.shared.pointFilter = .filterAllPoints

        guard let points = referenceTrack1?.points, points.count > 0 else {
            return XCTFail("no points")
        }
        manager.startTracking(type: .whileInUse) { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error.localizedDescription)")
            case .success:
                break
            }
        }
        manager.locationManager(locationServicing: self.mockManager, didChangeAuthorization: .authorizedWhenInUse)
        manager.locationManager(locationServicing: self.mockManager, didUpdateLocations: points)

        if manager.trackPersistence is SQLiteTrackPersisting {
            XCTAssertNil(manager.track)
        } else {
            // There will be no track if there are no points
            XCTAssertNotNil(manager.track)
            XCTAssertEqual(0, manager.track?.points.count)
        }
    }

    func testFilteringDefaults() {
        guard let manager = manager else {
            return XCTFail("cannot locate the manager")
        }
        GeoTrackManager.shared.pointFilter = .defaultFilterOptions
        GeoTrackManager.oldPointTimeThreshold = nil

        guard let points = referenceTrack1?.points, points.count > 0 else {
            return XCTFail("no points")
        }

        manager.startTracking(type: .whileInUse) { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error.localizedDescription)")
            case .success:
                break
            }
        }

        manager.locationManager(locationServicing: self.mockManager, didChangeAuthorization: .authorizedWhenInUse)
        manager.locationManager(locationServicing: self.mockManager, didUpdateLocations: points)

        XCTAssertNotEqual(0, manager.track?.points.count ?? 0)
        XCTAssertTrue((manager.track?.points.count ?? points.count) < points.count)
    }

}

// MARK: - PointFilterOptions extension

extension PointFilterOptions {

    static var filterAllPoints: PointFilterOptions {
        let filter = PointFilterOptions()
        filter.minimumDistanceBetweenPoints = 100000000
        filter.minimumElapsedTime = 100000000
        filter.minimumVerticalAccuracy = 0
        filter.minimumHorizontalAccuracy = 0

        return filter
    }

}

// MARK: - MockLocationManager

class MockLocationManager: LocationServicing {
    func requestAlwaysAuthorization() {

    }

    func requestWhenInUseAuthorization() {

    }

    func startUpdatingLocation() {

    }

    func stopUpdatingLocation() {

    }

}
