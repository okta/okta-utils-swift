Pod::Spec.new do |s|
  s.name             = 'OktaSQLiteStorage'
  s.version          = '0.0.2'
  s.summary          = 'Okta SQLite storage framework'
  s.description      = <<-DESC
Okta SQLite storage wrapper on top of GRDB framework
                       DESC
  s.platforms        = { :ios => "13.0", :osx => "12.0" }
  s.homepage         = 'https://github.com/okta/okta-logger-swift.git'
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.authors          = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => 'https://github.com/okta/okta-logger-swift.git', :tag => "OktaSQLiteStorage-"+s.version.to_s }
  s.swift_version = '5.0'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  s.source_files = 'Sources/OktaSQLiteStorage/Sources/*.{h,m,swift}'

  s.dependency 'GRDB.swift','~>5'
end
