#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_skyway_ios'
  s.version          = '0.0.1'
  s.summary          = 'An iOS implementation of the flutter_skyway plugin.'
  s.description      = <<-DESC
  An iOS implementation of the flutter_skyway plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :git => 'https://github.com/skyway/skyway-ios-sdk-specs.git' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SkyWayRoom'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end