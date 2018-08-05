//
//  ActivityService.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 7/27/18.
//

import CoreLocation
import Foundation
import HealthKit

/// A callback that will tell you success or failure and optionally provide an Error
public typealias AuthorizationCallback = (Bool, Error?) -> Void
/// A callback that will give you back an optional array of HKWorkout objects or an optional Error
public typealias WorkoutCallback = ([HKWorkout]?, Error?) -> Void
/// A callback that will give you back an optional array of `HKSeriesSample` objects or an optional Error
public typealias RouteSampleCallback = ([HKSeriesSample]?, Error?) -> Void
/// A callback that will give you back an optional array of CLLocation points (track) or an optional Error
public typealias TrackCallback = ([CLLocation]?, Error?) -> Void

/// A service that will get you workout activities, with a specific focus on those workouts that have associated
/// routes (think: associated Geospatial data, aka Tracks).
///
/// The Apple Class hierarchies that we're working with here are:
/// ```
/// HKWorkout  -- has 0 or more --> HKWorkoutRoute
/// HKWorkoutRoute -- has 0 or more -> CLLocation
/// ```
/// `HKWorkoutRoute` is a `HKSeriesSample`
///
/// A typical workflow goes like this:
/// 1. Set Access Type: ``
/// 2. Ensure we are authorized: `ActivityService.shared.authorize { //...`
/// 3. Query for the workouts: `ActivityService.shared.queryWorkouts { //...`
/// 4. Filter down to workouts that have Routes: `ActivityService.shared.queryRoute(from: workout) { // ...`
/// 5. Get the Track (Route) for a workout: `ActivityService.shared.queryTrack(from: workout) { // ...`
public class ActivityService {

    /// Access modes for HealthKit data
    ///
    /// - readonly: I only wish to read data from health kit.
    /// - writeonly: I only wish to write data to health kit.
    /// - readwrite: I wish to read and write data to health kit.
    public enum AccessType {
        case readonly
        case writeonly
        case readwrite

        /// Does this access type have read access?
        var readAccess: Bool {
            return [AccessType.readonly, AccessType.readwrite].contains(self)
        }

        /// Does this access type have write access?
        var writeAccess: Bool {
            return [AccessType.writeonly, AccessType.readwrite].contains(self)
        }
    }

    /// Shared (singleton) instance of the `ActivityService`
    public static let shared = ActivityService()

    /// Is health data avaialble?
    public var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// The HealthKitStore (if available)
    private var store = HKHealthStore()

    /// The way in which you wish to access data with HealthKit.
    public var accessType = AccessType.readwrite

}

// MARK: - Authorization API

extension ActivityService {

    /// Request authorization for health kit data.
    ///
    /// - Parameter callback: the callback that will hand back a boolean (indicating success or failure)
    /// and an optional Error object.
    public func authorize(_ callback: @escaping AuthorizationCallback) {
        guard isHealthDataAvailable else {
            GTError(message: GeoTrackKitError.healthDataNotAvailable.humanReadableDescription)
            return callback(false, GeoTrackKitError.healthDataNotAvailable)
        }
        guard #available(iOS 11.0, *) else {
            GTError(message: GeoTrackKitError.iOS11Required.humanReadableDescription)
            return callback(false, GeoTrackKitError.iOS11Required)
        }

        let workoutsWithRoutes = Set([
            HKObjectType.workoutType(),
            HKObjectType.seriesType(forIdentifier: HKWorkoutRouteTypeIdentifier)!
        ])

        let shareMode = accessType.writeAccess ? workoutsWithRoutes : nil
        let readMode = accessType.readAccess ? workoutsWithRoutes : nil

        store.requestAuthorization(toShare: shareMode, read: readMode) { (success, error) in
            if let error = error {
                callback(success, error)
                return GTError(message: "Could not get health store authorization: \(error.localizedDescription)")
            }
            if !success {
                GTError(message: GeoTrackKitError.authNoErrorButUnsuccessful.humanReadableDescription)
                return callback(success, GeoTrackKitError.authNoErrorButUnsuccessful)
            }

            GTInfo(message: "Successful authorization")
            callback(success, error)
        }
    }

}

// MARK: - Write APIs

extension ActivityService {

    /// Saves the provided track to HealthKit
    ///
    /// - Parameter model: the model that contains the points, legs, etc to be
    /// saved in HealthKit.
    public func saveTrack(_ model: UIGeoTrack, for activity: HKWorkoutActivityType) {
        guard let startDate = model.startDate, let endDate = model.endDate, let distance = model.analyzer.stats?.totalDistance else {
            return assertionFailure("No start / end date")
        }
        let elapsed = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let workout = HKWorkout(activityType: activity, start: startDate,
                  end: endDate,
                  duration: elapsed,
                  totalEnergyBurned: nil,
                  totalDistance: HKQuantity(unit: HKUnit.meter(), doubleValue: distance), metadata: nil)

        store.save(workout) { (success, error) in
            if let error = error {
                return GTError(message: error.localizedDescription)
            }
            self.helpSaveTrack(model, workout: workout)
        }
    }

    private func helpSaveTrack(_ model: UIGeoTrack, workout: HKWorkout) {
        var savedLegs = 0
        var failure = false
        for leg in model.allLegs {
            guard let points = model.getPoints(for: leg) else {
                savedLegs += 1
                failure = true
                continue
            }
            let builder = HKWorkoutRouteBuilder(healthStore: store, device: nil)
            builder.insertRouteData(points) { (success, error) in
                if let error = error {
                    savedLegs += 1
                    failure = true
                    return GTError(message: error.localizedDescription)
                }

                builder.finishRoute(with: workout, metadata: model.metadata(for: leg), completion: { (route, error) in
                    savedLegs += 1
                    if let error = error {
                        failure = true
                        return GTError(message: error.localizedDescription)
                    }

                })
            }
        }
    }

}

