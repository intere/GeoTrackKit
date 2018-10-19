//
//  GeoTrackMap.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 2/27/17.
//
//

import MapKit
import CoreLocation

/// This class provides you an easy way to visualize your track on a map.  You can configure the unknown, ascent and descent colors.  They have sensible defaults.  Using the UIGeoTrack model, you can set which legs of your track are visible and we'll render them accordingly.  Keep in mind, performance of this control may degrade if your tracks have too many points.
public class GeoTrackMap: MKMapView {

    /// The color to use when rendering a leg of unknown direction (could be flat, or we just don't have enough altitude change to tell if it's an ascent or descent)
    public var unknownColor: UIColor = .yellow

    /// The color to use when rendering an ascent
    public var ascentColor: UIColor = .red

    /// The color to use when rendering a descent
    public var descentColor: UIColor = .blue

    /// The Zoom Delegate: which tells us if / where to zoom to
    public var zoomDelegate: ZoomDefining?
    // swiftlint:disable:previous weak_delegate

    /// The UI Model for the track.  When you set it, we render it!
    public var model: UIGeoTrack? {
        didSet {
            renderTrack()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        zoomDelegate = DefaultMapZoom()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        zoomDelegate = DefaultMapZoom()
    }
}

// MARK: - API

public extension GeoTrackMap {

    /// This will render your track on the map (based on what you've toggled as visible in the model)
    func renderTrack() {
        guard let analyzer = model?.analyzer else {
            return
        }
        removeOverlays(overlays)
        guard let polylines = model?.polylines else {
            return
        }

        for polyline in polylines {
            addOverlay(polyline)
        }

        guard let zoomDelegate = zoomDelegate else {
            return
        }
        if zoomDelegate.shouldZoom {
            setRegion(zoomDelegate.zoomRegion(for: analyzer.track.points), animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate

extension GeoTrackMap: MKMapViewDelegate {

    /// Delegate function that provides the MKOverlayRenderer for the Leg Overlays
    ///
    /// - Parameters:
    ///   - mapView: The map view
    ///   - overlay: The overlay to create a renderer for
    /// - Returns: The result MKOverlay renderer
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKPolylineRenderer(overlay: overlay)
        }

        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.lineWidth = 3
        renderer.strokeColor = unknownColor

        guard let title = polyline.title, let direction = Direction(rawValue: title) else {
            return renderer
        }

        switch direction {
        case .downward:
            renderer.strokeColor = descentColor
        case .upward:
            renderer.strokeColor = ascentColor
        default:
            break
        }

        return renderer
    }
}


// MARK: - converters

fileprivate extension UIGeoTrack {

    /// gets you an array of polylines to draw based on the array of legs
    var polylines: [MKPolyline] {
        var polys = [MKPolyline]()
        let points = track.points

        for leg in legs {
            var coordinates = [CLLocationCoordinate2D]()
            for index in leg.index...leg.endIndex {
                coordinates.append(points[index].coordinate)
            }
            let poly = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            poly.title = leg.direction.rawValue
            polys.append(poly)
        }

        return polys
    }

}
