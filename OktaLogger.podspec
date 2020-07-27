Pod::Spec.new do |s|
  s.name             = "OktaLogger"
  s.version          = "1.0.2"
  s.summary          = "Logging proxy for standardized logging interface across products"
  s.description      = "Standard interface for all logging in Okta apps + SDK. Supports file, console, firebase logging destinations."
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => "https://github.com/okta/okta-logger-swift.git",  :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'
  s.source_files = 'OktaLogger/*.{h,m,swift}'
  s.exclude_files = [
    'OktaLogger/Info.plist'
  ]
  s.dependency  'CocoaLumberjack/Swift', '~>3.6.0'
end
