Pod::Spec.new do |s|
  s.name             = "OktaLogger"
  s.version          = "1.0.4"
  s.summary          = "Logging proxy for standardized logging interface across products"
  s.description      = "Standard interface for all logging in Okta apps + SDK. Supports file, console, firebase logging destinations."
  s.homepage         = "https://github.com/okta/okta-logger-swift"
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
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
    complete.dependency 'OktaLogger/Lumberjack'
    complete.dependency 'OktaLogger/FirebaseCrashlytics'
  end

  s.subspec 'Lumberjack' do |lumberjack|
      lumberjack.source_files = [
        'OktaLogger/FileLoggers/*.{h,m,swift}'
      ]
      lumberjack.dependency 'CocoaLumberjack/Swift', '~>3.6.0'
      lumberjack.dependency 'OktaLogger/Core'
  end

  s.subspec 'FirebaseCrashlytics' do |crashlytics|
    crashlytics.source_files = [
      'OktaLogger/CrashlyticsLogger/OktaLoggerCrashlyticsLogger.swift'
    ]
    crashlytics.dependency 'Firebase/Crashlytics', '~>6.29.0'
    crashlytics.dependency 'OktaLogger/Core'
  end

  s.subspec "Core" do |core|
      core.source_files = 'OktaLogger/*.{h,m,swift}'
      core.exclude_files = [
        'OktaLogger/Info.plist',
        'OktaLogger/FileLoggers',
        'OktaLogger/CrashlyticsLogger'
      ]
  end

end
