# GeoTrackKit
### An iOS Library for Geo Tracking

## Features
- Handles user authorization
- Handles track creation
- Handles track analyzing (for ascents, descents and other stats)
- Custom MKMapKit control for plotting your tracks on a map
- Pull tracks in from HealthKit (Activity App)
    - `NOTE:` This is an iOS 11+ only feature and requires a physical device to test
    - This capability is in a subspec: `HealthKit`
- Example App to demonstrate capabilities


## Project Status
This project is currently a work in progress.

[![Build Status](https://travis-ci.org/intere/GeoTrackKit.svg?branch=develop)](https://travis-ci.org/intere/GeoTrackKit)
[![Documentation](https://cdn.rawgit.com/intere/GeoTrackKit/master/docs/badge.svg)](https://intere.github.io/GeoTrackKit/docs/index.html)
[![Platform](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://cocoadocs.org/docsets/GeoTrackKit)
[![CocoaPods](https://img.shields.io/cocoapods/v/GeoTrackKit.svg)](https://cocoapods.org/pods/GeoTrackKit)  
 [![CocoaPods](https://img.shields.io/cocoapods/dt/GeoTrackKit.svg)](https://cocoapods.org/pods/GeoTrackKit) [![CocoaPods](https://img.shields.io/cocoapods/dm/GeoTrackKit.svg)](https://cocoapods.org/pods/GeoTrackKit)

### Initial Roadmap
- [ ] Carthage Support
- [x] CocoaPods Support
- [x] Continuous Integration (Buddy Build)
- [x] Function Documentation
- [x] Jazzy Docs
- [ ] Performance Tests
- [x] SwiftLint Integration
- [ ] 90% Code Coverage
- [x] Pull tracks from HealthKit (Workouts)

### Example App

TODO:
- [ ] Save tracks to disk
- [ ] Provide a track list
- [x] Pull tracks in from HealthKit

### Installation

## Installation Instructions

### CocoaPods

Directly from Github:
```ruby
pod 'GeoTrackKit', :git => 'git@github.com:intere/GeoTrackKit.git', :branch => 'develop'
```

Directly from Cocoapods:
```ruby
pod 'GeoTrackKit'
```

## Example Usage

```
// This will either start tracking, or prompt the user for access to track their location
GeoTrackManager.shared.startTracking()
```
<img src="https://github.com/intere/GeoTrackKit/raw/develop/screenshots/GeoTrackKit-Tracking.gif" title="Tracking Example">

This library also includes a map control that will map the GeoTrack:

<img src="https://user-images.githubusercontent.com/2284832/43367309-19f759ce-9308-11e8-974a-8823f3aade66.gif" title="Map View">

## Inspiration
I've built a couple of variations of Geo Tracking applications, but I wanted to build a library for the community that I can share and get feedback and build better products.

## Created and maintained by
[Eric Internicola](http://intere.github.io)


## Key Classes
<img src="https://github.com/intere/GeoTrackKit/raw/develop/screenshots/GeoTrackKitClasses.png" title="Key GeoTrackKit Classes">

## Documentation
See the generated documentation in the [`docs`](https://intere.github.io/GeoTrackKit/docs/) folder


## Credits / Attribution
- [Example App Icon](https://www.flaticon.com/free-icon/world-location_52177#term=globe&page=1&position=68)
    - <div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
- [Terminal icon](https://www.flaticon.com/free-icon/terminal-server-session_523#term=terminal&page=1&position=60)
    - <div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
- [Location on map icon](https://www.flaticon.com/free-icon/location-on-map_106165#term=gps&page=1&position=33)
    - <div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
- [Map Location free icon](https://www.flaticon.com/free-icon/map-location_149985#term=gps&page=1&position=24)
    - <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
