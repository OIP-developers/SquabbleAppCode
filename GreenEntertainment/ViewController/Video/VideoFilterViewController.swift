//
//  VideoFilterViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 18/09/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AVKit
import CoreImage
import Firebase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseStorage


//import BBMetalImage

class VideoFilterViewController: UIViewController {
    
    
    @IBOutlet weak var videPlayerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgViewPreview: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var doubleTapForward: UIButton!
    @IBOutlet weak var doubleTapBackward: UIButton!
    
    @IBOutlet weak var centerPlayButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var videoSize = CGSize.zero
    var homeObj = HomeModel()
    var thumbnailImage = UIImage()
    var player = AVPlayer()
    private var playerLayer: AVPlayerLayer!
    
    var videoFinshed = false
    var backButtonTapped = false
    var videoType: VideoType = .myPost
    var isPhotoPreview = false
    var challengeName = ""
    var videoURL: URL?
    var file: AttachmentInfo?
    var videoObj = RewardsModel()
    var aVAudioPlayer: AVAudioPlayer?
    var tempUrl: URL?
    let context = CIContext(options: nil)
    
    var isFromLibrary = false
    var isForChallange = false
    var challangeType = ""
    var selectedIndex = 0
    
    var videoID : Int?
    var challengeId : String?
    var data : NSData?
    var url = ""
    var isPost = false
    
    fileprivate var playerItem: AVPlayerItem!
    
    
    fileprivate var avVideoComposition: AVVideoComposition!
    fileprivate var video: AVURLAsset?
    
    
    public typealias CompletionBlock = (_ success: Bool, _ data: Data, _ error: Error?) -> Void
    
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
    
    
    
    
    let filterNameList = [
        "CIBoxBlur",
        "CIVibrance",
        "CIHueAdjust",
        "CIPhotoEffectNoir",
        "CISharpenLuminance",
        "CIGammaAdjust",
        "CIHighlightShadowAdjust",
        "CIExposureAdjust",
        "CIGaussianBlur",
        "CIColorControls",    //Saturation
        "CILinearToSRGBToneCurve"
    ]
    
    let filterDisplayNameList = [
        "Normal",
        "Vibrance",
        "Hue",
        "Luminance",
        "Sharpen",
        "Gamma",
        "Highlight Shadow",
        "White Balance",
        "Bilateral",
        "Saturation",
        "Haze"
    ]
    
    var imageArray = [UIImage]()
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let size =  self.resolutionSizeForLocalVideo(url: videoURL!)
        videoSize = size ?? .zero
        
