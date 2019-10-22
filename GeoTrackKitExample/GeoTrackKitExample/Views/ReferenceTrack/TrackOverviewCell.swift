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

    struct Constants {
        static let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.alwaysShowsDecimalSeparator = false
            formatter.groupingSeparator = ","
            return formatter
        }()
    }

    func updateContents() {
        backgroundColor = .black
        chromeView.backgroundColor = .black
        overviewLabel.textColor = .white

        guard let analyzer = analyzer else {
            return
        }

        let numRuns = analyzer.legs.filter({ $0.direction == .downward }).count
        let vertical = abs(analyzer.stats?.verticalDescent ?? 0).metersToFeet

        let feet = Constants.numberFormatter.string(for: Int(vertical))

        if let feet = feet {
            overviewLabel.text = "\(numRuns) runs\n\(feet) ft vertical descent"
        } else {
            overviewLabel.text = "\(numRuns) runs\n\(Int(vertical)) ft vertical descent"
        }

    }

}
