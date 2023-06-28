Pod::Spec.new do |s|
  s.name             = 'OktaSQLiteStorage'
  s.version          = '0.0.3'
  s.summary          = 'Okta SQLite storage framework'
  s.description      = <<-DESC
Okta SQLite storage wrapper on top of GRDB framework
                       DESC
  s.platforms        = { :ios => "13.0", :osx => "11.0" }
  s.homepage         = 'https://github.com/okta/okta-logger-swift.git'
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.authors          = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => 'https://github.com/okta/okta-logger-swift.git', :tag => "OktaSQLiteStorage-"+s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  s.source_files = 'Sources/OktaSQLiteStorage/Sources/*.{h,m,swift}'
  s.default_subspec  = 'standard'
  
  s.subspec 'standard' do |ss|
    ss.dependency 'GRDB.swift/SQLCipher'
    ss.dependency 'SQLCipher','~> 4.0'
  end

  s.subspec 'SQLCipher' do |ss|
    ss.dependency 'GRDB.swift/SQLCipher'
    ss.dependency 'SQLCipher','~> 4.0'
  end

end
