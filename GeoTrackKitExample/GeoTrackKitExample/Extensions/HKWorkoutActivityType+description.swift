//
//  HKWorkoutActivityType+description.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 7/25/21.
//  Copyright © 2021 Eric Internicola. All rights reserved.
//

import HealthKit

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

        case .discSports:
            return "discSports"

        case .fitnessGaming:
            return "fitnessGaming"
        case .cardioDance:
            return "Cardio Dance"
        case .socialDance:
            return "Social Dance"
        case .pickleball:
            return "Pickleball"
        case .cooldown:
            return "Cooldown"
        case .other:
            return "other"
        @unknown default:
            return "Unknown workout type"
        }
    }
}
