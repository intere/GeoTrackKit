//
//  UIGeoTrack.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/28/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

public class UIGeoTrack {
    
    public let track: GeoTrack
    public let analyzer: GeoTrackAnalyzer
    fileprivate var visibleLegs: [GeoTrackAnalyzer.Relative] = []
    
    /// Initializes the UI Model with the provided track.  It then creates the analyzer and calculates the stats for it.
    ///
    /// - Parameter track: The track to initialize with.
    public init(with track: GeoTrack) {
        self.track = track
        analyzer = GeoTrackAnalyzer(track: track)
        analyzer.calculate()
        enableAll()
    }
    
}

// MARK: - API

public extension UIGeoTrack {
    
    /// Tells you if the leg at the specified index is visible or not
    ///
    /// - Parameter index: The index to check for visibility
    /// - Returns: true if it's visible, false if it's not.
    func isVisible(at index: Int) -> Bool {
        guard index < allLegs.count else {
            return false
        }
        return visibleLegs.contains(where: { $0 == allLegs[index] })
    }

    /// Toggles the visibility and sends out a notification
    ///
    /// - Parameters:
    ///   - visible: The visibility to set for the
    ///   - leg: The leg to be toggled
    func set(visibility visible: Bool, for leg: GeoTrackAnalyzer.Relative) {
        if visible {
            guard !visibleLegs.contains(where: { $0 == leg }) else {
                return
            }
            visibleLegs.append(leg)
        } else {
            guard let index = visibleLegs.index(of: leg) else {
                return
            }
            visibleLegs.remove(at: index)
        }
        NotificationCenter.default.post(name: Notification.Name.GeoMapping.legVisibilityChanged, object: nil)
    }
    
    var legs: [GeoTrackAnalyzer.Relative] {
        return visibleLegs
    }
    
    var allLegs: [GeoTrackAnalyzer.Relative] {
        return analyzer.indices
    }
    
}

// MARK: - Helpers

fileprivate extension UIGeoTrack {    
    
    func enableAll() {
        for leg in allLegs {
            visibleLegs.append(leg)
        }
    }
    
}

public extension Notification.Name {
    public struct GeoMapping {
        public static let legVisibilityChanged = Notification.Name(rawValue: "geo.mapping.leg.visibility.changed")
    }
}

extension GeoTrackAnalyzer.Relative: Equatable {
    
    public static func ==(lhs: GeoTrackAnalyzer.Relative, rhs: GeoTrackAnalyzer.Relative) -> Bool {
        guard lhs.index == rhs.index, Int(lhs.altitude) == Int(rhs.altitude), lhs.direction == rhs.direction, lhs.endIndex == rhs.endIndex else {
            return false
        }
        return true
    }
}
