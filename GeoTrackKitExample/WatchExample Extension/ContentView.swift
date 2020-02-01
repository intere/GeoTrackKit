//
//  ContentView.swift
//  WatchExample Extension
//
//  Created by Eric Internicola on 1/27/20.
//  Copyright © 2020 Eric Internicola. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var labelText = "GeoTrackKit"
    var buttonText = "Start Tracking"

    var body: some View {
        VStack {
            Text(labelText)
            Button(action: {
                #warning("TODO: implement me")
            }, label: {
                Text(buttonText)
            })
        }
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
