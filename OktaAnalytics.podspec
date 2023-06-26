Pod::Spec.new do |s|
  s.name             = "OktaAnalytics"
  s.version          = "2.0.0"
  s.summary          = "Implementation of Analytics logger destination"
  s.description      = "Implementation of Analytics logger destination. Requires OktaLogger/Core"
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.author           = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => "https://github.com/okta/okta-logger-swift.git",  :tag => "OktaAnalytics-"+s.version.to_s }
  
  s.osx.deployment_target = '11.0'
  s.ios.deployment_target = '13.0'
  
  s.swift_version = '5.0'
  s.static_framework = true

  s.source_files = 'Sources/OktaAnalytics/**/*.{h,m,swift}'
  s.dependency 'AppCenter','5.0.0'
  s.dependency 'OktaLogger/Core', '~>1'
  s.dependency 'OktaSQLiteStorage', '~>0.0.3'
end
