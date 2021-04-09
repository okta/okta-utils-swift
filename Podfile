platform :ios, '11.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'Firebase/Crashlytics', '~>7.10.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'Firebase/Crashlytics', '~>7.10.0'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end
