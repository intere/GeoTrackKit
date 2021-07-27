//
//  PointFilterOptions.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/17/19.
//

import CoreLocation
import Foundation

// MARK: - PointFilterOptions

/// Filtering options and the implementation to perform the actual filtering of each point.
open class PointFilterOptions {

    /// A filter that won't filter any points
    public static let nilFilterOptions: PointFilterOptions = {
        let options = PointFilterOptions()
        options.minimumElapsedTime = nil
        options.minimumDistanceBetweenPoints = nil
        options.minimumHorizontalAccuracy = nil
        options.minimumVerticalAccuracy = nil
        return options
    }()

    /// Gets you the default PointFilterOptions
    public static let defaultFilterOptions: PointFilterOptions = {
        return PointFilterOptions()
    }()

    /// Default initializer
    public init() { }

    /// The minimum amount of time that should elapse between any two points
    open var minimumElapsedTime: TimeInterval? = 3

    /// The minimum amount of distance that should elapse between any two points (in meters)
    open var minimumDistanceBetweenPoints: CLLocationDistance? = 10

    /// The minimum horizontal accuracy that a point should have to not be filtered (in meters)
    open var minimumHorizontalAccuracy: CLLocationAccuracy? = 10

    /// The minimum vertical accuracy that a point should have to not be filtered (in meters)
    open var minimumVerticalAccuracy: CLLocationAccuracy? = 10

    /// Performs the filtering of the points, based in the criteria
    /// - Parameters:
    ///   - points: The collection of points to be filtered.
    ///   - lastPoint: The last point that was not filtered.
    open func filter(points: [CLLocation], last lastPoint: CLLocation? = nil) -> [CLLocation] {
        var filtered = [CLLocation]()

        var last = lastPoint

        for point in points {
            defer {
                if !shouldFilter(current: point) {
                    if last == nil {
                        filtered.append(point)
                    }
                    last = point
                }
            }
            guard let last = last, !shouldFilter(last: last, current: point) else { continue }
            filtered.append(point)
        }

        return filtered
    }
}

// MARK: - Implementation

private extension PointFilterOptions {

    /// Should the current point be filtered by the filter criteria?
    /// - Parameters:
    ///   - last: The last point (for time / distance comparisons).
    ///   - current: The current point (for all comparisons).
    func shouldFilter(last: CLLocation, current: CLLocation) -> Bool {
        if shouldFilter(current: current) {
            return true
        }

        // Filter by elapsed time between points
        if let minimumElapsedTime = minimumElapsedTime,
           abs(last.timestamp.timeIntervalSince(current.timestamp)) <= minimumElapsedTime {
            return true
        }

        // Filter by distance between points
        if let minimumDistanceBetweenPoints = minimumDistanceBetweenPoints,
           last.distance(from: current) <= minimumDistanceBetweenPoints {
            return true
        }

        return false
    }

    /// Should the current point be filtered?
    /// - Parameter current: the current point to check.
    func shouldFilter(current: CLLocation) -> Bool {
        // Filter by horizontal accuracy
        if let minimumHorizontalAccuracy = minimumHorizontalAccuracy,
           current.horizontalAccuracy > minimumHorizontalAccuracy {
            return true
        }

        // Filter by vertical accuracy
        if let minimumVerticalAccuracy = minimumVerticalAccuracy,
           current.verticalAccuracy > minimumVerticalAccuracy {
            return true
        }

        return false
    }

}
