//
//  AppDelegate.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import Braintree
//import GoogleMobileAds
import Firebase
import FirebaseMessaging
import Stripe
import Branch
import StoreKit

import Video
import VideoUI

import FirebaseCore
import FirebaseAuth
import CodableFirebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController = UINavigationController()
    
    private var videos: [Video]! //= HardcodeDataProvider.getVideos()
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        DispatchQueue.main.async {
            
            self.registerForNotification(application: application)
            Messaging.messaging().delegate = self
            //AuthManager.shared.fcmToken = Messaging.messaging().fcmToken
            
        }
        // Override point for customization after application launch.
        
//        if UIDevice.current.isJailBroken {
//            UIControl().sendAction(#selector(NSXPCConnection.suspend),
//            to: UIApplication.shared, for: nil)
//            return true
//        }
        
//
//        if(isJailBroken()){
//            UIControl().sendAction(#selector(NSXPCConnection.suspend),
//            to: UIApplication.shared, for: nil)
//            return true
//        }
        // Use Firebase library to configure APIs
//        FirebaseApp.configure()
        
        //GADMobileAds.sharedInstance().start(completionHandler: nil)
        AuthManager.shared.deviceID = UIDevice.current.identifierForVendor!.uuidString
        //Stripe.setDefaultPublishableKey("pk_test_51HAhluBbRq9JnLoRKDsw3CDGKyK4eSJM3azRfCEIhslDKRx7r2eAEBQY8DPNTdCwdkPDI1Zk4gtePDc2bTPX3DXO00mtL8zBcN")
        Stripe.setDefaultPublishableKey(" pk_test_51HAhluBbRq9JnLoRKDsw3CDGKyK4eSJM3azRfCEIhslDKRx7r2eAEBQY8DPNTdCwdkPDI1Zk4gtePDc2bTPX3DXO00mtL8zBcN")
        
//       Stripe.setDefaultPublishableKey("pk_live_51HAhluBbRq9JnLoRON5BPxCf0Qm0ynOyvd9b5jdydm4bnUdIyHlmRpnZAyddgoyU5rxhcfgXmso4oFFHowUojsLI00Ofo4ttlf")
        

        //BTAppSwitch.setReturnURLScheme("com.quytech.greenentertainment.payments")
        navigateToRequiredScreen()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
                
        //
      //  Branch.setUseTestBranchKey(true)
        
        let branch: Branch = Branch.getInstance()
        
        // listener for Branch Deep Link data
        branch.initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
            
            guard let data = params as? [String: AnyObject] else { return }
            
            // Option 2: save deep link data to global model

            guard let videoId = data["video_id"] as? String else { return }
            if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                vc.isShareVideo = true
                vc.videoId = videoId
                vc.videoType = .gallery
                delay(delay: 0.1) {
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
            }
            print(params as? [String: AnyObject] ?? {})
        }
        // firebase notification
        
       // updateTime(type: "1", time_id: "")
        
        return true
    }

    
    // MARK :- Initial Setup
    func loadTabbarBase(){
        if let baseVC = UIStoryboard.tabbar.get(TabbarViewController.self) {
            self.navigationController = UINavigationController.init(rootViewController: baseVC)
        }
        self.navigationController.setNavigationBarHidden(true, animated: false)
        if self.window == nil {
            self.window = UIWindow.init(frame: UIScreen.main.bounds)
        }
        window?.rootViewController = self.navigationController
        window?.makeKeyAndVisible()
    }
    
    func loadLoginBase(){
        if let baseVC = UIStoryboard.auth.get(LoginViewController.self) {
            self.navigationController = UINavigationController.init(rootViewController: baseVC)
        }
        self.navigationController.setNavigationBarHidden(true, animated: false)
        if self.window == nil {
            self.window = UIWindow.init(frame: UIScreen.main.bounds)
        }
        window?.rootViewController = self.navigationController
        window?.makeKeyAndVisible()
    }
    
    func navigateToRequiredScreen(){
        
//        let remoteVideoLoader = HardcodeVideoLoader(videos: self.videos)
//        let avVideoLoader = HLSVideoLoader(identifier: "cacheHLSVideoIdentifier", store: store)
//        
//        
//        let videoViewController = VideoUIComposer.videoComposedWith(videoloader: remoteVideoLoader, avVideoLoader: avVideoLoader)
//        self.navigationController = UINavigationController.init(rootViewController: videoViewController)
//
//        self.navigationController.setNavigationBarHidden(true, animated: false)
//        if self.window == nil {
//            self.window = UIWindow.init(frame: UIScreen.main.bounds)
//        }
//        window?.rootViewController = self.navigationController
//        window?.makeKeyAndVisible()
                
        let userloggedin = UserDefaults.standard.value(forKey: "guestUser") as? Bool
        if (userloggedin == true) {
            
            if let baseVC = UIStoryboard.tabbar.get(TabbarViewController.self) {
                //baseVC.fromInitialTab = true
                self.navigationController = UINavigationController.init(rootViewController: baseVC)
            }
            
            self.navigationController.setNavigationBarHidden(true, animated: false)
            if self.window == nil {
                self.window = UIWindow.init(frame: UIScreen.main.bounds)
            }
            window?.rootViewController = self.navigationController
            window?.makeKeyAndVisible()
        }else{
            if let baseVC = UIStoryboard.auth.get(WalkthroughViewController.self){
                baseVC.fromInitial = true
                self.navigationController = UINavigationController.init(rootViewController: baseVC)
            }
            self.navigationController.setNavigationBarHidden(true, animated: false)
            if self.window == nil {
                self.window = UIWindow.init(frame: UIScreen.main.bounds)
            }
            window?.rootViewController = self.navigationController
            window?.makeKeyAndVisible()
            
        }
    }
    
    func clearDiskCache() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent("")
        guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            do{
                try fileManager.removeItem(at: filePath)
            } catch let error as NSError {
                print("Couldn't remove existing destination file: \(error)")
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
       // updateTime(type: "1", time_id: "")
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("resign")
        updateTime(type: "2",time_id: UserDefaults.standard.string(forKey: "user_app_time_id") ?? "" )
        clearDiskCache()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        updateTime(type: "1", time_id: "")
        DispatchQueue.main.async {
            URLCache.shared.removeAllCachedResponses()
//            self.getAppVersion() 📌
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //SKPaymentQueue.default().remove(iapObserver)
        ///updateTime(type: "2",time_id: UserDefaults.standard.string(forKey: "user_app_time_id") ?? "" )
    }
}

