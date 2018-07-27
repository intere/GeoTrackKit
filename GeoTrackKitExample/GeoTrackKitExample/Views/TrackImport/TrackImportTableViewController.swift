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

class TrackImportTableViewController: UITableViewController {

    var workouts: [HKWorkout]?

    override func viewDidLoad() {
        super.viewDidLoad()

        ActivityService.shared.authorize { (success, _) in
            guard success else {
                print("We won't be querying activities, no authorization")
                return
            }
            ActivityService.shared.queryWorkouts() { (results, error) in
                if let error = error {
                    return print("We got an error: \(error.localizedDescription)")
                }
                guard let results = results else {
                    return print("We didn't get an error, but we didn't get results either")
                }
                self.workouts = results
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let workout = workouts?[indexPath.row] else {
            return cell
        }

        print("Cell: \(workout.tableDescription)")

        cell.textLabel?.text = workout.tableDescription

        return cell
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

    /// Gets the description for the table
    var tableDescription: String {
        let time = Constants.formatter.string(from: startDate)
        return "\(time): \(source.name) - \(workoutActivityType.description)"
    }

}

// MARK: - HKWorkoutActivityType Helpers

extension HKWorkoutActivityType {

    var description: String {
        switch self {
        case .americanFootball:
            return "americanFootball"

        case .archery:
            return "archery"

        case .australianFootball:
            return "australianFootball"

        case .badminton:
            return "badminton"

        case .baseball:
            return "baseball"

        case .basketball:
            return "basketball"

        case .bowling:
            return "bowling"

        case .boxing:
            return "boxing"

        case .climbing:
            return "climbing"

        case .cricket:
            return "cricket"

        case .crossTraining:
            return "crossTraining"

        case .curling:
            return "curling"

        case .cycling:
            return "cycling"

        case .dance:
            return "dance"

        case .danceInspiredTraining:
            return "danceInspiredTraining"

        case .elliptical:
            return "elliptical"

        case .equestrianSports:
            return "equestrianSports"

        case .fencing:
            return "fencing"

        case .fishing:
            return "fishing"

        case .functionalStrengthTraining:
            return "functionalStrengthTraining"

        case .golf:
            return "golf"

        case .gymnastics:
            return "gymnastics"

        case .handball:
            return "handball"

        case .hiking:
            return "hiking"

        case .hockey:
            return "hockey"

        case .hunting:
            return "hunting"

        case .lacrosse:
            return "lacrosse"

        case .martialArts:
            return "martialArts"

        case .mindAndBody:
            return "mindAndBody"

        case .mixedMetabolicCardioTraining:
            return "mixedMetabolicCardioTraining"

        case .paddleSports:
            return "paddleSports"

        case .play:
            return "play"

        case .preparationAndRecovery:
            return "preparationAndRecovery"

        case .racquetball:
            return "racquetball"

        case .rowing:
            return "rowing"

        case .rugby:
            return "rugby"

        case .running:
            return "running"

        case .sailing:
            return "sailing"

        case .skatingSports:
            return "skatingSports"

        case .snowSports:
            return "snowSports"

        case .soccer:
            return "soccer"

        case .softball:
            return "softball"

        case .squash:
            return "squash"

        case .stairClimbing:
            return "stairClimbing"

        case .surfingSports:
            return "surfingSports"

        case .swimming:
            return "swimming"

        case .tableTennis:
            return "tableTennis"

        case .tennis:
            return "tennis"

        case .trackAndField:
            return "trackAndField"

        case .traditionalStrengthTraining:
            return "traditionalStrengthTraining"

        case .volleyball:
            return "volleyball"

        case .walking:
            return "walking"

        case .waterFitness:
            return "waterFitness"

        case .waterPolo:
            return "waterPolo"

        case .waterSports:
            return "waterSports"

        case .wrestling:
            return "wrestling"

        case .yoga:
            return "yoga"

        case .barre:
            return "barre"

        case .coreTraining:
            return "coreTraining"

        case .crossCountrySkiing:
            return "crossCountrySkiing"

        case .downhillSkiing:
            return "downhillSkiing"

        case .flexibility:
            return "flexibility"

        case .highIntensityIntervalTraining:
            return "highIntensityIntervalTraining"

        case .jumpRope:
            return "jumpRope"

        case .kickboxing:
            return "kickboxing"

        case .pilates:
            return "pilates"

        case .snowboarding:
            return "snowboarding"

        case .stairs:
            return "stairs"

        case .stepTraining:
            return "stepTraining"

        case .wheelchairWalkPace:
            return "wheelchairWalkPace"

        case .wheelchairRunPace:
            return "wheelchairRunPace"

        case .taiChi:
            return "taiChi"

        case .mixedCardio:
            return "mixedCardio"

        case .handCycling:
            return "handCycling"

        case .other:
            return "other"
        }
    }
}
