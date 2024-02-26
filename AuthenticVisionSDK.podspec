Pod::Spec.new do |s|
  s.name             = 'AuthenticVisionSDK'
  s.version          = '8.2.3'
  s.summary = "Enables authentication of AV security labels in iOS apps."
  s.description = <<-DESC
  The Authentic Vision SDK provides iOS applications the ability to authenticate Authentic Vision’s irreproducible security labels. It includes a simple API and a pre-made scan view controller for integrating label scanning functionality seamlessly. Requirements: iOS 12.0 or later, rear camera with torch, internet connection for scanning, and an AV SDK license.
DESC
  s.homepage         = 'https://github.com/EmanuelMairoll/AVSDK-mirror'
  s.author           = { 'Your Name' => 'support@authenticvision.com' }
  s.source           = { :http => "https://github.com/EmanuelMairoll/AVSDK-mirror/releases/download/v#{s.version}/AuthenticVisionSDK.xcframework.zip" }

  s.platform     = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  s.vendored_frameworks = 'AuthenticVisionSDK.xcframework'
end
