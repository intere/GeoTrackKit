# GeoTrackKit.podspec

Pod::Spec.new do |s|
  s.name      = 'GeoTrackKit'
  s.version   = '0.0.1'
  s.summary   = 'Geo Tracking and statistics for iOS'
  s.homepage  = 'https://github.com/intere/GeoTrackKit'
  s.author = {
    'Eric Internicola' => 'intere@gmail.com'
  }
  s.source = {
    :git => 'git@github.com:intere/GeoTrackKit.git',
    :branch => 'master'
    # :tag => '0.0.1'
  }
  s.source_files = 'GeoTrackKit/*.swift', 'GeoTrackKit/*.h'
end
