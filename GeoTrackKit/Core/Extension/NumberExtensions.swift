//
//  NumberExtensions.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/9/18.
//

import Foundation

public extension Double {

    /// Converts this (degrees) number into radians
    var radians: Double {
        return self * .pi / 180
    }

    /// Converts this (radians) number into decimal degrees
    var degrees: Double {
        return self * 180 / .pi
    }

    /// Converts this double to a Float
    var float: Float {
        return Float(self)
    }

    /// Converts this double to a CGFloat
    var cgFloat: CGFloat {
        return CGFloat(self)
    }

}

public extension CGRect {

    init(x1: Double, y1: Double, x2: Double, y2: Double) {
        let startX = min(x1, x2)
        let startY = min(y1, y2)
        let width = abs(x1 - x2)
        let height = abs(y1 - y2)

        self.init(x: startX, y: startY, width: width, height: height)
    }

}
