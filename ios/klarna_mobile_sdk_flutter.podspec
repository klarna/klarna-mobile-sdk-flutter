#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint klarna_mobile_sdk_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'klarna_mobile_sdk_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Klarna&#x27;s Flutter wrapper for the Klarna Mobile SDK'
  s.description      = <<-DESC
Klarna&#x27;s Flutter wrapper for the Klarna Mobile SDK
                       DESC
  s.homepage         = 'https://github.com/klarna/klarna-mobile-sdk-flutter/'
  s.license          = { :type => "Apache License, Version 2.0", :file => '../LICENSE' }
  s.author           = { 'Klarna Mobile SDK Team' => 'mobile.sdk@klarna.com' }
  s.source           = { :git => "https://github.com/klarna/klarna-mobile-sdk-flutter.git", :tag => s.version.to_s }
  s.source_files = 'Classes/**/*'
  s.resources = 'Assets/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  # Klarna Mobile SDK
  s.dependency 'KlarnaMobileSDK', '~> 2.6.21'
end