extension AppDelegate {
    func updateTime(type: String,time_id: String) {
        var param = [String : Any]()
        param["type"] = type
        if type == "2"{
        param["user_app_time_id"] = time_id
        }
        if let userId = AuthManager.shared.loggedInUser?.user_id {
            param["user_id"] = userId
        }else {
            param["user_id"] = "0"
        }
        WebServices.updateAppTime(params: param) { (response) in
            if let dat = response?.object{
                UserDefaults.standard.set(dat.user_app_time_id, forKey: "user_app_time_id")
            }
        }
    }
}


// MARK:- Firebase configuration
extension AppDelegate {
    
    func registerForNotification(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AuthManager.shared.fcmToken = fcmToken
        if AppFunctions.getUserID() != "" {
            APIService.singelton.saveNotifToken(id: AppFunctions.getUserID(), token: fcmToken!)
        }
        Logs.show(message: "FCM TOKEN: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /*if let dict = notification.request.content.userInfo as? [String: Any], let notification_type = dict["notification_type"] as? String, notification_type == "SEND_CHAT_MESSAGE", let chatter_id = dict["user_id"] as? String {
            print(dict.debugDescription)
            if let controller = APPDELEGATE.navigationController.viewControllers.last, let chatController = controller as? ChatViewController {
               /* if chatController.user.user_id == dict["user_id"] as? String {
                    let obj = Chat()
                    obj.chat_text = dict["chat_text"] as? String ?? ""
                    obj.receiver_id = dict["receiver_id"] as? String ?? ""
                    obj.chat_id = dict["chat_id"] as? String ?? ""
                    obj.user_id = chatter_id
                    obj.created_timestamp = dict["created_timestamp"] as? String ?? ""
                    obj.url = dict["url"] as? String ?? ""
                    obj.read_status = "1"
                    obj.video_path = dict["video_path"] as? String ?? ""
                    obj.video_id = dict["video_id"] as? String ?? ""
                    obj.share_message = dict["share_message"] as? String ?? ""
                    obj.video_thumbnail = dict["video_thumbnail"] as? String ?? ""
                    obj.chat_type = dict["chat_type"] as? String ?? ""
                    if !(obj.video_thumbnail?.isEmpty ?? false) {
                        obj.chat_type = "3"
                    }
                    
                    chatController.updateChatList(object: obj)
                    
                    completionHandler([])
                }else {*/
                    completionHandler([.alert, .sound, .badge])
                //}
            }
        } else if let dict = notification.request.content.userInfo as? [String: Any], let notification_type = dict["notification_type"] as? String {
            if notification_type == Constants.kLIVE_STREAMING_ON || notification_type == Constants.kLIVE_STREAMING_END  {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLive"), object: nil, userInfo: nil)
                
            }
            
            completionHandler([.alert, .sound, .badge])
        }*/
        Logs.show(message: "willPresent: \(notification.request.content.userInfo)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let dict = response.notification.request.content.userInfo as? [String: Any] {
            print(dict.debugDescription)
            //handlePushNotification(response: response)
        }
        Logs.show(message: "didReceive: \(response.notification.request.content.userInfo)")

        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    
    
    func handlePushNotification(response: UNNotificationResponse) {
        if let dict = response.notification.request.content.userInfo as? [String: Any], let notification_type = dict["notification_type"] as? String  {
            switch notification_type {
            case Constants.kSEND_CHAT_MESSAGE:
                    print("")
                /*if let controller = APPDELEGATE.navigationController.viewControllers.last, let chatController = controller as? ChatViewController {
                    chatController.user.user_id = dict["user_id"] as? String
                    chatController.user.first_name = dict["sender_name"] as? String ?? ""
                    chatController.user.image = dict["sender_image"] as? String ?? ""
                    chatController.customSetup()
                    chatController.getMessageHistory()
                }else {*/
                    
                    if let chatter_id = dict["user_id"] as? String {
                        let name = dict["sender_name"] as? String ?? ""
                        let profile_image = dict["sender_image"] as? String ?? ""
                        self.navigateToChatScreen(id: chatter_id, name: name , profile_image: profile_image )
                    }
                //}
                break
            case Constants.kUSER_FOLLOW:
                if let user_id = dict["sender_id"] as? String {
                    self.navigateToUserScreen(id: user_id)
                }
            case Constants.kUSER_FOLLOW_REQUEST:
                if let vc = UIStoryboard.main.get(FriendRequestViewController.self) {
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
            case Constants.kVIDEO_SHARE:
                
                var arr = [RewardsModel]()
                let model = RewardsModel()
                model.is_following = Int(dict["is_following"] as? String ?? "")
                model.video_id = dict["video_id"] as? String
                model.video_path = dict["video_path"] as? String
                model.video_text = dict["video_text"] as? String
                model.is_posted = dict["is_posted"] as? String
                model.is_sponsered = dict["is_sponsered"] as? String
                model.user_id = dict["user_id_sharing_video"] as? String
                arr.append(model)
                
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.videoObj.video_path = dict["video_path"] as? String
                    vc.videoObj.video_thumbnail = dict["video_thumbnail"] as? String
                    vc.videoType = .gallery
                    vc.isShareVideo = true
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
                
            case  Constants.kMONEY_ADDED_TO_WALLET,Constants.kRANDOM_VOTER_PRIZE,Constants.kREFUND_TO_WALLET,Constants.kWITHDRAW_MONEY_FROM_WALLET,Constants.kWITHDRAW_MONEY_REQUEST_APPROVED,Constants.kDONATION_SENT, Constants.kDONATION_RECEIVED, Constants.kGIFT_PURCHASED :
                self.navigateToWalletScreen()
                
            case Constants.kWINNER_ANNOUNCEMENT, Constants.kWINNER_NOTIFIED :
                
                let blocked_status = dict["blocked_status"] as? Int
                let check_if_you_block = dict["check_if_you_block"] as? Int
                
               

                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.videoObj.aws_video_path = dict["video_path"] as? String
                    vc.videoObj.video_thumbnail = dict["video_thumbnail"] as? String
                    vc.videoObj.intro_video_path = dict["intro_video_path"] as? String
                    vc.videoObj.intro_video_thumbnail = dict["intro_video_thumbnail"] as? String
                    //vc.videoType = .winningVideo
                    vc.isShareVideo = false
                    vc.blocked_status = dict["blocked_status"] as? String
                    vc.check_if_you_block = dict["check_if_you_block"] as? String

                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                    
                }
            case Constants.kNEW_CHALLENGE_POSTED,Constants.kMONTHLY_CHALLENGE_VOTING_OPEN, Constants.kSIZZLE_SHOWCASEHOUR_DAILY,Constants.kLIVE_STREAMING_END,Constants.kMANUAL_NOTIFICATION,Constants.kSUBMISSION_OPEN,Constants.kDAILY_CHALLENGE_VOTING_OPEN:
                
                
                if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                    let navigationController = UINavigationController(rootViewController: vc)
                    navigationController.navigationBar.isHidden = true
                    APPDELEGATE.navigationController = navigationController
                    APPDELEGATE.window?.rootViewController = navigationController
                }
                
            case Constants.kGOT_NEW_BADGE:
                if let vc = UIStoryboard.profile.get(BadgeShareViewController.self){
                    vc.badgeName  = dict["badge_title"] as? String
                    vc.imageName = dict["badge_thumbnail"] as? String
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
                
            case Constants.kACCEPTED_REQUEST:
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.user.user_id  = dict["sender_id"] as? String
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
                
            case Constants.kVIDEO_VOTE:
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.isShareVideo = true
                    vc.videoId =  dict["video_id"] as? String ?? "0"
                    vc.videoType = .gallery
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                    
                }
                
            case Constants.kVIDEO_TAG:
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.isFromTagVideo = true
                    vc.videoId = dict["video_id"] as? String ?? "0"
                    vc.videoType = .gallery
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
                
            case Constants.kREWARD_CLAIMED:
                if let vc = UIStoryboard.main.get(MyRewardsViewController.self){
                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                }
                
            case Constants.kLIVE_STREAMING_ON:
                    print("")
//                if let vc = UIStoryboard.main.get(LiveWinnerViewController.self){
//                    vc.token  = dict["token"] as? String ?? ""
//                    vc.challengeId = dict["challenge_id"] as? String ?? ""
//                    vc.encoded_token = dict["encoded_token"] as? String ?? ""
//                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
//                }
                
            default:
                break
            }
            
        }
    }
    
