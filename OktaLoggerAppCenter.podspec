Pod::Spec.new do |s|
  s.name             = "OktaLoggerAppCenter"
  s.version          = "1.0.0"
  s.summary          = "Implementation of AppCenter logger destination"
  s.description      = "Implementation of AppCenter logger destination. Requires OktaLogger/Core"
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.author           = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => "https://github.com/okta/okta-logger-swift.git",  :tag => s.version.to_s }
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'
  s.dependency 'SwiftLint'
  s.static_framework = true
  
  s.source_files = [
    'OktaLogger/AppCenterLogger/*'
    ]
  s.dependency 'AppCenter','~>4.3.0'
  s.dependency 'OktaLogger/Core'
end
