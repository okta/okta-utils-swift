platform :ios, '11.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'AppCenter', '4.3.0'
    pod 'Firebase/Crashlytics', '10.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '11.7.0'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'OktaAnalytics', :path => '.'
    pod 'Firebase/Crashlytics', '10.4.0'

    target 'OktaLoggerTests' do
      pod 'OktaAnalytics', :path => '.'
    end
end
