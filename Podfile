platform :ios, '11.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'AppCenter', '~>4.3.0'
    pod 'Firebase/Crashlytics', '9.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '11.0.1'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'Firebase/Crashlytics', '9.4.0'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end
