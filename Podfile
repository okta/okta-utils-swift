platform :ios, '11.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'AppCenter', '~>4.3.0'
    pod 'Firebase/Crashlytics', '~>7.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '~>10.7.5'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'Firebase/Crashlytics', '~>7.4.0'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end
