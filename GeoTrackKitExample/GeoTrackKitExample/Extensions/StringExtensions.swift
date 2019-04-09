//
//  StringExtensions.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 3/4/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import Foundation

extension String {

    /// Takes this string (assumes this is the name of a track) and converts it to a format
    /// that will save to the filesystem without failing because of using slashes or colons.
    var trackNameToFileSystemName: String {
        return self.replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "_")
    }

}
