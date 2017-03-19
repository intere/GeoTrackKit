# GeoTrackKit
### An iOS Library for Geo Tracking

## Features
- Handles user authorization
- Handles track creation
- Handles track analyzing (for ascents, descents and other stats)
- Custom MKMapKit control for plotting your tracks on a map
- Example App to demonstrate capabilities

## Project Status
This project is currently a work in progress.

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=58a5d9cf4d78ba0100bda868&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/58a5d9cf4d78ba0100bda868/build/latest?branch=feature/BuildingBlocks)
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

### Installation

## Installation Instructions

### CocoaPods
```ruby
pod 'GeoTrackKit', :git => 'git@github.com:intere/GeoTrackKit.git', :branch => 'master'
```

## Example Usage

```
// This will either start tracking, or prompt the user for access to track their location
GeoTrackManager.shared.startTracking()
```
<img alt="Location Prompt" src="screenshots/LocationTrackingPrompt.png">
<img alt="Tracking" src="screenshots/Usage.png">

This library also includes a map control that will map the GeoTrack:
<img alt="Geo Track Map" src="screenshots/Mapping.png">

## Inspiration
I've built a couple of variations of Geo Tracking applications, but I wanted to build a library for the community that I can share and get feedback and build a better product.

## Created and maintained by
[Eric Internicola](http://intere.github.io)


## Key Classes
<img alt="Key GeoTrackKit Classes" src="screenshots/GeoTrackKitClasses.png">

## Documentation
See the generated documentation in the `docs` folder
