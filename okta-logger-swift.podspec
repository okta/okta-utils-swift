Pod::Spec.new do |s|
  s.name             = "okta-logger-swift"
  s.version          = "0.9.0"
  s.summary          = "Logging proxy for standardized logging interface across products"
  s.description      = "Standard interface for all logging in Okta apps + SDK"
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = 'MIT'
  s.author           = { "Steve Lind" => "steve.lind@okta.com" }
  s.source           = { :git => "git@github.com:okta/okta-logger-swift.git",  :tag => s.version.to_s }

  s.platform     = :ios, '12.0'
  s.requires_arc = true
  s.source_files = 'OktaLogger/*.{swift}'
end