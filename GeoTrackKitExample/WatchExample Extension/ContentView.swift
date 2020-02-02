//
//  ContentView.swift
//  WatchExample Extension
//
//  Created by Eric Internicola on 1/27/20.
//  Copyright © 2020 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import SwiftUI

struct ContentView: View {
    @State var labelText = "GeoTrackKit"
    @State var buttonText = "Start Tracking"

    var body: some View {
        VStack {
            Text(labelText)
            Button(action: {
                self.handleTracking()
            }, label: {
                Text(buttonText)
            })
        }
    }

    init() {
        do {
            try SQLiteService.shared.configureDatabase()
        } catch {
            ELog("failed to configure db: \(error.localizedDescription)")
        }
        GeoTrackManager.shared.trackPersistence = SQLiteTrackPersisting.shared
    }

    func handleTracking() {
        if GeoTrackManager.shared.isTracking {
            GeoTrackManager.shared.stopTracking()
            self.buttonText = "Start Tracking"
            if let track = GeoTrackManager.shared.track {
                self.labelText = "\(track.points.count) points"
            } else {
                self.labelText = "No track"
            }
        } else {
            GeoTrackManager.shared.startTracking(type: .whileInUse) { result in
                switch result {
                case .failure(let error):
                    self.labelText = "Tracking Error"
                    self.buttonText = "Start Tracking"
                    ELog("failed to start tracking: \(error.localizedDescription)")
                case .success(let authStatus):
                    switch authStatus {
                    case .authorizedAlways, .authorizedWhenInUse:
                        self.labelText = "Tracking!"
                        self.buttonText = "Stop Tracking"
                    case .denied, .restricted:
                        self.labelText = "Location Services Disabled"
                        self.buttonText = "Start Tracking"
                    case .notDetermined:
                        self.labelText = "Access not determined"
                        self.buttonText = "Start Tracking"
                    @unknown default:
                        self.labelText = "Library needs updating"
                        self.buttonText = "Unknown State"
                    }
                }
            }
        }
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