    func navigateToChatScreen(id: String, name: String, profile_image: String ) {
        if let vc = UIStoryboard.message.get(ChatViewController.self) {
            /*vc.user.user_id = id
            vc.user.first_name = name
            vc.user.image = profile_image*/
            APPDELEGATE.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToUserScreen(id: String ) {
        if let vc = UIStoryboard.profile.get(UserProfileViewController.self) {
            vc.user.user_id = id
            APPDELEGATE.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToWalletScreen() {
        if let vc = UIStoryboard.wallet.get(WalletViewController.self) {
            APPDELEGATE.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: - Receive Dynamic Link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        //Branch.getInstance().continue(userActivity)
       // return Branch.getInstance().continue(userActivity)
        return Branch.getInstance().continue(userActivity)
      //  return true
    }
 
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
       return Branch.getInstance().application(app, open: url, options: options)
    //

        /*
        
        if let dynamiclink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url), url.absoluteString.contains("squabblewin.page.link") {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            
            guard let isContain = dynamiclink.url?.absoluteString.contains(find: "squabblewin.page.link") else { return false }
            if isContain{
                let url = dynamiclink.url?.absoluteString
                let courseID = url?.components(separatedBy: "=").last

            }
            return true
        }
        return true
 */
    }
    /*
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let webPageUrl = userActivity.webpageURL {
            let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webPageUrl) { (dynamiclink, error) in
                if error == nil {
                    if(dynamiclink?.url?.absoluteString.contains("squabblewin.page.link"))!{
                        let url = dynamiclink?.url?.absoluteString
                        if url?.contains("videoID") ?? false  {
                            let videoId = url?.components(separatedBy: "=").last
                              print("videoIddd:-\(videoId ?? "nULLL")")
                            if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                                vc.isShareVideo = true
                                vc.videoId = videoId ?? ""
                                vc.videoType = .gallery
                                delay(delay: 0.1) {
                                    APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }else {
//                    URLSession.shared.dataTask(with: webPageUrl) { (data, response, error) in
//
//                                if let actualURL = response?.url {
//                                    print("actualURL:-\(actualURL)")
//
//                                    // you will get actual URL from short link here
//
//                                    // e.g short url was
//                                    // https://sampleuniversallink.page.link/hcabcx2fdkfF5U
//
//                                    // e.g actual url will be
//                                    // https://www.example.com/somePage?quertItemkey=quertItemvalue...
//                                }
//                            }.resume()
                    delay(delay: 0.5) {
                        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webPageUrl) { (dynamiclink, error) in
                            if error == nil {
                                if(dynamiclink?.url?.absoluteString.contains("squabblewin.page.link"))!{
                                    let url = dynamiclink?.url?.absoluteString
                                    if url?.contains("videoID") ?? false  {
                                        let videoId = url?.components(separatedBy: "=").last
                                          print("videoIddd:-\(videoId ?? "nULLL")")
                                        if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                                            vc.isShareVideo = true
                                            vc.videoId = videoId ?? ""
                                            vc.videoType = .gallery
                                            delay(delay: 0.1) {
                                                APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }
            return handled
        }else {
            delay(delay: 0.8) {
                if let webPageUrl = userActivity.webpageURL {
                    let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webPageUrl) { (dynamiclink, error) in
                        if error == nil {
                            if(dynamiclink?.url?.absoluteString.contains("squabblewin.page.link"))!{
                                let url = dynamiclink?.url?.absoluteString
                                if url?.contains("videoID") ?? false  {
                                    let videoId = url?.components(separatedBy: "=").last
                                      print("videoIddd:-\(videoId ?? "nULLL")")
                                    if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                                        vc.isShareVideo = true
                                        vc.videoId = videoId ?? ""
                                        vc.videoType = .gallery
                                        delay(delay: 0.1) {
                                            APPDELEGATE.navigationController.pushViewController(vc, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true
        }
    }
    */
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
//            if navigationController.visibleViewController is LiveWinnerViewController {
//                return UIInterfaceOrientationMask.all
//            }else {
                return UIInterfaceOrientationMask.portrait
//            }
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    
    func isJailBroken() -> Bool{
        
        #if targetEnvironment(simulator)
        return false
        #else
        let url = URL.init(fileURLWithPath: "cydia://package/com.example.package")
        return UIApplication.shared.canOpenURL(url)
        #endif
        
    }
    
}

extension AppDelegate {
    //app update
    
    func getAppVersion() {
        let url = String(format:"http://itunes.apple.com/lookup?id=%@","1561097344")
        let clientTokenURL = URL(string: url)!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL)
        clientTokenRequest.httpMethod = "GET"
        clientTokenRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                DispatchQueue.main.async(execute: {
                })
                return
            }
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            let json: AnyObject? = responseString!.parseJSONString
            if json != nil
            {
                let result = json as? NSDictionary
                let configData = result?.value(forKey: "results") as? NSArray ?? []
                for config in configData
                {
                    DispatchQueue.main.async(execute: {
                        let  version = (config as AnyObject).value(forKey: "version") as? NSString ?? ""
                        var versionLatest = ""
                        versionLatest=version as String
                        self.checkForAppUpdate(versionLatest: versionLatest)
                    })
                }
            }
            else{
                DispatchQueue.main.async(execute: {
                })
            }
            
        }) .resume()
    }
    func checkForAppUpdate(versionLatest:String) {
        
        let minAppVersion = versionLatest
        print("minnnnn",minAppVersion)
        
        guard let info = Bundle.main.infoDictionary else {
            return
        }

        guard let appVersion = info["CFBundleShortVersionString"] as? String else {
            return
        }
        
        
        //Compare App Versions
        let minAppVersionComponents : NSArray = minAppVersion.components(separatedBy: ".") as NSArray
        let appVersionComponents : NSArray = appVersion.components(separatedBy: ".") as NSArray
        
        var needToUpdate = false
        
        for i in 0..<min(minAppVersionComponents.count, appVersionComponents.count)
        {
            let minAppVersionComponent = minAppVersionComponents.object(at: i) as? String ?? ""
            let appVersionComponent = appVersionComponents.object(at: i) as? String ?? ""
            let minApp: String = minAppVersionComponent
            let appVer: String = appVersionComponent
            
            if (minApp != appVer)
            {
                needToUpdate = (appVer < minApp)
                break;
            }
        }
        
        if (needToUpdate) {
            AlertController.alert(title: "New Version Available", message: "A new version of Squabble is available! Click below or go to your App Store to update now!", buttons: ["Update to new version"]) { (alert, index) in
                if index == 0 {
                    UIApplication.shared.open(URL(string : "https://itunes.apple.com/us/app/squabble-win/id1561097344?mt=8")!, options: [:], completionHandler: nil)
                }
            }
        }
    }
}





///branch
//test
//ypa7x.test-app.link
//ypa7x-alternate.test-app.link
//key_test_fgZd86m4JhNIAiyg6nfY2medzucvWu1Q
///live
//ypa7x.app.link
//ypa7x-alternate.app.link
//key_live_mb9k20f4QiUKvgEa7hoWTlgfyvlzWy4y
