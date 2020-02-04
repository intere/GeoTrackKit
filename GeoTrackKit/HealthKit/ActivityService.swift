//
//  ActivityService.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 7/27/18.
//

import CoreLocation
import Foundation
import HealthKit


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
/// 1. Ensure we are authorized: `ActivityService.shared.authorize { //...`
/// 2. Query for the workouts: `ActivityService.shared.queryWorkouts { //...`
/// 3. Filter down to workouts that have Routes: `ActivityService.shared.queryRoute(from: workout) { // ...`
/// 4. Get the Track (Route) for a workout: `ActivityService.shared.queryTrack(from: workout) { // ...`
public class ActivityService {

    /// A callback that will tell you success or failure and optionally provide an Error
    public typealias AuthorizationCallback = (Swift.Result<Bool, Error>) -> Void
    /// A callback that will give you back an optional array of HKWorkout objects or an optional Error
    public typealias WorkoutCallback = (Swift.Result<[HKWorkout], Error>) -> Void
    /// A callback that will give you back an optional array of `HKSeriesSample` objects or an optional Error
    public typealias RouteSampleCallback = (Swift.Result<[HKSeriesSample], Error>) -> Void
    /// A callback that will give you back an optional array of CLLocation points (track) or an optional Error
    public typealias TrackCallback = (Swift.Result<[CLLocation], Error>) -> Void


    /// Shared (singleton) instance of the `ActivityService`
    public static let shared = ActivityService()

    /// Is health data avaialble?
    public var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// The HealthKitStore (if available)
    private var store = HKHealthStore()

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
            return callback(.failure(GeoTrackKitError.healthDataNotAvailable))
        }
        guard #available(iOS 11.0, *) else {
            GTError(message: GeoTrackKitError.iOS11Required.humanReadableDescription)
            return callback(.failure(GeoTrackKitError.iOS11Required))
        }

        let allTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.activitySummaryType(),
            HKObjectType.seriesType(forIdentifier: HKWorkoutRouteTypeIdentifier)!
        ])

        store.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            if let error = error {
                callback(.failure(error))
                return GTError(message: "Could not get health store authorization: \(error.localizedDescription)")
            }
            if !success {
                GTError(message: GeoTrackKitError.authNoErrorButUnsuccessful.humanReadableDescription)
                return callback(.failure(GeoTrackKitError.authNoErrorButUnsuccessful))
            }

            GTInfo(message: "Successful authorization")
            callback(.success(success))
        }
    }

}

// MARK: - Workout Queries

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

            if let error = error {
                self.store.stop(query)
                GTError(message: error.localizedDescription)
                return callback(.failure(error))
            }

            // Cast the samples to the HKWorkout type
            guard let samples = samples as? [HKWorkout] else {
                self.store.stop(query)
                return callback(.failure(GeoTrackKitError.notWorkoutType))
            }
            GTInfo(message: "We got \(samples.count) workouts back")
            callback(.success(samples))
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
            return callback(.failure(GeoTrackKitError.iOS11Required))
        }

        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, _, _, error) in

            if let error = error {
                self.store.stop(query)
                return callback(.failure(error))
            }
            guard let routes = samples as? [HKWorkoutRoute] else {
                GTError(message: GeoTrackKitError.workoutWithoutRoutes.humanReadableDescription)
                return callback(.failure(GeoTrackKitError.workoutWithoutRoutes))
            }

            callback(.success(routes))
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
            return callback(.failure(GeoTrackKitError.iOS11Required))
        }

        queryRoute(from: workout) { result in
            switch result {
            case .failure(let error):
                GTError(message: "Failed to load route: \(error.localizedDescription)")
                callback(.failure(error))
            case .success(let routes):
                guard let routes = routes as? [HKWorkoutRoute] else {
                    GTError(message: GeoTrackKitError.workoutWithoutRoutes.humanReadableDescription)
                    return callback(.failure(GeoTrackKitError.workoutWithoutRoutes))
                }

                // keep track of the number of routes that have completed
                var completedCount = 0
                // keep an array of points around for calling back with
                var points = [CLLocation]()

                for route in routes {
                    self.queryPoints(route: route) { result in
                        switch result {
                        case .failure(let error):
                            callback(.failure(error))
                        case .success(let locations):
                            points.append(contentsOf: locations)
                            completedCount += 1

                            // Don't call back until we've got all of the responses back
                            if completedCount == routes.count {
                                callback(.success(points))
                            }
                        }
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
                return callback(.failure(error))
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
            callback(.success(points))
        }

        store.execute(query)
    }
}
