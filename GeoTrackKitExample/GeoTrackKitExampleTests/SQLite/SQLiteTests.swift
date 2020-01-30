//
//  SQLiteTests.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 1/30/20.
//  Copyright © 2020 Eric Internicola. All rights reserved.
//

@testable import GeoTrackKit
import XCTest

class SQLiteTests: XCTestCase {

    override func setUp() {
        super.setUp()

        guard let databasePath = SQLiteService.shared.databasePath else {
            return XCTFail("Failed to get the databasePath")
        }
        if FileManager.default.fileExists(atPath: databasePath.path) {
            do {
                try FileManager.default.removeItem(at: databasePath)
            } catch {
                XCTFail("error: \(error.localizedDescription)")
            }
        }
    }

    override class func tearDown() {
        guard let databasePath = SQLiteService.shared.databasePath else {
            return XCTFail("Failed to get the databasePath")
        }
        if FileManager.default.fileExists(atPath: databasePath.path) {
            do {
                try FileManager.default.removeItem(at: databasePath)
            } catch {
                XCTFail("error: \(error.localizedDescription)")
            }
        }
    }

    func testConfigure() throws {
        try SQLiteService.shared.configureDatabase()
    }

    func testInsertPoints() throws {
        try SQLiteService.shared.configureDatabase()

        guard let track = referenceTrack1 else {
            return XCTFail("Failed to read track")
        }

        try track.points.forEach { point in
            try SQLiteService.shared.insert(location: point)
        }

        print("Inserted \(track.points.count) points")
    }

    func testMeasureInsertPoints() throws {
        try SQLiteService.shared.configureDatabase()

        guard let track = referenceTrack1 else {
            return XCTFail("Failed to read track")
        }

        measure {
            do {
                try track.points.forEach { point in
                    try SQLiteService.shared.insert(location: point)
                }
            } catch {
                XCTFail("Failed to insert points")
            }
        }
    }

    func testClearPoints() throws {
        try SQLiteService.shared.configureDatabase()

        guard let track = referenceTrack1 else {
            return XCTFail("Failed to read track")
        }

        try track.points.forEach { point in
            try SQLiteService.shared.insert(location: point)
        }

        try SQLiteService.shared.clearPoints()

        let points = try SQLiteService.shared.getPoints()
        XCTAssertEqual(0, points.count)
    }

    func testFetchPoints() throws {
        try SQLiteService.shared.configureDatabase()

        guard let track = referenceTrack1 else {
            return XCTFail("Failed to read track")
        }

        try track.points.forEach { point in
            try SQLiteService.shared.insert(location: point)
        }

        let points = try SQLiteService.shared.getPoints()
        XCTAssertEqual(track.points.count, points.count)
    }

}
