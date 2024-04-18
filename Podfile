# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'GreenEntertainment' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

 # Pods for GreenEntertainment
 
 pod 'PKHUD', '~> 5.0'
 pod 'RxSwift'
 pod 'RxCocoa'
 pod 'RxDataSources'
 pod 'RxSwiftExt', '~> 6.2.0'
 
 pod 'UIMultiPicker'
 pod 'SDWebImage'
 
 pod 'MaterialComponents/Snackbar'
 pod 'Kingfisher'
 pod 'IQKeyboardManagerSwift'
 pod 'ObjectMapper'
 pod 'SwiftyJSON'
 pod 'SwiftMessages'
 pod 'Alamofire'
 pod 'AlamofireImage', '~> 3.5'
 pod 'SwiftyGif'
 pod 'CarbonKit'
 pod "MBCircularProgressBar"
 pod 'UICircularProgressRing'
 pod "ScalingCarousel"
 pod "SimpleAnimation"
 #pod "Braintree"
 #pod 'Google-Mobile-Ads-SDK'
 pod 'FirebaseAnalytics'
 pod 'Firebase/Messaging'
 pod 'Firebase/Crashlytics'
 pod 'Stripe'
 #pod 'BBMetalImage'
 pod 'AgoraRtm_iOS'
 pod 'MKToolTip'
 pod 'Firebase/DynamicLinks'
 pod "Pulsator"
 pod 'InfiniteLayout'
 pod 'Branch'
 pod 'ActiveLabel'
 pod 'FTPopOverMenu_Swift'
 pod "FlexiblePageControl"

 pod 'FirebaseCore'
 pod 'FirebaseAuth'
 pod 'Firebase/Database'
 pod 'Firebase/Firestore'
 pod 'Firebase/Storage'
 
 pod 'CodableFirebase'
 
 pod 'SwiftDate'


 # pod 'AgoraRtcEngine_iOS'

  target 'GreenEntertainmentTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GreenEntertainmentUITests' do
    # Pods for testing
  end
  
  target 'Video' do
    # Pods for testing
  end
  
  target 'VideoUI' do
    # Pods for testing
  end

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
      end
    end
  end
#  post_install do |installer|
#    installer.pods_project.targets.each do |target|
#      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
#        target.build_configurations.each do |config|
#          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
#          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
#        end
#      end
#    end
#  end
  
end
