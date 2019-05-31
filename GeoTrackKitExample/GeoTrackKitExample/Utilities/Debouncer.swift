//
//  Debouncer.swift
//  GeoTrackKitExampleTests
//
//  Created by Eric Internicola on 5/31/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import Foundation

public class Debouncer {

    // MARK: - Properties
    private let queue = DispatchQueue.main
    private var workItem = DispatchWorkItem(block: {})
    private var interval: TimeInterval

    // MARK: - Initializer
    public init(seconds: TimeInterval) {
        self.interval = seconds
    }

    // MARK: - Debouncing function
    public func debounce(action: @escaping (() -> Void)) {
        workItem.cancel()
        workItem = DispatchWorkItem(block: { action() })
        queue.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
}
