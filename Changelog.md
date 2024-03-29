# Changelog

## 1.0.0
- [Swiftlint / Config updates](https://github.com/intere/GeoTrackKit/pull/35)
- [Point filtering and API enhancements.](https://github.com/intere/GeoTrackKit/pull/28)
    - Added `PointFilterOptions` as a property of the `GeoTrackManager` and two static pre-configured values: `nilFilterOptions`, which won't filter at all and `defaultFilterOptions`, which has the default filter options.
    - `GeoTrackManager.shared.reset()`

## 0.3.0
- Added Live Tracking in Example App
- Refactored Example App into a tab bar based UI
- Factored existing code into a (default) subspec: `Core`
- Added `HealthKit` subspec
    - Provides the ability to read tracks from Workouts in HealthKit

## 0.2.0
- Swift 4
- functionally no different than 0.1.0

## 0.1.0
MVP Version:
- Swift 3.0
- Location Tracking
- Mapping of tracks
