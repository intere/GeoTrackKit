//
//  TrackImportTableViewController.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 7/27/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import HealthKit
import UIKit

/// A ViewController for a table that will show you a list of workouts that have routes associated with them.
class TrackImportTableViewController: UITableViewController {

    /// The workouts that the table will show
    var workouts = [HKWorkout]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTracksFromWorkouts()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard indexPath.row < workouts.count else {
            return cell
        }
        let workout = workouts[indexPath.row]

        cell.textLabel?.text = workout.tableDescription

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadTrack(from: indexPath) { track in
            guard let track = track else {
                return assertionFailure("There was an error with the track")
            }

            DispatchQueue.main.async { [weak self] in
                let mapView = TrackMapViewController.loadFromStoryboard()
                mapView.model = UIGeoTrack(with: track)
                self?.navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .normal, title: "Import") { _, indexPath in
                self.loadTrack(from: indexPath) { track in
                    guard let track = track else {
                        return assertionFailure("There was an error with the track")
                    }
                    assert(TrackService.shared.save(track: track))
                }
            }
        ]
    }

}

// MARK: - Implementation

extension TrackImportTableViewController {

    typealias TrackCallback = (GeoTrack?) -> Void

    /// Loads a track for the activity at the provided indexPath.
    ///
    /// - Parameters:
    ///   - indexPath: The indexPath that you want the workout track from.
    ///   - completion: The callback that hands you back the track or nil if there was an issue.
    func loadTrack(from indexPath: IndexPath, completion: @escaping TrackCallback) {
        guard indexPath.row < workouts.count else {
            completion(nil)
            return
        }

        let workout = workouts[indexPath.row]

        ActivityService.shared.queryTrack(from: workout) { (locations, error) in
            if let error = error {
                completion(nil)
                return print("Error getting points: \(error.localizedDescription)")
            }
            guard let locations = locations else {
                completion(nil)
                return print("Locations came back empty")
            }

            let track = GeoTrack(points: locations, name: workout.tableDescription, description: workout.description)
            completion(track)
        }
    }

    /// Loads the tracks from the workouts for you.
    func loadTracksFromWorkouts() {
        workouts.removeAll()
        ActivityService.shared.authorize { (success, _) in
            guard success else {
                print("We won't be querying activities, no authorization")
                return
            }
            ActivityService.shared.queryWorkouts { (results, error) in
                if let error = error {
                    return print("We got an error: \(error.localizedDescription)")
                }
                guard let results = results else {
                    return print("We didn't get an error, but we didn't get results either")
                }

                results.forEach { workout in
                    // If the workout has a route, we'll add it to the table
                    ActivityService.shared.queryRoute(from: workout) { [weak self] (routes, _) in
                        guard let strongSelf = self, let routes = routes, routes.count > 0 else {
                            return
                        }
                        strongSelf.workouts.append(workout)
                        strongSelf.workouts = strongSelf.workouts.sorted(by: { $0.startDate > $1.startDate })

                        DispatchQueue.main.async { [weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

}

// MARK: - HKWorkout stuff

extension HKWorkout {

    struct Constants {
        static var formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    }

    /// Gets the description of this `HKWorkout` to display in the table
    var tableDescription: String {
        let time = Constants.formatter.string(from: startDate)
        if let burned = totalEnergyBurned {
            let calories = Int(burned.doubleValue(for: HKUnit.kilocalorie()))
            return "\(time): \(sourceRevision.source.name) - \(workoutActivityType.description) - \(calories) Cal"
        } else {
            return "\(time): \(sourceRevision.source.name) - \(workoutActivityType.description)"
        }
    }

}
