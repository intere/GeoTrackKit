//
//  StringExtensions.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 3/4/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import Foundation

extension String {

    var trackNameToFileSystemName: String {
        return self.replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "_")
    }

}
