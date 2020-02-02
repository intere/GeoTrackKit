//
//  SQLiteTrackPersisting.swift
//  Pods
//
//  Created by Eric Internicola on 2/1/20.
//

import CoreLocation

/// This track persistence manager uses a SQLite DB to store all of the points.  They are only loaded
/// into memory when you ask for the `track`.  The `track` in this case, is ephemeral.
public class SQLiteTrackPersisting: TrackPersisting {
    public static let shared = SQLiteTrackPersisting()

    public var track: GeoTrack? {
        do {
            let points = try SQLiteService.shared.getPoints()
            guard points.count > 0 else {
                return nil
            }
            return GeoTrack(points: points)
        } catch {
            elog("failed to get the points: \(error.localizedDescription)")
        }
        return nil
    }

    public var lastPoint: CLLocation? {
        do {
            return try SQLiteService.shared.getMostRecentPoint()
        } catch {
            elog("Failed to get most recent point: \(error.localizedDescription)")
        }
        return nil
    }

    public func startTracking() {
        reset()
    }

    public func addPoints(_ locations: [CLLocation]) {
        do {
            try locations.forEach {
                try SQLiteService.shared.insert(location: $0)
            }
        } catch {
            elog("failed to handle the new points: \(error.localizedDescription)")
        }
    }

    public func reset() {
        do {
            try SQLiteService.shared.clearPoints()
        } catch {
            elog("failed to clear points: \(error.localizedDescription)")
        }
    }

}
