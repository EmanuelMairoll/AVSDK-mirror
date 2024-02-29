Pod::Spec.new do |s|
  s.name             = 'AuthenticVisionSDK'
  s.version          = '8.2.3'
  s.summary = "Enables authentication of AV security labels in iOS apps."
  s.description = <<-DESC
  The Authentic Vision Mobile Auth­enti­cation SDK (AV SDK) auth­en­ti­cates Authentic Vision's security labels. It presents a cust­om­iz­able scan screen and provides your app­li­cation with detailed per-label in­for­mation, or opens a website when a label is scanned.
DESC
  s.homepage         = 'https://docs.authenticvision.com/sdk/'
  s.author           = { 'Authentic Vision GmbH' => 'support@authenticvision.com' }
  s.source           = { :http => 'https://github.com/EmanuelMairoll/AVSDK-mirror/releases/download/v8.2.3/AuthenticVisionSDK.xcframework.zip' }
  s.license      = { :type => 'Authentic Vision SDK License' }
  s.platform     = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  s.vendored_frameworks = 'AuthenticVisionSDK.xcframework'
end
