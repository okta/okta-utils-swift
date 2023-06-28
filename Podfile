platform :ios, '13.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'Firebase/Crashlytics', '~>10.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '11.7.0'
    pod 'SwiftLint', '0.51'
end

target 'OktaAnalytics' do
    pod 'OktaLogger/Core', :path => '.'
    pod 'OktaSQLiteStorage', :podspec => '.'
    pod 'AppCenter', '~>4.3.0'
    pod 'SwiftLint', '0.51'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    #pod 'OktaAnalytics', :path => '.'
    pod 'Firebase/Crashlytics', '~>10.4.0'
    pod 'OktaSQLiteStorage', :podspec => '.'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end

target 'SQLiteStorage' do
    pod 'GRDB.swift/SQLCipher', '~> 6.0'
    pod 'SQLCipher','~> 4.0'
    pod 'SwiftLint', '0.51'
end

target 'OktaSQLiteStorageTests' do
  pod 'OktaSQLiteStorage/SQLCipher', :podspec => '.'
end

target 'OktaAnalyticsTests' do
  pod 'OktaAnalytics', :path => '.'
  pod 'OktaSQLiteStorage', :podspec => '.'
  pod 'AppCenter', '~>4.3.0'
end