// MARK: - UIGeoTrack extensions

extension UIGeoTrack {

    func averageSpeed(for leg: Leg) -> CLLocationSpeed {
        guard let points = getPoints(for: leg) else {
            return 0
        }

        return points.reduce(0, { $0 + $1.speed }) / CLLocationSpeed(points.count)
    }

    func metadata(for leg: Leg) -> [String: Any]? {
        var metamap = [String: Any]()

        if #available(iOS 11.2, *) {
            if leg.direction == .downward {
                metamap[HKMetadataKeyElevationDescended] = abs(leg.altitudeChange)
            } else if leg.direction == .upward {
                metamap[HKMetadataKeyElevationAscended] = abs(leg.altitudeChange)
            }
            metamap[HKMetadataKeyMaximumSpeed] = leg.stat.maximumSpeed
            metamap[HKMetadataKeyAverageSpeed] = averageSpeed(for: leg)
        }

        return metamap
    }
}

// MARK: - Read APIs

extension ActivityService {

    /// Queries HealthKit to get all of your workouts
    ///
    /// - Parameters:
    ///   - minimumDistance: The minimum distance (in meters) that a workout must be to show up in your query results (defults to 100)
    ///   - callback: The block to handle the result (whether it's success or failure)
    public func queryWorkouts(minimumDistance: Double = 100, _ callback: @escaping WorkoutCallback) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThan, totalDistance: HKQuantity(unit: HKUnit.meter(), doubleValue: minimumDistance))
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: workoutPredicate, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in

            // Cast the samples to the HKWorkout type
            guard let samples = samples as? [HKWorkout], error == nil else {
                self.store.stop(query)
                GTError(message: error?.localizedDescription ?? "couldn't get the samples")
                return callback(nil, error)
            }
            GTInfo(message: "We got \(samples.count) workouts back")
            callback(samples, nil)
        }

        store.execute(query)
    }

    /// Queries to see if there is a `HKWorkoutRoute` related to the provided workout.
    ///
    /// - Parameters:
    ///   - workout: The workout to query.
    ///   - callback: The callback that will tell you if there is a sample (Route) or not.
    public func queryRoute(from workout: HKWorkout, callback: @escaping RouteSampleCallback) {
        guard #available(iOS 11.0, *) else {
            GTError(message: GeoTrackKitError.iOS11Required.humanReadableDescription)
            return callback(nil, GeoTrackKitError.iOS11Required)
        }

        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, _, _, error) in

            if let error = error {
                self.store.stop(query)
                return callback(nil, error)
            }
            guard let routes = samples as? [HKWorkoutRoute] else {
                GTError(message: GeoTrackKitError.workoutWithoutRoutes.humanReadableDescription)
                return callback(nil, GeoTrackKitError.workoutWithoutRoutes)
            }

            callback(routes, nil)
        }

        store.execute(routeQuery)
    }

    /// Queries for the points related to a workout.
    ///
    /// - Parameters:
    ///   - workout: The workout you want to query for a track from.
    ///   - callback: A callback that will either give you track points (an array of CLLocation) or an error.
    public func queryTrack(from workout: HKWorkout, callback: @escaping TrackCallback) {
        guard #available(iOS 11.0, *) else {
            GTError(message: GeoTrackKitError.iOS11Required.humanReadableDescription)
            return callback(nil, GeoTrackKitError.iOS11Required)
        }

        queryRoute(from: workout) { (routes, error) in
            if let error = error {
                GTError(message: "Failed to load route: \(error.localizedDescription)")
                return callback(nil, error)
            }
            guard let routes = routes as? [HKWorkoutRoute] else {
                GTError(message: GeoTrackKitError.workoutWithoutRoutes.humanReadableDescription)
                return callback(nil, GeoTrackKitError.workoutWithoutRoutes)
            }

            // keep track of the number of routes that have completed
            var completedCount = 0
            // keep a reference in case we need to call back with an error
            var errorResponse: Error?
            // keep an array of points around for calling back with
            var points = [CLLocation]()

            for route in routes {
                self.queryPoints(route: route) { (locations, error) in
                    if let error = error {
                        errorResponse = error
                        return
                    }
                    guard let locations = locations else {
                        return
                    }
                    points.append(contentsOf: locations)
                    completedCount += 1

                    // Don't call back until we've got all of the responses back
                    if completedCount == routes.count {
                        callback(points, errorResponse)
                    }
                }
            }
        }
    }

}

// MARK: - Implementation

extension ActivityService {

    @available(iOS 11.0, *)
    func queryPoints(route: HKWorkoutRoute, callback: @escaping TrackCallback) {

        var points = [CLLocation]()

        // Create the route query.
        let query = HKWorkoutRouteQuery(route: route) { (query, locations, done, error) in

            // This block may be called multiple times.
            if let error = error {
                self.store.stop(query)
                GTError(message: "Failed to get points for route: \(error.localizedDescription)")
                return callback(nil, error)
            }

            guard let locations = locations else {
                return GTError(message: GeoTrackKitError.sampleMissingPoints.humanReadableDescription)
            }

            points.append(contentsOf: locations)
            GTDebug(message: "Added \(locations.count) points - for a total of \(points.count)")

            guard done else {
                return
            }

            GTDebug(message: "Completed importing points")
            callback(points, nil)
        }

        store.execute(query)
    }
}
