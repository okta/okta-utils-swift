require 'cocoapods-catalyst-support'

platform :ios, '11.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'AppCenter', '~>4.3.0'
    pod 'Firebase/Crashlytics', '9.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
    pod 'Instabug', '11.2.0'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'Firebase/Crashlytics', '9.4.0'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end

# Configure your macCatalyst dependencies
catalyst_configuration do
	# Uncomment the next line for a verbose output
	verbose!

	ios 'Instabug' # This dependency will only be available for iOS
	macos 'AppCenter' # This dependency will only be available for macOS
end

# Configure your macCatalyst App
post_install do |installer|
	installer.configure_catalyst
end
