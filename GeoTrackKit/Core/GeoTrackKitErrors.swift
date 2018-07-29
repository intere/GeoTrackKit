//
//  GeoTrackKitErrors.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 7/29/18.


/// A group of some errors that GeoTrackKit provides
enum GeoTrackKitError: LocalizedError {
    case healthDataNotAvailable
    case iOS11Required
    case authNoErrorButUnsuccessful
    case workoutWithoutRoutes
    case sampleMissingPoints

    /// A description of the error
    public var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "Health data is not available on this device"
        case .iOS11Required:
            return "A minimum of iOS 11 is required"
        case .authNoErrorButUnsuccessful:
            return "We didn't get an auth error, but we did not get success either"
        case .workoutWithoutRoutes:
            return "Workout did not have any associated routes"
        case .sampleMissingPoints:
            return "Route called back without any points"
        }
    }

    /// The human readable description for the error.
    var humanReadableDescription: String {
        return errorDescription ?? "Error description not provided"
    }

}
