//
//  SaveTrackCell.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 8/5/18.
//  Copyright © 2018 Eric Internicola. All rights reserved.
//

import UIKit

class SaveTrackCell: UITableViewCell {

    struct Constants {
        static let saveTrackNotification = Notification.Name(rawValue: "tapped.save.track")
    }

    @IBAction
    func tappedSaveTrack(_ sender: Any) {
        NotificationCenter.default.post(name: Constants.saveTrackNotification, object: nil)
    }

}
