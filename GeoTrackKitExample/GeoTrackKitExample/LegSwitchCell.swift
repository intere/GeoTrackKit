//
//  LegSwitchCell.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 2/28/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class LegSwitchCell: UITableViewCell {
    
    @IBOutlet var toggleSwitch: UISwitch!
    @IBOutlet var label: UILabel!
    
    var indexPath: IndexPath?
    weak var model: UIGeoTrack?
    
    @IBAction func didToggleSwitch(_ sender: UISwitch) {
        guard let indexPath = indexPath else {
            return assertionFailure("IndexPath not set on cell")
        }
        guard let model = model else {
            return assertionFailure("Model not set on cell")
        }
        model.set(visibility: toggleSwitch.isOn, for: model.allLegs[indexPath.row])
    }
    
    
}
