Pod::Spec.new do |s|
  s.name             = "OktaLogger"
  s.version          = "1.4.1"
  s.summary          = "Logging proxy for standardized logging interface across products"
  s.description      = "Standard interface for all logging in Okta apps + SDK. Supports file, console, firebase logging destinations."
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.author           = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => "https://github.com/okta/okta-logger-swift.git",  :tag => "OktaLogger-"+s.version.to_s }
  
  s.platforms = { :ios => '15.0', :osx => '10.15' }
  s.swift_version = '5.0'
  s.default_subspec = "Complete"

  s.subspec "Complete" do |complete|
      complete.platforms = { :ios => '15.0', :osx => '10.15' }
      complete.dependency 'OktaLogger/FileLogger'
      complete.dependency 'OktaLogger/FirebaseCrashlytics'
      complete.ios.dependency 'OktaLogger/InstabugLogger'
  end

  s.subspec 'FileLogger' do |fileLogger|
      fileLogger.platforms = { :ios => '15.0', :osx => '10.15', :watchos => '7.0' }
      fileLogger.source_files = [
        'Sources/OktaLogger/FileLoggers/*.{h,m,swift}'
      ]
      fileLogger.dependency 'CocoaLumberjack/Swift', '~>3'
      fileLogger.dependency 'OktaLogger/Core'
  end

  s.subspec 'FirebaseCrashlytics' do |crashlytics|
      crashlytics.platforms = { :ios => '15.0', :osx => '10.15' }
      crashlytics.source_files = [
        'Sources/OktaLogger/FirebaseCrashlyticsLogger/OktaLoggerFirebaseCrashlyticsLogger.swift'
      ]
      crashlytics.dependency 'Firebase/Crashlytics', '~> 11'
      crashlytics.dependency 'OktaLogger/Core'
  end

  s.subspec 'InstabugLogger' do |instabugLogger|
      instabugLogger.platform = :ios, '15.0'
      instabugLogger.ios.source_files = [
        'Sources/OktaLogger/InstabugLogger/*'
      ]
      instabugLogger.ios.dependency 'Instabug', '~> 16'
      instabugLogger.dependency 'OktaLogger/Core'
  end

  s.subspec "Core" do |core|
      core.platforms = { :ios => '15.0', :osx => '10.15', :watchos => '7.0' }
      core.source_files = 'Sources/OktaLogger/LoggerCore/*.{h,m,swift}'
      core.exclude_files = [
        'Sources/OktaAnalytics',
        'Sources/OktaLogger/FileLoggers',
        'Sources/OktaLogger/FirebaseCrashlyticsLogger',
        'Sources/OktaLogger/Info.plist',
        'Sources/OktaLogger/InstabugLogger'
      ]
  end

end
