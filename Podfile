source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!

target 'SceneryTracker' do
    pod 'Alamofire'
    pod 'Kingfisher'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
	    target.build_configurations.each do |config|
	        config.build_settings['SWIFT_VERSION'] = '3.0'
	    end
	end
end