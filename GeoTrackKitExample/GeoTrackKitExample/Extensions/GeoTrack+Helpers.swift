//
//  GeoTrack+Helpers.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 10/29/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import CoreLocation
import GeoTrackKit

extension GeoTrack {

    struct AccuracyReport {
        let hAccMin: CLLocationAccuracy
        let hAccMax: CLLocationAccuracy
        let vAccMin: CLLocationAccuracy
        let vAccMax: CLLocationAccuracy
    }

    /// Computes the accuracy report for this track.
    func computeAccuracyReport() -> AccuracyReport? {
        guard points.count > 0, let first = points.first else {
            return nil
        }

        var hAccMin = first.horizontalAccuracy
        var hAccMax = first.horizontalAccuracy
        var vAccMin = first.verticalAccuracy
        var vAccMax = first.verticalAccuracy

        points.forEach { point in
            hAccMin = min(hAccMin, point.horizontalAccuracy)
            hAccMax = max(hAccMax, point.horizontalAccuracy)
            vAccMin = min(vAccMin, point.verticalAccuracy)
            vAccMax = max(vAccMax, point.verticalAccuracy)
        }

        return AccuracyReport(hAccMin: hAccMin, hAccMax: hAccMax, vAccMin: vAccMin, vAccMax: vAccMax)
    }

}
