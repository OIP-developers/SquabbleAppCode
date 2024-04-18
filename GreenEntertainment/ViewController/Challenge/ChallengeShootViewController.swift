//
//  ChallengeShootViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 11/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import UICircularProgressRing
import Firebase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseStorage
import SwiftUI


class ChallengeShootViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var progressView: UICircularProgressRing!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deletelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var shootImageView: UIImageView!
    @IBOutlet weak var crossView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet var mainView: UIView!
    
    
    //required variables for custom camera
    var timer = Timer()
    var frontCamera = true
    let cameraController = CameraController()
    let cameraEngine = CameraEngine()
    var counter = 0
    var isCameraForImageMode = false
    var backCompletion: (() -> Void)?  = nil
    var challengeId : String?
    var videoId : String?
    var challengeName : String?
    var homeObj = HomeModel()
    var file: AttachmentInfo?
    var isFromList = false
    
    var isForChallange = false
    var challangeType = ""
    
    var imagePicker = UIImagePickerController()

    
    //
    var isCross: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.overlayView.isHidden = !self.isCross
            }
        }
    }
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInitialDataForCamera()
        counter = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cameraController.stopSession()
        self.cameraController.previewLayer?.removeFromSuperlayer()
    }
    
    //MARK:- Helper Method
    //required functions for custom camera
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            // Display camera preview..
            try? self.cameraController.displayPreview(on: self.mainView)
        }
    }
    
    func customSetup(){
        isCross = false
        overlayView.isUserInteractionEnabled = true
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapAction))
        overlayView.addGestureRecognizer(viewTap)
    }
    
    func allowPermissionForCamera() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        var returnStatus = false
        switch status {
        case .authorized:
            returnStatus = true
        case .denied,.restricted:
            returnStatus = false
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        returnStatus = true
                    } else {
                        returnStatus = false
                    }
                }
            }
        @unknown default:
            break
        }
        return returnStatus
    }
    
    func allowPermissionForMicrophone() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        var returnStatus = false
        switch status {
        case .authorized:
            returnStatus = true
        case .denied,.restricted:
            returnStatus = false
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        returnStatus = true
                    } else {
                        returnStatus = false
                    }
                }
            }
        @unknown default:
            break
        }
        return returnStatus
    }
    
    func setInitialDataForCamera(){
        progressView.resetProgress()
        progressView.maxValue = 60
        progressView.style = .ontop
        progressView.startAngle = 270.0
        startButton.setImage(UIImage(named: "butn_start"), for: .normal)
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            self.configureCameraController()
        case .denied,.restricted:
            
            AlertController.alert(title: "Required Camera Access", message: "Please allow device camera to record video.", buttons: ["Settings","Cancel"]) { (action, index) in
                if(index == 0){
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else{
                }
                
            }
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureCameraController()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        @unknown default:
            break
        }
        // audio permission
        let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch audioStatus {
        case .authorized:
            print("authorized")
        case .denied,.restricted:
            AlertController.alert(title: "Required Microphone Access", message: "Please allow device microphone to record audio.", buttons: ["Settings","Cancel"]) { (action, index) in
                if(index == 0){
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else{
                }
                
            }
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("granted")
                    }
                    else {
                        print("denied")
                    }
                }
            }
        @unknown default:
            break
        }
        
    }
    
    func startVideoTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    func stopTimer()  {
        self.timer.invalidate()
    }
    func refreshCameraUIForRetake() {
        lblTimer.text = "00:00"
        lblTimer.isHidden = true
        startButton.tag = 101;
        startButton.setImage(UIImage(named: "icn_camera"), for: .normal)
    }
    
    func getThumbnailImageForVideoAtURL(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 4, preferredTimescale: 30)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print(error.localizedDescription)
            return UIImage(named: "record")
        }
    }
    
    //MARK:- Target Method
    
    @objc func updateTimerLabel() {
        counter += 1
        lblTimer.isHidden = false
        lblTimer.text = String(format: "00:%02d", counter)
        UIView.animate(withDuration: 0.001) {
            self.progressView.value = CGFloat(self.counter)
            self.view.layoutIfNeeded()
        }
        
        if counter == 60 {
            stopTimer()
            counter = 0
            cameraController.stopRecording { (videoURL, error) in
                if (error == nil) {
                    guard self.getThumbnailImageForVideoAtURL(url: videoURL!) != nil else {
                        print(error ?? "Image thumbnail error")
                        return
                    }
                    DispatchQueue.main.async {
                        if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
                            vc.videoURL = videoURL! as URL
                            vc.thumbnailImage = self.getThumbnailImageForVideoAtURL(url: videoURL!)!
                            vc.challengeId = self.challengeId
                            vc.homeObj = self.homeObj
                           
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                        self.refreshCameraUIForRetake()
                    }
                }
            }
        }
    }
    
    @objc func viewTapAction(){
        isCross = false
    }
    
    
    
    // MARK: - UIButton Action
    
    // Toogle Camera
    @IBAction func toogleCameraAction(_ sender: Any) {
        do {
            try cameraController.switchCameras()
            frontCamera = !frontCamera
        }
        catch {
            print(error)
        }
    }
    
    
    // Capture Image/Video
    @IBAction func captureVideoAction(_ sender: Any) {
        
        if (Auth.auth().currentUser?.uid == nil) {
            AppFunctions.showSnackBar(str: "You need to login before posting Challenge")
            return
        }
        
        if !allowPermissionForCamera() {
            AlertController.alert(title: "Required Camera Access", message: "Please allow device camera to record video.", buttons: ["Settings","Cancel"]) { (action, index) in
                if(index == 0){
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else{
                }
                
            }
        }else if !allowPermissionForMicrophone() {
            AlertController.alert(title: "Required Microphone Access", message: "Please allow device microphone to record audio.", buttons: ["Settings","Cancel"]) { (action, index) in
                if(index == 0){
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else{
                }
            }
        }else {
            
            
            
            if isCameraForImageMode {
                //for image
                cameraController.captureImage {(image, error) in
                    guard image != nil else {
                        print(error ?? "Image capture error")
                        return
                    }
                }
            }
            else{
                // Capture Video
                let button = sender as! UIButton
                if button.tag == 101 {
                    // start capture
                    button.setImage(UIImage(named: "ic_pause"), for: .normal)
                    button.tag = 102
                    cameraController.startRecording()
                    lblTimer.isHidden = false
                    startVideoTimer()
                }
                else if button.tag == 102 {
                    // pause capture
                    button.setImage(UIImage(named: "icn_pause"), for: .normal)
                    button.tag = 103
                    cameraController.pauseRecording()
                    stopTimer()
                }
                else if button.tag == 103 {
                    // resume capture
                    button.setImage(UIImage(named: "ic_pause"), for: .normal)
                    button.tag = 102
                    cameraController.resumeRecording()
                    startVideoTimer()
                }
            }
        }
        
    }
    @IBAction func saveButtonAction(_ sender: UIButton) {
        stopTimer()
        if (counter < 5){
            if counter == 0 {
                startButton.setImage(UIImage(named: "butn_start"), for: .normal)
                startButton.tag = 101
                AlertController.alert(title: "Alert", message: ValidationMessage.MinimumVideoLimit.rawValue)
            }else {
                startButton.setImage(UIImage(named: "butn_start"), for: .normal)
                startButton.tag = 103
                cameraController.pauseRecording()
                AlertController.alert(title: "Alert", message: ValidationMessage.MinimumVideoLimit.rawValue)
            }
            
        }else{
            stopTimer()
            
            cameraController.stopRecording { (videoURL, error) in

                if (error == nil) {
                    guard self.getThumbnailImageForVideoAtURL(url: videoURL!) != nil else {
                        print(error ?? "Image thumbnail error")
                        return
                    }
                    self.compressAndNevigate(videoURL: videoURL!)
                }
            }
        }
    }
    
    func compressAndNevigate(videoURL: URL) {
        
        if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self) {
            vc.videoURL = videoURL as URL
            vc.thumbnailImage = self.getThumbnailImageForVideoAtURL(url: videoURL)!
            vc.challengeId = self.challengeId
            vc.challengeName = self.challengeName ?? ""
            vc.homeObj = self.homeObj
            vc.isForChallange = self.isForChallange
            delay(delay: 0.1) {
                DispatchQueue.main.async {
                    ProgressHud.hideActivityLoader()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    func sizeOfFile(data: Data) -> String {
        let imageSize: Int = data.count
        Logs.show(message:"There were \(imageSize) bytes")
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(imageSize))
    }
    
    
    @IBAction func deleteButtonAction(_ sender: UIButton){
        startButton.setImage(UIImage(named: "icn_stop"), for: .normal)
        startButton.tag = 103
        cameraController.pauseRecording()
        stopTimer()
        
        AlertController.alert(title: "Alert", message: "Are you sure you want to leave this recording?", buttons: ["Yes","No"]) { (action, index) in
            if(index == 0){
                self.tabBarController?.selectedIndex = 0
                self.navigationController?.popViewController(animated: true)
            }else{
                self.startButton.setImage(UIImage(named: "butn_start"), for: .normal)
                self.startButton.tag = 102
                self.cameraController.resumeRecording()
                self.startVideoTimer()
            }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton){
        isCross = true
    }
    
    @IBAction func galleryButtonAction(_ sender: UIButton){
        
        if (Auth.auth().currentUser?.uid == nil) {
            AppFunctions.showSnackBar(str: "You need to login before posting Challenge")
            return
        }

        
        self.cameraController.stopSession()
        self.cameraController.previewLayer?.removeFromSuperlayer()
        stopTimer()
        counter = 0
        DispatchQueue.main.async {
            self.isCross = false
            self.refreshCameraUIForRetake()
            self.setInitialDataForCamera()
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.videoMaximumDuration = 60; // duration in seconds
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
//        if let vc = UIStoryboard.challenge.get(GalleryViewController.self) {
//            self.present(vc, animated: true)
//            //self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[.mediaURL] as? URL
        print(videoURL!)
        compressAndNevigate(videoURL: videoURL!)
        imagePicker.dismiss(animated: true,completion: nil)//.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func reshootButtonAction(_ sender: UIButton){
        self.cameraController.stopSession()
        self.cameraController.previewLayer?.removeFromSuperlayer()
        stopTimer()
        counter = 0
        DispatchQueue.main.async {
            self.isCross = false
            self.refreshCameraUIForRetake()
            self.setInitialDataForCamera()
        }
    }
    
    @IBAction func leaveButtonAction(_ sender: UIButton){
        self.backCompletion?()
        overlayView.isHidden = true
        self.tabBarController?.selectedIndex = 0
        if isFromList {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension ChallengeShootViewController {
    func callApiForSaveVideo(data:NSData, url : URL){
        var params = [String: Any]()
        params["is_save_to_gallery"] = 0
        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
        var videoData = self.file ?? AttachmentInfo()
        videoData.apiKey = Constants.kVideo_File
        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
            if let obj = resposne?.object  {
                
                if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self){
                    vc.homeObj = self.homeObj
                    vc.videoID = obj.video_id
                    vc.videoURL = url
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
    }
}


extension ChallengeShootViewController {
    
    func cropVideo(sourceURL1: URL) {
        ProgressHud.showActivityLoader()
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let mediaType = "mp4"
        if  mediaType == "mp4" as String {
            let asset = AVAsset(url: sourceURL1 as URL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            
            let start = 0.6
            let end = length
            
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).\(mediaType)")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    self.counter = 0
                    self.refreshCameraUIForRetake()
                    
                    if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
                        vc.videoURL = outputURL as URL
                        vc.thumbnailImage = self.getThumbnailImageForVideoAtURL(url: outputURL)!
                        vc.challengeId = self.challengeId
                        vc.challengeName = self.challengeName ?? ""
                        vc.homeObj = self.homeObj
                        vc.isForChallange = self.isForChallange
                        vc.challangeType = self.challangeType
                        delay(delay: 0.1) {
                            ProgressHud.hideActivityLoader()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                case .failed: break
                    
                case .cancelled: break
                    
                default: break
                }
            }
        }
    }
}
