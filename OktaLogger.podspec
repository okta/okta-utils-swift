Pod::Spec.new do |s|
  s.name             = "OktaLogger"
  s.version          = "1.2.0"
  s.summary          = "Logging proxy for standardized logging interface across products"
  s.description      = "Standard interface for all logging in Okta apps + SDK. Supports file, console, firebase logging destinations."
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  s.author           = { "Okta Developers" => "developer@okta.com" }
  s.source           = { :git => "https://github.com/okta/okta-logger-swift.git",  :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'
  s.dependency 'SwiftLint'
  s.default_subspec = "Complete"
  s.static_framework = true

  # Subspec
  s.subspec "Complete" do |complete|
    complete.dependency 'OktaLogger/FileLogger'
    complete.dependency 'OktaLogger/FirebaseCrashlytics'
  end

  s.subspec "MacOS" do |macos|
    macos.dependency 'OktaLogger/FileLogger'
    macos.dependency 'OktaLogger/AppCenterLogger'
  end

  s.subspec 'FileLogger' do |fileLogger|
      fileLogger.source_files = [
        'OktaLogger/FileLoggers/*.{h,m,swift}'
      ]
      fileLogger.dependency 'CocoaLumberjack/Swift', '~>3.6.0'
      fileLogger.dependency 'OktaLogger/Core'
  end

  s.subspec 'FirebaseCrashlytics' do |crashlytics|
    crashlytics.source_files = [
      'OktaLogger/FirebaseCrashlyticsLogger/OktaLoggerFirebaseCrashlyticsLogger.swift'
    ]
    crashlytics.dependency 'Firebase/Crashlytics', '~>7.4.0'
    crashlytics.dependency 'OktaLogger/Core'
  end

  s.subspec 'AppCenterLogger' do |appCenterLogger|
      appCenterLogger.source_files = [
      'OktaLogger/AppCenterLogger/*'
      ]
      appCenterLogger.dependency 'AppCenter', '~>4.1.1'
      appCenterLogger.dependency 'OktaLogger/Core'
  end

  s.subspec "Core" do |core|
      core.source_files = 'OktaLogger/*.{h,m,swift}'
      core.exclude_files = [
        'OktaLogger/Info.plist',
        'OktaLogger/FileLoggers',
        'OktaLogger/FirebaseCrashlyticsLogger',
        'OktaLogger/AppCenterLogger'
      ]
  end

end
