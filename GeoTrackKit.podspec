# GeoTrackKit.podspec
# to lint:
# pod lib lint --allow-warnings GeoTrackKit.podspec

Pod::Spec.new do |s|
  s.name      = 'GeoTrackKit'
  s.version   = '1.1.0'
  s.summary   = 'Geo Tracking and statistics for iOS'
  s.description = <<-DESC
A Geo Location Tracking and statistic calculation library for iOS.  It also provides rendering location tracks over a map for you.
  DESC

  s.homepage  = 'https://github.com/intere/GeoTrackKit'
  s.author = { 'Eric Internicola' => 'intere@gmail.com' }
  s.source = {
    :git => 'https://github.com/intere/GeoTrackKit.git',
    :tag => s.version.to_s
  }

  s.license = {
    :type => 'MIT',
    :text => <<-LICENSE
    The MIT License (MIT)
Copyright (c) 2018 Eric Internicola

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    LICENSE
  }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.default_subspecs = 'Core'

  # Core Tracking functionality + Apple Maps rendering
  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.source_files = 'GeoTrackKit/Core/**/*.{swift,h,m}'
  end

  # HealthKit subspec, provides the ability to read tracks from Workouts
  s.subspec 'HealthKit' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.source_files = 'GeoTrackKit/HealthKit/**/*.{swift,h,m}'
    ss.dependency 'GeoTrackKit/Core'
  end

  s.subspec 'SQLite' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.source_files = 'GeoTrackKit/SQLite/**/*.{swift,h,m}'
    ss.dependency 'SQLite.swift'
    ss.dependency 'GeoTrackKit/Core'
  end


  # Watch
  s.subspec 'WatchCore' do |ss|
    ss.watchos.deployment_target = '6.0'
    ss.source_files = 'GeoTrackKit/Core/**/*.{swift,h,m}'
    ss.watchos.exclude_files = [
      "GeoTrackKit/Core/**/GeoTrackMap.swift",
      "GeoTrackKit/Core/**/UIGeoTrack.swift"
    ]
  end

  s.subspec 'SQLiteWatch' do |ss|
    ss.watchos.deployment_target = '6.0'
    ss.source_files = 'GeoTrackKit/SQLite/**/*.{swift,h,m}'
    ss.dependency 'SQLite.swift'
    ss.dependency 'GeoTrackKit/WatchCore'
  end

end
