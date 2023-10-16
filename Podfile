platform :ios, '13.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'Firebase/Crashlytics', '~>9.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '11.7.0'
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
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'OktaAnalytics', :path => '.'
    pod 'Firebase/Crashlytics', '~>9.4.0'

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
