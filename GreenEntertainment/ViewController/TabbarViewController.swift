//
//  TabbarViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController,UITabBarControllerDelegate {
    
   /* //var videoController : ChallengeListViewController?
    var fromInitialTab = false
    let imagePickerController = UIImagePickerController()
    //var file: AttachmentInfo?
    var videoCount = 0
    var dynamic_error_message = ""
    
    var videoUploadStatus = 0
    var video_upload_access_error_message = ""
    
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        
//        if fromInitialTab {
//
//            if let vc = UIStoryboard.challenge.get(ChallengeListViewController.self) {
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
//
//        }else{
//
//        }
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge(notfication:)), name: NSNotification.Name(rawValue: "NotificationCount"), object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        let moveProfile = UserDefaults.standard.value(forKey: "movetoProfile") as? Bool
        if (moveProfile == true){
            self.selectedIndex = 4
            
        }
        
        if !(AuthManager.shared.loggedInUser?.auth_token?.isEmpty ?? true) {
            self.getCountApi()
        }
        
    }
    
    override var   supportedInterfaceOrientations : UIInterfaceOrientationMask{
        
        return  .portrait
        
    }
    
    
    @objc func updateBadge(notfication: NSNotification) {
//        if !(AuthManager.shared.loggedInUser?.auth_token?.isEmpty ?? true) {
//            self.getCountApi()
//        }
    }
    
    
    //MARK:- Tabbar Controller Delegate Method
    
    /*\func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = self.viewControllers?.firstIndex(of: viewController)
        Logs.show(message: "INDEX: \(String(describing: index))")

        if index == 1{
            tabBarController.selectedIndex = 0
            if let vc = UIStoryboard.challenge.get(ChallengeListViewController.self){
                videoController = vc
                self.navigationController?.pushViewController(vc, animated: false)
            }
            return false
        }else if(index == 2){
            tabBarController.selectedIndex = 0

            if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                if !(AuthManager.shared.loggedInUser?.auth_token?.isEmpty ?? true) {
                    self.getCountApi(isFromAdd: true)
                }
                
            }else {
                AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                    if index == 0 {
                        if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.navigationBar.isHidden = true
                            APPDELEGATE.navigationController = navigationController
                            APPDELEGATE.window?.rootViewController = navigationController
                        }
                    }
                }
            }
            
            return false
        }
        
        else if (index == 4) {
            
            if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                return true
                
            } else {
                AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                    if index == 0 {
                        if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.navigationBar.isHidden = true
                            APPDELEGATE.navigationController = navigationController
                            APPDELEGATE.window?.rootViewController = navigationController
                        }
                    }
                }
            }
        }
        
        else if (index == 3) {
            
            if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                return true
                
            }else {
                AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                    if index == 0 {
                        if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.navigationBar.isHidden = true
                            APPDELEGATE.navigationController = navigationController
                            APPDELEGATE.window?.rootViewController = navigationController
                        }
                    }
                }
            }
        }
        
        else{
            if viewController.isKind(of: ChallengesFeedViewController.self)   {
                return true
            }else{
                return false
            }
        }
        
        return false
        //
    }*/
    
    /*\override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if !(AuthManager.shared.loggedInUser?.auth_token?.isEmpty ?? true) {
            self.getCountApi()
        }
        if item.tag == 1 {
            
            if let vc = UIStoryboard.challenge.get(ChallengeListViewController.self){
                videoController = vc
                videoController?.completion = {
                    self.tabBarController?.selectedViewController = vc
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }
            
            
        }
    }*/
    
}


extension TabbarViewController {
    func showActionSheet() {
        
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor = .red
        
        let appGalleryAction = UIAlertAction(title: "Gallery", style: .default, handler:
                                                {
                                                    (alert: UIAlertAction!) -> Void in
                                                    self.openGallery()
                                                })
        
        let libraryAction = UIAlertAction(title: "Library", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                self.openLibrary()
                                            })
        
