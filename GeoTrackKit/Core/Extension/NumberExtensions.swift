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

    init(x1 point1X: Double, y1 point1Y: Double, x2 point2X: Double, y2 point2Y: Double) {
        let startX = min(point1X, point2X)
        let startY = min(point1Y, point2Y)
        let width = abs(point1X - point2X)
        let height = abs(point1Y - point2Y)

        self.init(x: startX, y: startY, width: width, height: height)
    }

}
