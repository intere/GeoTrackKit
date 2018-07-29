//
//  GeoTrackKitErrors.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 7/29/18.

public protocol GenericError: LocalizedError {

    /// For human-friendly error messages, use humanReadableDescription property.
    ///
    /// - Note: Default implementation returns `errorDescription`.
    var humanReadableDescription: String { get }

}

// MARK: - Default Implementation

public extension GenericError {

    var humanReadableDescription: String {
        return errorDescription ?? "Error description not provided"
    }

}

enum GeoTrackKitError: GenericError {
    case healthDataNotAvailable
    case iOS11Required
    case authNoErrorButUnsuccessful
    case workoutWithoutRoutes
    case sampleMissingPoints

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

}
