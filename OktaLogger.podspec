Pod::Spec.new do |s|
  s.name             = "OktaLogger"
  s.version          = "1.3.10"
  s.summary          = "Logging proxy for standardized logging interface across products"
  s.description      = "Standard interface for all logging in Okta apps + SDK. Supports file, console, firebase logging destinations."
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.author           = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => "https://github.com/okta/okta-logger-swift.git",  :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'
  s.watchos.deployment_target = '6.0'
  s.swift_version = '5.0'
  s.dependency 'SwiftLint'
  s.default_subspec = "Complete"

  # Subspec
  s.subspec "Complete" do |complete|
    complete.dependency 'OktaLogger/FileLogger'
    complete.dependency 'OktaLogger/FirebaseCrashlytics'
    complete.dependency 'OktaLogger/InstabugLogger'
  end

  s.subspec 'FileLogger' do |fileLogger|
      fileLogger.source_files = [
        'Sources/OktaLogger/FileLoggers/*.{h,m,swift}'
      ]
      fileLogger.dependency 'CocoaLumberjack/Swift', '~>3.6.0'
      fileLogger.dependency 'OktaLogger/Core'
  end

  s.subspec 'FirebaseCrashlytics' do |crashlytics|
    crashlytics.source_files = [
      'Sources/OktaLogger/FirebaseCrashlyticsLogger/OktaLoggerFirebaseCrashlyticsLogger.swift'
    ]
    crashlytics.dependency 'Firebase/Crashlytics', '~> 9.0'
    crashlytics.dependency 'OktaLogger/Core'
  end

  s.subspec 'InstabugLogger' do |instabugLogger|
      instabugLogger.ios.source_files = [
        'Sources/OktaLogger/InstabugLogger/*'
      ]
      instabugLogger.ios.dependency 'Instabug', '11.0.1'
      instabugLogger.ios.dependency 'OktaLogger/Core'
  end

  s.subspec "Core" do |core|
      core.source_files = 'Sources/OktaLogger/LoggerCore/*.{h,m,swift}'
      core.exclude_files = [
        'Sources/OktaLogger/Info.plist',
        'Sources/OktaLogger/FileLoggers',
        'Sources/OktaLogger/FirebaseCrashlyticsLogger',
        'Sources/OktaLogger/AppCenterLogger',
        'Sources/OktaLogger/InstabugLogger'
      ]
  end

end
