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
        GeoTrackManager.shared.trackPersistence = SQLiteTrackPersisting.shared
    }

    func handleTracking() {
        if GeoTrackManager.shared.isTracking {
            GeoTrackManager.shared.stopTracking()
            self.labelText = "Start Tracking"
        } else {
            do {
                try GeoTrackManager.shared.startTracking(type: .whileInUse)
                self.labelText = "Stop Tracking"
            } catch {

            }
        }
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
