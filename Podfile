platform :ios, '11.4'

target 'kat' do
  use_frameworks!
	pod 'ACFloatingTextfield-Swift', '~> 1.7'
	pod 'Alamofire'
	pod 'SwiftyJSON'
	pod 'AlamofireImage'
    pod 'BSImagePicker', '~> 2.4'
    pod 'SimpleImageViewer', '~> 1.1.1'
    pod 'SearchTextField'
    pod 'IQKeyboardManagerSwift'
    pod 'M13Checkbox'
    pod 'ReachabilitySwift'
end
# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
