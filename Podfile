# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'VShootApplication' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
    pod 'Alamofire'
    pod 'AlamofireSwiftyJSON'
    pod 'SwiftyJSON'
    pod 'Socket.IO-Client-Swift', '~> 13.2.0'
    pod 'iOSDropDown'
    pod 'TwilioVideo', '~> 2.8.0'
    pod 'SwiftSpinner'
    pod 'Firebase/Core'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'XLPagerTabStrip', '~> 9.0'
    pod 'MessengerKit', :git => 'https://github.com/steve228uk/MessengerKit.git'
    
    

  target 'VShootApplicationTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
