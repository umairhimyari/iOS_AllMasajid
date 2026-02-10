# Uncomment the next line to define a global platform for your project
 platform :ios, '14.0'

target 'AllMasajid' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 5.9'
  pod 'SwiftyJSON', '~> 5.0'

  #pod 'SideMenu'
  pod 'DropDown'

#  pod 'Adhan', '~> 0.1.5'
  pod 'GooglePlaces', '~> 7.4.0'
  pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'master'
  pod 'SCLAlertView'
  pod 'PKHUD', '~> 5.0'
  pod 'IQKeyboardManagerSwift'
  pod 'YandexMobileMetrica', '~> 4.5'
  pod 'Kingfisher', '~> 7.0'
  pod 'FSCalendar'

  # Firebase - using compatible version 10.x for iOS 14
  pod 'Firebase/Analytics', '~> 10.29'
  pod 'Firebase/Messaging', '~> 10.29'
  pod 'Firebase/Auth', '~> 10.29'
  #pod 'Stripe'

  pod 'CountryPickerView'
  pod 'NVActivityIndicatorView'

  pod 'KeychainSwift', '~> 19.0'
  pod 'FBSDKLoginKit', '~> 17.4'
  pod 'GoogleSignIn', '~> 7.0'
  
  post_install do |pi|
      pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
      end
  end
end
