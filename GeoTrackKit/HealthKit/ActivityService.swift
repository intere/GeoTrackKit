//
//  ActivityService.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 7/27/18.
//

import Foundation
import HealthKit

public typealias AuthorizationCallback = (Bool, Error?) -> Void
public typealias WorkoutCallback = ([HKWorkout]?, Error?) -> Void

public class ActivityService {

    public static let shared = ActivityService()

    /// Is health data avaialble?
    public var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// The HealthKitStore (if available)
    private var store = HKHealthStore()

    /// Request authorization for health kit data.
    ///
    /// - Parameter callback: the callback that will hand back a boolean (indicating success or failure)
    /// and an optional Error object.
    public func authorize(_ callback: @escaping AuthorizationCallback) {
        let allTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.activitySummaryType()
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

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
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

    public func queryActivities() {

        // Create the date components for the predicate
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            fatalError("*** This should never fail. ***")
        }

        let endDate = NSDate()

        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate as Date, options: []) else {
            fatalError("*** unable to calculate the start date ***")
        }

        let units: NSCalendar.Unit = [.day, .month, .year, .era]

        var startDateComponents = calendar.components(units, from: startDate)
        startDateComponents.calendar = calendar as Calendar

        var endDateComponents = calendar.components(units, from: endDate as Date)
        endDateComponents.calendar = calendar as Calendar

        // Create the predicate for the query

        let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)

        let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summaries, error) -> Void in
            guard summaries != nil else {
                guard error != nil else {
                    fatalError("*** Did not return a valid error object. ***")
                }

                // Handle the error here...

                return
            }
        }

        // Run the query
        store.execute(query)


    }
}
