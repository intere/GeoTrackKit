//
//  TrackOverviewCell.swift
//  GeoTrackKitExample
//
//  Created by Eric Internicola on 3/1/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import GeoTrackKit
import UIKit

class TrackOverviewCell: UITableViewCell {
    @IBOutlet weak var chromeView: UIView!
    @IBOutlet weak var overviewLabel: UILabel!

    var analyzer: GeoTrackAnalyzer? {
        didSet {
            updateContents()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        overviewLabel.text = nil
    }

}

// MARK: - Implementation

extension TrackOverviewCell {

    func updateContents() {
        chromeView.backgroundColor = .black
        overviewLabel.textColor = .white

        guard let analyzer = analyzer, let stats = analyzer.stats else {
            return
        }

        let numRuns = analyzer.legs.filter({ $0.direction == .downward }).count
        let vertical = abs(stats.verticalDescent.metersToFeet)
        let distance = String(format: "%.2f mi distance", stats.totalDistance.metersToMiles)

        overviewLabel.text = "\(numRuns) runs\n\(Int(vertical))ft vertical descent\n\(distance)"
    }

}