        let shootAction = UIAlertAction(title: "Shoot", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                self.openShoot()
                                            })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                print("Cancelled")
                                            })
        
        optionMenu.addAction(appGalleryAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(shootAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func openShoot(){
        if let vc = UIStoryboard.challenge.get(ChallengeShootViewController.self){
            navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
    func openGallery(){
        if let vc = UIStoryboard.challenge.get(GalleryViewController.self){
            vc.isFromTabBar = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = ["public.movie"]
            imagePickerController.videoMaximumDuration = 60
            imagePickerController.isEditing = true
            imagePickerController.allowsEditing = true
           imagePickerController.videoQuality = .typeHigh
            if #available(iOS 11.0, *) {
                imagePickerController.videoExportPreset = AVAssetExportPresetHighestQuality
            }
            present(imagePickerController, animated: true, completion: nil)
        }
    }
}

extension TabbarViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        let videoURL = info[.mediaURL] as? NSURL
        print("Image Info:::\(info)")
        print("videoURL:::\(videoURL?.absoluteString ?? "")")
        if let url = videoURL {
            //for check video
            //        let file = FileInfo(withFileURL: url as URL)
            //        if (file.totalDuration ?? 0) > 180  {
            //            AlertController.alert(message: "Video file is too large.")
            //            return
            //        }
            
            let asset = AVURLAsset.init(url: url as URL) // AVURLAsset.init(url: outputFileURL as URL) in swift 3
            // get the time in seconds
            let durationInSeconds = asset.duration.seconds
            print("==== Duration is ",durationInSeconds)
            
            if Int(durationInSeconds) < 5 {
                Alerts.shared.show(alert: .warning, message: ValidationMessage.MinimumVideoLimit.rawValue, type: .warning)
            }
            
            else if Int(durationInSeconds) > 60 {
                Alerts.shared.show(alert: .warning, message: "Video file is too large.", type: .warning)
                //  AlertController.alert(message: "Video file is too large.")
                return
            }else  {
                //   self.compressVideoFromLibrary(videoUrl: url as URL)
                
                if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
                    vc.videoURL = url as URL
                    vc.thumbnailImage = self.getThumbnailImage(forUrl: url as URL)!
                    vc.isFromLibrary = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
                //                guard let compressedData = NSData(contentsOf: url as URL)else { return }
                //                self.callApiForSaveVideo(data: compressedData, url: url as URL)
            }
            
            
        }
    }
    
}

extension TabbarViewController {
    func getCountApi(isFromAdd: Bool = false){
        WebServices.getCounts { (response) in
            if let obj = response?.object {
                self.videoCount = obj.video_count ?? 0
                self.dynamic_error_message = obj.dynamic_error_message ?? ""
                self.videoUploadStatus = obj.check_video_upload_access ?? 0
                self.video_upload_access_error_message = obj.video_upload_access_error_message ?? ""
                if obj.unread_notification_count == 0 {
                    self.tabBar.items![3].badgeValue = nil
                }else {
                    self.tabBar.items![3].badgeValue = "\(obj.unread_notification_count ?? 0)"
                }
                if isFromAdd {
                    
                    if self.videoUploadStatus == 0 {
                        AlertController.alert(message: self.video_upload_access_error_message)
                    }else {
                        if self.videoCount == 20 {
                            AlertController.alert(message: self.dynamic_error_message)
                        }else {
                            self.showActionSheet()
                        }
                    }
                    
                }
            }
        }
    }
    
    
    func callApiForSaveVideo(data:NSData, url : URL){
        var params = [String: Any]()
        params["is_save_to_gallery"] = 0
        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
        var videoData = self.file ?? AttachmentInfo()
        videoData.apiKey = Constants.kVideo_File
        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
            if let obj = resposne?.object  {
                if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
                    vc.videoID = obj.video_id
                    vc.videoURL = url
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
}

extension TabbarViewController {
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage).fixOrientation
        } catch let error {
            print(error)
        }
        
        return nil
    }
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType =  AVFileType.mp4 //AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func compressVideoFromLibrary(videoUrl : URL) {
        compressVideo(inputURL: videoUrl, outputURL: self.compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: self.compressedURL)else { return }
                self.callApiForSaveVideo(data:compressedData, url: videoUrl)
            
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }*/
}
