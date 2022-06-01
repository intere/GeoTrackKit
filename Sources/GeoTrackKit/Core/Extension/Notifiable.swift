//
//  Notifiable.swift
//  GeoTrackKit
//
//  Created by Eric Internicola on 11/16/19.
//

import Foundation

/// The purpose of this protocol is to prevent you from having to write a bunch of boilerplate code
/// to get from a `String` to a Notification (and associated convenience functions).
///
/// By conforming to `Notifiable` and `CustomStringConvertable`, you automatically get the
/// `notify()` and `addObserver(...)` functions.
/// See Boilerplate Mark below for implementations.
public protocol Notifiable {

    /// The base of the notification, used to build out the notification.
    static var notificationBase: String { get }

}

// MARK: - Notifiable Boiler Plate

public extension Notifiable where Self: CustomStringConvertible {

    /// Gets you the Notification String (fully-qualified) for this `Notifiable` Implementation.
    var notificationString: String {
        return type(of: self).notificationBase + "." + self.description
    }

    /// Gets you the `Notification.Name` for this `Notifiable` implementation.
    var name: Notification.Name {
        return Notification.Name(rawValue: notificationString)
    }

    /// Gets you the notification for this `Notifiable` implementation.
    var notification: Notification {
        return Notification(name: name)
    }

    /// Sends out this notification via the default `NotificationCenter`.
    func notify() {
        NotificationCenter.default.post(notification)
    }

    /// Sends out this notification (with an associated object) via the default `NotificationCenter`.
    ///
    /// - Parameter object: The object to be associated with this notification.
    func notify(withObject object: Any) {
        NotificationCenter.default.post(name: name, object: object)
    }

    /// Registers a listener for the event with the default `NotificationCenter`.
    ///
    /// - Parameters:
    ///   - observer: The observer that will be listening for the event.
    ///   - selector: The selector to call back to for the event.
    ///   - object: Optional object to be associated with the observer.
    func addObserver(_ observer: Any, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }

}