        let asset = AVURLAsset.init(url: videoURL!)
        video = asset
        self.playerItem = AVPlayerItem(asset: video!)
        self.setUpVideoPlayerViewController(avPlayerItem: self.playerItem)
        delay(delay: 1) {
            self.player.play()
        }
        
        
        doubleTapForward.addTarget(self, action: #selector(multipleTapForward(_:event:)), for: UIControl.Event.touchDownRepeat)
        doubleTapBackward.addTarget(self, action: #selector(multipleTapBackward(_:event:)), for: UIControl.Event.touchDownRepeat)
        
        customiseView()
        createFilteredImage()
        // applyFilterOnImage()
        // Do any additional setup after loading the view.
        applyFilterOnVideo(filterName: filterNameList[0], filterIndex: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.pause()
        // self.player.replaceCurrentItem(with: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        player.pause()
    }
    
    //MARK:- Helper Method
    func customiseView(){
        
    }
    
    func initialMethod(){
        
    }
    
    func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    
    func createFilteredImage()  {
        for filterName in self.filterNameList {
            if filterName == "CIBoxBlur" {
                imageArray.append(thumbnailImage)
            } else {
                // 1 - create source image
                let sourceImage = CIImage(image: thumbnailImage)
                
                // 2 - create filter using name
                let filter = CIFilter(name: filterName)
                filter?.setDefaults()
                
                if filterName == "CIHueAdjust" {
                    filter?.setValue(fmodf(90, 360) * Float.pi / 180, forKey: "inputAngle")
                }
                if filterName == "CIVibrance" {
                    filter?.setValue(1, forKey: "inputAmount")
                }
                if filterName == "CIGammaAdjust"{
                    filter?.setValue(1.5, forKey: "inputPower")
                }
                if filterName == "CIHighlightShadowAdjust"{
                    filter?.setValue(0.5, forKey: "inputHighlightAmount")
                    filter?.setValue(0.5, forKey: "inputShadowAmount")
                }
                if filterName == "CITemperatureAndTint"{
                    //            filter?.setValue(CIVector(x: 6500, y: 500), forKey: "inputNeutral")
                    //            filter?.setValue(CIVector(x: 1000, y: 630), forKey: "inputTargetNeutral")
                    
                    filter?.setValue(CIVector(x: 13000, y: 1000), forKey: "inputNeutral")
                    filter?.setValue(CIVector(x: 1000, y: 500), forKey: "inputTargetNeutral")
                }
                
                if filterName == "CIExposureAdjust"{
                    filter?.setValue(0.8, forKey: "inputEV")
                }
                
                
                if filterName == "CIGaussianBlur"{
                    filter?.setValue(3, forKey: "inputRadius")
                }
                
                if filterName == "CIColorControls"{
                    filter?.setValue(2, forKey: "inputSaturation")
                    
                }
                
                // 3 - set source image
                filter?.setValue(sourceImage, forKey: kCIInputImageKey)
                
                // 4 - output filtered image as cgImage with dimension.
                let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
                
                // 5 - convert filtered CGImage to UIImage
                let filteredImage = UIImage(cgImage: outputCGImage!, scale: thumbnailImage.scale, orientation: thumbnailImage.imageOrientation)
                imageArray.append(filteredImage)
            }
            
        }
        
        
        self.collectionView.reloadData()
    }
    
    func rewindVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        var newTime = CMTimeGetSeconds(currentTime) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }
    
    func forwardVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        let duration = player.currentItem?.duration
        var newTime = CMTimeGetSeconds(currentTime) + seconds
        if newTime >= CMTimeGetSeconds(duration!) {
            newTime = CMTimeGetSeconds(duration!)
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }
    
    
    func setUpVideoPlayerViewController(avPlayerItem: AVPlayerItem) {
        
        
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        // let avPlayer = AVPlayer(url: self.videoURL!)
        let avPlayerViewController = AVPlayerViewController()
        player = avPlayer
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player.currentTime())
            }
        }
        
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.player.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                
                if let isPlaybackLikelyToKeepUp = self?.player.currentItem?.isPlaybackLikelyToKeepUp {
                    //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
                    self?.activityIndicator.isHidden = isPlaybackLikelyToKeepUp
                    self?.activityIndicator.startAnimating()
                    self?.imgViewPreview.isHidden = isPlaybackLikelyToKeepUp
                    
                }
            }
        }
        
        let totalDuration : CMTime = player.currentItem!.asset.duration
        let totalSeconds : Float64 = CMTimeGetSeconds(totalDuration)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        avPlayerViewController.player = avPlayer
        self.addChild(avPlayerViewController)
        
        avPlayerViewController.view.frame = self.outerView.bounds
        
        if videoSize.width == 720 || videoSize.height == 1920{
            avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }else {
            avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
            
        }
        for view in videPlayerView.subviews {
            view.removeFromSuperview()
        }
        avPlayerViewController.showsPlaybackControls = false
        videPlayerView.addSubview(avPlayerViewController.view)
        avPlayerViewController.didMove(toParent: self)
        
    }
    
    //MARK:- Target Method
    @objc func multipleTapForward(_ sender: UIButton, event: UIEvent) {
        outerView.isHidden = false
        
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            if(!videoFinshed){
                self.forwardVideo(by: 5.0)
            }
            if(player.timeControlStatus == .playing){
                player.play()
            }else{
                player.pause()
            }
            
        }
    }
    
    @objc func multipleTapBackward(_ sender: UIButton, event: UIEvent) {
        outerView.isHidden = false
        
        if(videoFinshed){
            videoFinshed = false
        }
        self.rewindVideo(by: 5.0)
        backButtonTapped = true
        if(player.timeControlStatus == .playing){
            player.play()
            backButtonTapped = false
        }else{
            player.pause()
        }
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        player.pause()
        videoFinshed = true
        
    }
    
    //MARK:- UIButton Action Method
    @IBAction func centerPlayButtonAction(_ sender: UIButton) {
        outerView.isHidden = false
        imgViewPreview.isHidden = true
        if(player.timeControlStatus == .playing){
            player.pause()
        }else{
            player.play()
        }
        
        
    }
    @IBAction func playPauseButtonAction(_ sender: UIButton) {
        outerView.isHidden = false
        self.centerPlayButton.isHidden = true
        if(videoFinshed && !backButtonTapped){
            videoFinshed = false
            player.play()
        }
        if player.timeControlStatus == .playing  {
            player.pause()
        }else {
            backButtonTapped = false
            if(player.currentItem == nil){
                setUpVideoPlayerViewController(avPlayerItem: self.playerItem)
            }else{
                player.play()
            }
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        outerView.isHidden = false
        
        if(!videoFinshed){
            self.forwardVideo(by: 5.0)
        }
        if(player.timeControlStatus == .playing){
            player.play()
        }else{
            player.pause()
        }
    }
    @IBAction func backwardButtonAction(_ sender: UIButton) {
        outerView.isHidden = false
        
        if(videoFinshed){
            videoFinshed = false
        }
        self.rewindVideo(by: 5.0)
        backButtonTapped = true
        if(player.timeControlStatus == .playing){
            player.play()
            backButtonTapped = false
        }else{
            player.pause()
        }
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if isPhotoPreview {
        }
        else {
            saveVideo(savetoGallery: 0)
        }
    }
    
    func saveVideo(savetoGallery:Int){
        //guard let videoData = NSData(contentsOf: videoURL!)else { return }
        
        /*\compressVideo(inputURL: videoURL!, outputURL: compressedURL) { (exportSession) in
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
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }*/
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
   
    @IBAction func btnNextAction(_ sender: Any) {
        
        ProgressHud.showActivityLoaderWithTxt(text: "Uploading...")

        if let videoId = self.videoID , selectedIndex == 0 {
            
            if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
                vc.challengeId = self.challengeId
                vc.homeObj = self.homeObj
                vc.videoID = videoId
                vc.thumbnail = self.imageArray[self.selectedIndex]
                vc.isFromProfile = true
                vc.videoObj = self.videoObj
                vc.videoType = self.videoType
                vc.videoURL = self.videoURL
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else {
            if self.avVideoComposition != nil {
                video?.exportFilterVideo(videoComposition: avVideoComposition , completion: { [weak self] (url) in
    
                    var data: Data!
                    do {
                        data = try Data(contentsOf: url! as URL, options: .mappedIfSafe)
                        Logs.show(message: "pickedVideo actual size of file in MB: \(self?.sizeOfFile(data: data))")
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                        let date = Date()
                        let documentsPath = NSTemporaryDirectory()
                        let outputPath = "\(documentsPath)/\(formatter.string(from: date)).mp4"
                        let newOutputUrl = URL(fileURLWithPath: outputPath)
                        
                        self?.convertVideoToLowQuailtyWithInputURL(inputURL: url! as URL, outputURL: newOutputUrl) { val, url in
                            let newUrl = URL(string: url)
                            do {
                                let data = try Data(contentsOf: newUrl!, options: .mappedIfSafe)
                                //self.saveFile(tag: "converted", data: data)
                                Logs.show(message: "pickedVideo converted size of file in MB: \(self?.sizeOfFile(data: data))")
                                
                                if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
                                    vc.videoURL = newUrl
                                    vc.thumbnailImage = self!.thumbnailImage
                                    vc.isForChallange = self!.isForChallange
                                    vc.challangeType = self!.challangeType
                                    //vc.params = params
                                    
                                        DispatchQueue.main.async {
                                            ProgressHud.hideActivityLoader()
                                            self?.navigationController?.pushViewController(vc, animated: true)

                                        }
                                    
                                }
                                
                            } catch let error {
                                print("*** Error : \(error.localizedDescription)")
                                ProgressHud.hideActivityLoader()
                                AppFunctions.showSnackBar(str: "\(error.localizedDescription)")
                            }
                        }
                        
                    } catch let error {
                        print("*** Error : \(error.localizedDescription)")
                        ProgressHud.hideActivityLoader()
                        AppFunctions.showSnackBar(str: "\(error.localizedDescription)")
                    }
                    Logs.show(message: "LL: Completed")

                    //self.callApiForSaveVideo(data: finalData, url: url! as URL)
                })
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
    /*\func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
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
    }*/
    
}

extension VideoFilterViewController:
    UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDisplayNameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterVideoCollectionViewCell", for: indexPath) as! FilterVideoCollectionViewCell
        cell.filterNameLabel.text = filterDisplayNameList[indexPath.item]
        cell.commonImageView.image = imageArray[indexPath.item]
        if selectedIndex == indexPath.item {
            cell.commonImageView.layer.borderWidth = 1
            cell.commonImageView.layer.borderColor = KAppRedColor.cgColor
        }else {
            cell.commonImageView.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 120, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.playerItem = nil
        self.avVideoComposition = nil
        self.player.replaceCurrentItem(with: nil)
        NotificationCenter.default.removeObserver(self)
        self.imgViewPreview.image = imageArray[indexPath.row]
        selectedIndex = indexPath.row
        applyFilterOnVideo(filterName: filterNameList[indexPath.row], filterIndex: indexPath.row)
        self.collectionView.reloadData()
    }
    
    func applyFilterOnVideo(filterName: String, filterIndex: Int){
        let avPlayerItem = AVPlayerItem(asset: video!)
        //  if(filterIndex != 0){
        print("\(video)")
        avVideoComposition = AVVideoComposition(asset: self.video!, applyingCIFiltersWithHandler: { request in
            let source = request.sourceImage.clampedToExtent()
            let filter = CIFilter(name:filterName)!
            filter.setDefaults()
            if filterName == "CIHueAdjust" {
                filter.setValue(fmodf(90, 360) * Float.pi / 180, forKey: "inputAngle")
            }
            
            if filterName == "CIBoxBlur" {
                filter.setValue(0, forKey: "inputRadius")
            }
            
            if filterName == "CIVibrance" {
                filter.setValue(1, forKey: "inputAmount")
            }
            if filterName == "CISharpenLuminance"{
                filter.setValue(0.7, forKey: "inputSharpness")
            }
            if filterName == "CIGammaAdjust"{
                filter.setValue(1.5, forKey: "inputPower")
            }
            if filterName == "CIHighlightShadowAdjust"{
                filter.setValue(0.5, forKey: "inputHighlightAmount")
                filter.setValue(0.5, forKey: "inputShadowAmount")
            }
            
            if filterName == "CIGaussianBlur"{
                filter.setValue(3, forKey: "inputRadius")
            }
            
            if filterName == "CIColorControls"{
                filter.setValue(2, forKey: "inputSaturation")
            }
            
            if filterName == "CIExposureAdjust"{
                filter.setValue(0.8, forKey: "inputEV")
            }
            
            
            if filterName == "CITemperatureAndTint"{
                // warm
                //                    filter.setValue(CIVector(x: 6500, y: 500), forKey: "inputNeutral")
                //                    filter.setValue(CIVector(x: 1000, y: 630), forKey: "inputTargetNeutral")
                
                //cold
                
                filter.setValue(CIVector(x: 13000, y: 1000), forKey: "inputNeutral")
                filter.setValue(CIVector(x: 1000, y: 500), forKey: "inputTargetNeutral")
            }
            
            
            filter.setValue(source, forKey: kCIInputImageKey)
            let output = filter.outputImage!
            request.finish(with:output, context: nil)
        })
        avPlayerItem.videoComposition = avVideoComposition
        //  }
        self.playerItem = avPlayerItem
        //   self.videoPlayer = AVPlayer(playerItem: avPlayerItem)
        self.player.pause()
        self.player.seek(to: .zero)
        setUpVideoPlayerViewController(avPlayerItem: avPlayerItem)
        self.player.play()
    }
}


extension VideoFilterViewController{
    
    func callApiForSaveVideo(data:NSData, url : URL){
        var params = [String: Any]()
        params["is_save_to_gallery"] = 0
        params["video_id"] = self.videoID
        
        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
        var videoData = self.file ?? AttachmentInfo()
        videoData.apiKey = Constants.kVideo_File
        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
            
            if resposne?.statusCode == 0 {
                AlertController.alert(title: "", message: "\(resposne?.message ?? "")", buttons: ["OK"]) { (alert, index) in
                    self.navigationController?.popViewController(animated: true)
                }
            }else if resposne?.statusCode == 200 {
                if let obj = resposne?.object  {
                    ProgressHud.hideActivityLoader()
                    //   if self.videoType == .gallery {
                    if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
                        vc.challengeId = self.challengeId
                        vc.homeObj = self.homeObj
                        vc.videoID = obj.video_id
                        vc.thumbnail = self.imageArray[self.selectedIndex]
                        // vc.videoObj = self.videoObj
                        vc.isFiltered = true
                        vc.videoType = self.videoType
                        vc.videoURL = url
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    // }
                }
            }else {
                
            }
            
        }
    }
    
    
}


extension VideoFilterViewController {
    
    func writeToFile(urlString: String) {
        guard let videoUrl = URL(string: urlString) else {
            return
        }
        do {
            let videoData = try Data(contentsOf: videoUrl)
            let fm = FileManager.default
            guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Unable to reach the documents folder")
                return
            }
            let localUrl = docUrl.appendingPathComponent("test\(String(describing: Date().toMillis())).mp4")
            try videoData.write(to: localUrl)
        } catch  {
            print("could not save data")
        }
    }
    
    func saveFile(tag: String, data: Data) {
        Logs.show(message: "SAVING FILE")
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = "Squable \(tag) \(String(describing: Date().toMillis())).mp4"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        //guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            Logs.show(message: "fileExists")
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
                Logs.show(message: "Saved remove file error: \(removeError)")
                
            }
            
        }
        
        do {
            try data.write(to: fileURL)
            Logs.show(message: "Saved File: \(fileURL)")
        } catch let error {
            Logs.show(message: "Saved File error: \(error)")
            print("error saving file with error", error)
        }
        
    }
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
            
        }
        
        return nil
    }
    
    
    func convertVideoToLowQuailtyWithInputURL(inputURL: URL, outputURL: URL, completion: @escaping (Bool , _ url: String) -> Void) {
        
        Logs.show(message: "COMPRESSION START")
        DispatchQueue.main.async {
            ProgressHud.showActivityLoaderWithTxt(text: "Uploading...")
        }
        let videoAsset = AVURLAsset(url: inputURL as URL, options: nil)
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let videoSize = videoTrack.naturalSize
        let videoWriterCompressionSettings = [
            AVVideoAverageBitRateKey : Int(400000)
        ]
        
        let videoWriterSettings:[String : AnyObject] = [
            AVVideoCodecKey : AVVideoCodecType.hevcWithAlpha as AnyObject,
            AVVideoCompressionPropertiesKey : videoWriterCompressionSettings as AnyObject,
            AVVideoWidthKey : Int(videoSize.width) as AnyObject,
            AVVideoHeightKey : Int(videoSize.height) as AnyObject
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoWriterSettings)
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriterInput.transform = videoTrack.preferredTransform
        let videoWriter = try! AVAssetWriter(outputURL: outputURL as URL, fileType: AVFileType.mov)
        videoWriter.add(videoWriterInput)
        
        
        
        //setup video reader
        let videoReaderSettings:[String : AnyObject] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) as AnyObject
        ]
        
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        var videoReader: AVAssetReader!
        
        do{
            
            videoReader = try AVAssetReader(asset: videoAsset)
        }
        catch {
            
            print("video reader error: \(error)")
            completion(false, "")
        }
        videoReader.add(videoReaderOutput)
        
        
        //setup audio writer
        //let formatDesc = CMSampleBufferGetFormatDescription()
        //let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil, sourceFormatHint: formatDesc)
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil, sourceFormatHint: (audioTrack.formatDescriptions[0] as! CMFormatDescription))
        //let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        videoWriter.add(audioWriterInput)
        //setup audio reader
        //let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        let audioReader = try! AVAssetReader(asset: videoAsset)
        audioReader.add(audioReaderOutput)
        videoWriter.startWriting()
        
        
        
        //start writing from video reader
        videoReader.startReading()
        videoWriter.startSession(atSourceTime: CMTime.zero)
        let processingQueue = DispatchQueue(label: "processingQueue1")
        videoWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
            while videoWriterInput.isReadyForMoreMediaData {
                let sampleBuffer:CMSampleBuffer? = videoReaderOutput.copyNextSampleBuffer();
                if videoReader.status == .reading && sampleBuffer != nil {
                    videoWriterInput.append(sampleBuffer!)
                }
                else {
                    videoWriterInput.markAsFinished()
                    if videoReader.status == .completed {
                        //start writing from audio reader
                        audioReader.startReading()
                        videoWriter.startSession(atSourceTime: CMTime.zero)
                        let processingQueue = DispatchQueue(label: "processingQueue2")
                        audioWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
                            while audioWriterInput.isReadyForMoreMediaData {
                                let sampleBuffer:CMSampleBuffer? = audioReaderOutput.copyNextSampleBuffer()
                                if audioReader.status == .reading && sampleBuffer != nil {
                                    audioWriterInput.append(sampleBuffer!)
                                }
                                else {
                                    audioWriterInput.markAsFinished()
                                    if audioReader.status == .completed {
                                        videoWriter.finishWriting(completionHandler: {() -> Void in
                                            completion(true, "\(videoWriter.outputURL)")
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
    }
}
