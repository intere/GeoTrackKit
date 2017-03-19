//
//  LoggingFunctions.swift
//  Pods
//
//  Created by Internicola, Eric on 12/7/16.
//
//
//  This module contains internal logging functions that can be used anywhere in the framework

import Foundation

// MARK: - Module functions

/// Writes "trace" messages to the log. (very high output potential, and we should probably not have this data in a release build)
///
/// - Parameter message: The message to be written to the Trace facility
func GTTrace(message: String) {
    GeoTrackEventLog.shared.add(event: GeoTrackEvent.trace(message: message))
}

/// Writes "debug" messages to the log. (high output potential, and we should probably not have this data in a release build)
///
/// - Parameter message: The message to be written to the Debug facility.
func GTDebug(message: String) {
    GeoTrackEventLog.shared.add(event: GeoTrackEvent.debug(message: message))
}

/// Writes "info" messages to the log.
///
/// - Parameter message: The message to be written to the Info facility.
func GTInfo(message: String) {
    GeoTrackEventLog.shared.add(event: GeoTrackEvent.info(message: message))
}

/// Writes "warning" messages to the log.
///
/// - Parameter message: The message to be written to the Warn facility.
func GTWarn(message: String) {
    GeoTrackEventLog.shared.add(event: GeoTrackEvent.warn(message: message))
}

/// Writes "error" messages to the log.
///
/// - Parameter message: The message to be written to the Error facility.
func GTError(message: String) {
    GeoTrackEventLog.shared.add(event: GeoTrackEvent.error(message: message))
}
