Pod::Spec.new do |s|
  s.name             = 'gms_location_settings_dialog'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin for GMS location settings dialog (Android) and location service status (iOS).'
  s.description      = <<-DESC
    Shows the Google Play Services in-app dialog to enable GPS on Android via
    ResolvableApiException. On iOS, reports CLLocationManager.locationServicesEnabled()
    with no dialog (iOS has no equivalent API). Requires GMS on Android.
  DESC
  s.homepage         = 'https://github.com/anttonijulio/gms_location_settings_dialog'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'anttonijulio' => 'antonijulio76@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
