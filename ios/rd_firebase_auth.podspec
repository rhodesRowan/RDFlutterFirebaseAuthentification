#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rd_firebase_auth.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rd_firebase_auth'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SnapSDK', '1.4'
  s.static_framework = true
  s.ios.deployment_target = '11.0'
  s.preserve_paths = 'SCSDKLoginKit.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework SCSDKLoginKit' }
  s.vendored_frameworks = 'SCSDKLoginKit.framework'
  s.swift_version = '5.0'
end
