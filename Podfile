platform :ios, '15.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'Firebase/AnalyticsWithoutAdIdSupport'
    pod 'Firebase/Crashlytics', '~>11.3.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '16.0.3'
    pod 'SwiftLint', '0.51'
end

target 'OktaSQLiteStorage' do
    pod 'GRDB.swift/SQLCipher','6.20.2'
    pod 'SQLCipher', '4.5.5'
    pod 'SwiftLint', '0.51'
end

target 'OktaAnalytics' do
    pod 'OktaLogger/Core', :path => '.'
    pod 'OktaSQLiteStorage', :path => '.'
    pod 'AppCenter', '~>5.0.0'
    pod 'SwiftLint', '0.51'
    pod 'Firebase/AnalyticsWithoutAdIdSupport'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'OktaAnalytics', :path => '.'
    pod 'Firebase/Crashlytics', '~>11.3.0'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end

target 'OktaSQLiteStorageTests' do
  pod 'OktaSQLiteStorage', :path => '.'
end

target 'OktaAnalyticsTests' do
  pod 'OktaAnalytics', :path => '.'
  pod 'OktaSQLiteStorage', :path => '.'
  pod 'AppCenter', '~>5.0.0'
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # use top level deployment target
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET'
    end
  end
end