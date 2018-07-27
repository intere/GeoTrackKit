//
//  ActivityService.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 7/27/18.
//

import CoreLocation
import Foundation
import HealthKit

public typealias AuthorizationCallback = (Bool, Error?) -> Void
public typealias WorkoutCallback = ([HKWorkout]?, Error?) -> Void
public typealias TrackCallback = ([CLLocation]?, Error?) -> Void

public class ActivityService {

    public static let shared = ActivityService()

    /// Is health data avaialble?
    public var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// The HealthKitStore (if available)
    private var store = HKHealthStore()

    /// A collection of points to call back with.
    private var points = [CLLocation]()

    private var currentRouteQuery: HKQuery?

    /// Request authorization for health kit data.
    ///
    /// - Parameter callback: the callback that will hand back a boolean (indicating success or failure)
    /// and an optional Error object.
    public func authorize(_ callback: @escaping AuthorizationCallback) {
        guard isHealthDataAvailable else {
            GTError(message: "Health data is not available on this device")
            return callback(false, nil)
        }
        guard #available(iOS 11.0, *) else {
            GTError(message: "You must be on iOS 11")
            return callback(false, nil)
        }

        let allTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.activitySummaryType(),
            HKObjectType.seriesType(forIdentifier: HKWorkoutRouteTypeIdentifier)!
            ])

        store.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            defer {
                callback(success, error)
            }
            if let error = error {
                return GTError(message: "Could not get health store authorization: \(error.localizedDescription)")
            }
            if !success {
                return GTError(message: "We didn't get an auth error, but we did not get success either")
            }

            guard self.isHealthDataAvailable else {
                return GTError(message: "We seem to have access, however no health data is available")
            }
            GTInfo(message: "Successful authorization")
        }
    }

    /// Queries HealthKit to get all of your workouts
    ///
    /// - Parameter callback: The block to handle the result (whether it's success or failure)
    public func queryWorkouts(_ callback: @escaping WorkoutCallback) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThan, totalDistance: HKQuantity(unit: HKUnit.meter(), doubleValue: 100))
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: workoutPredicate, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            // 4. Cast the samples as HKWorkout
            guard let samples = samples as? [HKWorkout], error == nil else {
                callback(nil, error)
                return GTError(message: error?.localizedDescription ?? "couldn't get the samples")
            }
            GTInfo(message: "We got \(samples.count) workouts back")
            callback(samples, nil)
        }

        HKHealthStore().execute(query)
    }

    public func queryTrack(from workout: HKWorkout, callback: @escaping TrackCallback) {
        guard #available(iOS 11.0, *) else {
            GTError(message: "You must be running iOS 11 or newer")
            // TODO: Fallback on earlier versions
            return callback(nil, nil)
        }

        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, _, _, error) in

            if let error = error {
                GTError(message: "Failed to load route: \(error.localizedDescription)")
                return callback(nil, error)
            }
            guard let route = samples?.first as? HKWorkoutRoute else {
                GTError(message: "We didn't get back any samples")
                return callback(nil, nil)
            }

            self?.queryPoints(route: route, callback: callback)
        }

        store.execute(routeQuery)

    }

    @available(iOS 11.0, *)
    func queryPoints(route: HKWorkoutRoute, callback: @escaping TrackCallback) {

        // Create the route query.
        currentRouteQuery = HKWorkoutRouteQuery(route: route) { (query, locations, done, error) in

            // This block may be called multiple times.

            if let error = error {
                GTError(message: "Failed to get points for route: \(error.localizedDescription)")
                self.store.stop(query)
                self.currentRouteQuery = nil
                return callback(nil, error)
            }

            guard let locations = locations else {
                return GTError(message: "There were no location points")
            }

            guard done else {
                GTError(message: "We're processing an incomplete track with \(locations.count) points")
                self.points.append(contentsOf: locations)
                return
            }

            callback(locations, nil)
        }

        guard let currentRouteQuery = currentRouteQuery else {
            return
        }
        store.execute(currentRouteQuery)
    }
}
