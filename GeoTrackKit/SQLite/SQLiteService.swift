//
//  SQLiteService.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 1/28/2020.
//

import CoreLocation
import Foundation
import SQLite

public class SQLiteService {
    static let shared = SQLiteService()

    /// The name of the database - defaults to "track-points.sqlite3"
    public var databaseName = "track-points.sqlite3"
    private var pointsTable = PointsTable()
    private var connection: Connection?

    /// Configures the database, including the connection
    public func configureDatabase() throws {
        guard let databasePath = databasePath else {
            throw SQLiteServiceError.databasePathNotFound
        }
        let exists = FileManager.default.fileExists(atPath: databasePath.path)

        try connection = Connection(databasePath.path)

        guard let connection = connection else {
            return assertionFailure("No database connection")
        }

        // If the database doesn't yet exist, then we need to create the schema:
        if !exists {
            try pointsTable.addSchema(to: connection)
        }
    }

    /// Inserts a location point into the table.
    /// - Parameter location: The location to insert into the table.
    public func insert(location: CLLocation) throws {
        guard let connection = connection else {
            throw SQLiteServiceError.databaseNotConfigured
        }
        try pointsTable.insert(location: location, into: connection)
    }

    /// Clears all of the points from the table.
    public func clearPoints() throws {
        guard let connection = connection else {
            throw SQLiteServiceError.databaseNotConfigured
        }
        let delete = pointsTable.table.delete()
        try connection.run(delete)
    }

    /// Fetches all of the points from the database.
    public func getPoints() throws -> [CLLocation] {
        guard let connection = connection else {
            throw SQLiteServiceError.databaseNotConfigured
        }

        return try pointsTable.fetchPoints(from: connection)
    }
}

// MARK: - PointsTable

struct PointsTable {
    let table = Table("points")
    let lat = Expression<CLLocationDegrees>("latitude")
    let lon = Expression<CLLocationDegrees>("longitude")
    let alt = Expression<CLLocationDistance>("altitude")
    let course = Expression<CLLocationDegrees>("course")
    let hAcc = Expression<CLLocationDistance>("horizontalAccuracy")
    let vAcc = Expression<CLLocationDistance>("verticalAccuracy")
    let speed = Expression<CLLocationSpeed>("speed")
    let timestamp = Expression<Date>("timestamp")

    /// Executes a "CREATE TABLE" schema statement against the provided connection.
    /// - Parameter connection: The connection to execute the statement against.
    func addSchema(to connection: Connection) throws {
        let create = table.create { builder in
            builder.column(lat)
            builder.column(lon)
            builder.column(alt)
            builder.column(course)
            builder.column(hAcc)
            builder.column(vAcc)
            builder.column(speed)
            builder.column(timestamp)
        }
        try connection.run(create)
    }

    /// Inserts the provided location into the database.
    /// - Parameters:
    ///   - location: The location you would like inserted into the database.
    ///   - connection: The database connection to execute the insert statement on.
    func insert(location: CLLocation, into connection: Connection) throws {
        let insert = table.insert(
            lat <- location.coordinate.latitude,
            lon <- location.coordinate.longitude,
            alt <- location.altitude,
            course <- location.course,
            hAcc <- location.horizontalAccuracy,
            vAcc <- location.verticalAccuracy,
            speed <- location.speed,
            timestamp <- location.timestamp
        )
        try connection.run(insert)
    }

    /// Fetches the points from the database.
    /// - Parameter connection: The connection to the database.
    func fetchPoints(from connection: Connection) throws -> [CLLocation] {
        let select = table.order(timestamp.asc).select(table[*])
        let rows = try connection.prepare(select)

        return rows.map { row in
            let date = Date(timeIntervalSince1970: row[timestamp].timeIntervalSince1970)
            return CLLocation(coordinate:
                CLLocationCoordinate2D(
                    latitude: row[lat].datatypeValue,
                    longitude: row[lon].datatypeValue),
                              altitude: row[alt].datatypeValue,
                              horizontalAccuracy: row[hAcc].datatypeValue,
                              verticalAccuracy: row[vAcc].datatypeValue,
                              course: row[course].datatypeValue,
                              speed: row[speed].datatypeValue,
                              timestamp: date)
        }
    }
}

// MARK: - Implementation

extension SQLiteService {

    /// Gets you the path of the documents directory
    var documentsFolder: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    /// Gets you the path for the database
    var databasePath: URL? {
        guard let documentsFolder = documentsFolder else {
            return nil
        }

        return URL(fileURLWithPath: databaseName, relativeTo: documentsFolder)
    }
}

// MARK: - SQLiteServiceError

enum SQLiteServiceError: Error {
    case databasePathNotFound
    case databaseNotConfigured
}
