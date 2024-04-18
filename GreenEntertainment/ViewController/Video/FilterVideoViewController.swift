//
//  FilterVideoViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 11/09/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AVKit
import CoreImage
//import BBMetalImage

enum VideoFrom {
    case gallery
    case library
    case shoot
}


class FilterVideoViewController: UIViewController {
    
   
    @IBOutlet weak var videPlayerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgViewPreview: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var doubleTapForward: UIButton!
    @IBOutlet weak var doubleTapBackward: UIButton!
   
    @IBOutlet weak var centerPlayButton: UIButton!
 
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
//    var videoSize = CGSize.zero
//    var tempVideoSize = CGSize.zero
//
//    var homeObj = HomeModel()
//    var thumbnailImage = UIImage()
//    //    var delegate: EditProfileViewController!
//    var player = AVPlayer()
//    private var playerLayer: AVPlayerLayer!
//
//    var videoFinshed = false
//    var backButtonTapped = false
//    var videoType: VideoType = .myPost
//    var isPhotoPreview = false
//    var challengeName = ""
//    var videoURL: URL?
//    var file: AttachmentInfo?
//    var videoObj = RewardsModel()
//    var aVAudioPlayer: AVAudioPlayer?
//    var tempUrl: URL?
//    var context: CIContext!
//    var currentFilter: CIFilter!
//    var isFromLibrary = false
//    var selectedIndex = 0
//
//    var videoID : Int?
//    var challengeId : String?
//    var data : NSData?
//    var url = ""
//    var isPost = false
//    var isFilterFirst = false
//
//    private var videoSource: BBMetalVideoSource!
//    private var videoWriter: BBMetalVideoWriter!
//
//    public typealias CompletionBlock = (_ success: Bool, _ data: Data, _ error: Error?) -> Void
//
//    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
//
//
//
//     let filterNameList = [
//
//           "CIWhitePointAdjust",
//           "CIHighlightShadowAdjust",
//           "CIVibrance",
//           "CISaturationBlendMode",
//           "CISharpenLuminance",
//           "CIHueAdjust",
//           "CIGammaAdjust"
//       ]
//
//        let filterDisplayNameList = ["Default",
//           "White Balance",
//           "Highlight Shadow",
//           "Vibrance",
//           "Saturation",
//           "Luminance",
//           "Hue",
//           "Gamma",
//           "Bilateral",
//           "Sharpen"
//       ]
//
//    var imageArray = [UIImage]()
//
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
//        tempUrl = videoURL
//        let size =  self.resolutionSizeForLocalVideo(url: videoURL as! NSURL)
//        videoSize = size ?? .zero
//        //imgViewPreview.transform = imgViewPreview.transform.rotated(by: .pi)
//
//        doubleTapForward.addTarget(self, action: #selector(multipleTapForward(_:event:)), for: UIControl.Event.touchDownRepeat)
//        doubleTapBackward.addTarget(self, action: #selector(multipleTapBackward(_:event:)), for: UIControl.Event.touchDownRepeat)
//
////        if !isPhotoPreview {
////            outerView.isHidden = true
////            setUpVideoPlayerViewController()
////            if(videoObj.video_thumbnail != nil){
////                if let url = URL(string: videoObj.video_thumbnail ?? "") {
////                    self.imgViewPreview.kf.setImage(with: url, placeholder: UIImage(named: ""))
////                }
////            }else{
////                let url = videoURL
////                let thumbnailImage = getThumbnailImage(forUrl: url!)
////                imgViewPreview.image = thumbnailImage
////            }
////            self.centerPlayButton.isHidden = false
////        }
////        else {
////        }
//        setVideoView()
//        customiseView()
//        applyFilteredImage()
//       // applyFilterOnImage()
//        // Do any additional setup after loading the view.
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        player.pause()
//        self.player.replaceCurrentItem(with: nil)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//        player.pause()
//        self.player.replaceCurrentItem(with: nil)
//    }
//
//    //MARK:- Helper Method
//    func customiseView(){
//
//    }
//
//    func initialMethod(){
//
//    }
//
//    func applyFilteredImage(){
//        for item in self.filterDisplayNameList {
//            if item == "Default"{
//                imageArray.append(self.thumbnailImage.fixOrientation!)
//            }else if item == "White Balance"{
//                imageArray.append(BBMetalWhiteBalanceFilter(temperature: 7000).filteredImage(with: thumbnailImage)!)
//            }else if item == "Highlight Shadow" {
//                imageArray.append(BBMetalHighlightShadowFilter(shadows: 0.5, highlights: 0.5).filteredImage(with: thumbnailImage)!)
//            }else if item == "Vibrance" {
//                imageArray.append(BBMetalVibranceFilter(vibrance: 1).filteredImage(with: thumbnailImage)!)
//            }else if item == "Saturation"{
//                imageArray.append(BBMetalSaturationFilter(saturation: 2).filteredImage(with: thumbnailImage)!)
//            }else if item == "Luminance" {
//                imageArray.append(BBMetalLuminanceFilter().filteredImage(with: thumbnailImage)!)
//            }else if item == "Hue" {
//                imageArray.append(BBMetalHueFilter(hue: 90).filteredImage(with: thumbnailImage)!)
//            }else if item == "Gamma" {
//                imageArray.append(BBMetalGammaFilter(gamma: 1.5).filteredImage(with: thumbnailImage)!)
//            }else if item == "Bilateral" {
//                imageArray.append(BBMetalBilateralBlurFilter().filteredImage(with: thumbnailImage)!)
//            }else {
//                imageArray.append(BBMetalSharpenFilter(sharpeness: 0.5).filteredImage(with: thumbnailImage)!)
//            }
//        }
//
//        self.collectionView.reloadData()
//        self.imgViewPreview.image = imageArray[0]
//    }
//
//    func applyFilterOnImage(){
//
//        for item in self.filterNameList {
//
//            context = CIContext()
//            currentFilter = CIFilter(name: item)
//
//            let beginImage = CIImage(image: thumbnailImage)
//            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//
//            let inputKeys = currentFilter.inputKeys
//
//            print("inputKeys::---\(inputKeys)")
//
////            if inputKeys.contains(kCIInputColorKey) {
////                print("item::--- \(item)")
////                currentFilter.setValue(RGBA(240, g: 240, b: 240, a: 0.5), forKey: kCIInputColorKey)
////            }
//
//            if inputKeys.contains("inputAmount") {
//                print("item::--- \(item)")
//                currentFilter.setValue(0.8, forKey: "inputAmount")
//            }
//
//
//
//           if inputKeys.contains(kCIInputShadingImageKey) {
//               print("item6::--- \(item)")
//               currentFilter.setValue(0.5, forKey: kCIInputShadingImageKey)
//           }
//
//            if inputKeys.contains(kCIInputRadiusKey) {
//                 print("item1::--- \(item)")
//                currentFilter.setValue(0.8 * 200, forKey: kCIInputRadiusKey)
//            }
//            if inputKeys.contains(kCIInputScaleKey) {
//                 print("item2::--- \(item)")
//                currentFilter.setValue(0.5 * 10, forKey: kCIInputScaleKey)
//            }
//
////            if inputKeys.contains(kCIInputBackgroundImageKey) {
////                 print("item2::--- \(item)")
////                currentFilter.setValue(0.5 * 10, forKey: kCIInputBackgroundImageKey)
////            }
//
//
//            if inputKeys.contains(kCIInputCenterKey) {
//                 print("item3::--- \(item)")
//                currentFilter.setValue(CIVector(x: thumbnailImage.size.width / 2, y: thumbnailImage.size.height / 2), forKey: kCIInputCenterKey)
//            }
//
//            if inputKeys.contains(kCIInputAngleKey) {
//                 print("item4::--- \(item)")
//                currentFilter.setValue(180, forKey: kCIInputAngleKey)
//            }
//
//
//
//            guard let image = currentFilter.outputImage else { return }
//
//
//
//
//
//           // currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
//
//            if let cgimg = context.createCGImage(image, from: image.extent) {
//                let processedImage = UIImage(cgImage: cgimg)
//                self.imageArray.append(processedImage)
//            }
//        }
//
//        self.imageArray.insert(thumbnailImage, at: 0)
//        self.collectionView.reloadData()
//        self.imgViewPreview.image = imageArray[0]
//    }
//
//    func getThumbnailImage(forUrl url: URL) -> UIImage? {
//        let asset: AVAsset = AVAsset(url: url)
//        let imageGenerator = AVAssetImageGenerator(asset: asset)
//
//        do {
//            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
//            return UIImage(cgImage: thumbnailImage)
//        } catch let error {
//            print(error)
//        }
//
//        return nil
//    }
//
//    func rewindVideo(by seconds: Float64) {
//        let currentTime = player.currentTime()
//        var newTime = CMTimeGetSeconds(currentTime) - seconds
//        if newTime <= 0 {
//            newTime = 0
//        }
//        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
//    }
//
//    func forwardVideo(by seconds: Float64) {
//        let currentTime = player.currentTime()
//        let duration = player.currentItem?.duration
//        var newTime = CMTimeGetSeconds(currentTime) + seconds
//        if newTime >= CMTimeGetSeconds(duration!) {
//            newTime = CMTimeGetSeconds(duration!)
//        }
//        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
//    }
//
//    func resolutionSizeForLocalVideo(url:NSURL) -> CGSize? {
////        guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
////        let size = track.naturalSize.applying(track.preferredTransform)
////        print("Width:---\(fabs(size.width)) and Height::---\( fabs(size.height))")
////        return CGSize(width: fabs(size.width), height: fabs(size.height))
//
//
//        guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
//        let tempsize = track.naturalSize.applying(track.preferredTransform)
//        print(" temp Width:---\(abs(tempsize.width)) and temp Height::---\( abs(tempsize.height))")
//        tempVideoSize = CGSize(width: abs(tempsize.width), height: abs(tempsize.height))
//
//        let size = track.naturalSize//.//applying(track.preferredTransform)
//        print("Width:---\(abs(size.width)) and Height::---\( abs(size.height))")
//        return CGSize(width: abs(size.width), height: abs(size.height))
//    }
//
//    func setUpVideoPlayerViewController() {
//     //   let videoURl = self.videoURL
//        //  if let videoURL = videoObj.video_path{
//
//        //   let url = URL(string:videoURL)!
//        let avPlayer = AVPlayer(url: self.videoURL!)
//        let avPlayerViewController = AVPlayerViewController()
//        player = avPlayer
////       let size =  self.resolutionSizeForLocalVideo(url: self.videoURL as! NSURL)
////       videoSize = size ?? CGSize.zero
//        //new
//        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
//            if self.player.currentItem?.status == .readyToPlay {
//                let time : Float64 = CMTimeGetSeconds(self.player.currentTime())
//            }
//        }
//
//
//
//
//
//        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
//            [weak self] time in
//
//            if self?.player.currentItem?.status == AVPlayerItem.Status.readyToPlay {
//
//                if let isPlaybackLikelyToKeepUp = self?.player.currentItem?.isPlaybackLikelyToKeepUp {
//                    //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
//                    //  print("isPlaybackLikelyToKeepUp::--\(isPlaybackLikelyToKeepUp)")
//                    self?.activityIndicator.isHidden = isPlaybackLikelyToKeepUp
//                    self?.activityIndicator.startAnimating()
//                    self?.imgViewPreview.isHidden = isPlaybackLikelyToKeepUp
//
//                }
//            }
//        }
//
//        let totalDuration : CMTime = player.currentItem!.asset.duration
//        let totalSeconds : Float64 = CMTimeGetSeconds(totalDuration)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
//
//
//        avPlayerViewController.player = avPlayer
//        self.addChild(avPlayerViewController)
//        avPlayerViewController.view.frame = CGRect(x: videPlayerView.frame.origin.x, y: 0, width: videPlayerView.frame.size.width, height: videPlayerView.frame.size.height)
//        //  avPlayerViewController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
//
//        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
//
//        avPlayerViewController.showsPlaybackControls = false
//        videPlayerView.addSubview(avPlayerViewController.view)
//        avPlayerViewController.didMove(toParent: self)
//
//        if ((tempUrl?.absoluteString ?? "") != (videoURL?.absoluteString ?? "")) && tempVideoSize.width == videoSize.height {
//            self.outerView.transform =   outerView.transform.rotated(by: .pi/2)
//        }else {
//            self.outerView.transform =   .identity
//        }
//
//
//
////        if size?.height == 720.0 {
////            self.outerView.transform =   outerView.transform.rotated(by: .pi/2)
////        }else {
////            self.outerView.transform =   .identity
////        }
//    }
//
//    func stringFromTimeInterval(interval: TimeInterval) -> String {
//        let interval = Int(interval)
//        let seconds = interval % 60
//        let minutes = (interval / 60) % 60
//        let hours = (interval / 3600)
//        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//    }
//
//    func playVoteSound(){
//
//        let path = Bundle.main.path(forResource: "Sword_swipes.mp3", ofType:nil)!
//        let url = URL(fileURLWithPath: path)
//        do {
//            aVAudioPlayer = try AVAudioPlayer(contentsOf: url)
//            aVAudioPlayer?.play()
//        } catch {
//            // couldn't load file :(
//        }
//    }
//
//
//    //MARK:- Target Method
//    @objc func multipleTapForward(_ sender: UIButton, event: UIEvent) {
//        //        setUpVideoPlayerViewController()
//        outerView.isHidden = false
//
//        let touch: UITouch = event.allTouches!.first!
//        if (touch.tapCount == 2) {
//            if(!videoFinshed){
//                self.forwardVideo(by: 5.0)
//            }
//            if(player.timeControlStatus == .playing){
//                player.play()
//                //   playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
//            }else{
//                player.pause()
//            }
//
//        }
//    }
//
//    @objc func multipleTapBackward(_ sender: UIButton, event: UIEvent) {
//        //  setUpVideoPlayerViewController()
//        outerView.isHidden = false
//
//
//        if(videoFinshed){
//            videoFinshed = false
//        }
//        self.rewindVideo(by: 5.0)
//        backButtonTapped = true
//        if(player.timeControlStatus == .playing){
//            player.play()
//            backButtonTapped = false
//        }else{
//            player.pause()
//        }
//
//    }
//
//    @objc func playerDidFinishPlaying(note: NSNotification){
//        player.pause()
//        //  playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
//        print("Video Finished")
//        videoFinshed = true
//
//    }
//
//    //MARK:- UIButton Action Method
//    @IBAction func centerPlayButtonAction(_ sender: UIButton) {
//        outerView.isHidden = false
//        imgViewPreview.isHidden = true
//
//        //        if videoType == .myPost || videoType == .myTrophy{
//        if(player.timeControlStatus == .playing){
//            player.pause()
//            //   self.centerPlayButton.setImage(UIImage(named:"icn_play"), for: .normal)
//        }else{
//            player.play()
//            //   self.centerPlayButton.setImage(UIImage(named:"icn_pause"), for: .normal)
//        }
//
//
//    }
//    @IBAction func playPauseButtonAction(_ sender: UIButton) {
//        outerView.isHidden = false
//        self.centerPlayButton.isHidden = true
//        if(videoFinshed && !backButtonTapped){
//            videoFinshed = false
//            player.play()
//            // playPauseButton.setImage(UIImage.init(named: "icn_pause"), for: .normal)
//        }
//        if player.timeControlStatus == .playing  {
//            player.pause()
//            //  playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
//        }else {
//            backButtonTapped = false
//            if(player.currentItem == nil){
//                setUpVideoPlayerViewController()
//            }else{
//                player.play()
//            }
//            //  playPauseButton.setImage(UIImage.init(named: "icn_pause"), for: .normal)
//        }
//    }
//
//    @IBAction func forwardButtonAction(_ sender: Any) {
//        outerView.isHidden = false
//
//        if(!videoFinshed){
//            self.forwardVideo(by: 5.0)
//        }
//        if(player.timeControlStatus == .playing){
//            player.play()
//        }else{
//            player.pause()
//        }
//    }
//    @IBAction func backwardButtonAction(_ sender: UIButton) {
//        outerView.isHidden = false
//
//        if(videoFinshed){
//            videoFinshed = false
//        }
//        self.rewindVideo(by: 5.0)
//        backButtonTapped = true
//        if(player.timeControlStatus == .playing){
//            player.play()
//            backButtonTapped = false
//        }else{
//            player.pause()
//        }
//    }
//
//    @IBAction func btnDoneAction(_ sender: Any) {
//        if isPhotoPreview {
//        }
//        else {
//          saveVideo(savetoGallery: 0)
//        }
//    }
//
//    func saveVideo(savetoGallery:Int){
//        guard let videoData = NSData(contentsOf: videoURL!)else { return }
//
//        compressVideo(inputURL: videoURL!, outputURL: compressedURL) { (exportSession) in
//            guard let session = exportSession else {
//                return
//            }
//
//            switch session.status {
//            case .unknown:
//                break
//            case .waiting:
//                break
//            case .exporting:
//                break
//            case .completed:
//                guard let compressedData = NSData(contentsOf: self.compressedURL)else { return }
//                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
//               // self.callApiForSaveVideo(data:compressedData, isSaveToGallery: savetoGallery)
//                //  self.uploadVideoInMultipartForm(dict)
//
//            case .failed:
//                break
//            case .cancelled:
//                break
//            }
//        }
//    }
//
//    @IBAction func btnBackAction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//
//    }
//
//    @IBAction func btnNextAction(_ sender: Any) {
//        if selectedIndex == 0 {
//            if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
//                vc.challengeId = self.challengeId
//                vc.homeObj = self.homeObj
//                vc.videoID = self.videoID
//            // vc.videoObj = self.videoObj
//              //  vc.videoType = self.videoType
//                vc.videoURL = self.videoURL
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }else {
//            guard let compressedData = NSData(contentsOf: self.videoURL! as URL)else { return }
//            self.callApiForSaveVideo(data: compressedData, url: self.videoURL! as URL)
//
//        }
//
//
//
//
//
//    }
//
//
//
//    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
//        let urlAsset = AVURLAsset(url: inputURL, options: nil)
//        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
//            handler(nil)
//
//            return
//        }
//
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType =  AVFileType.mp4 //AVFileType.mov
//        exportSession.shouldOptimizeForNetworkUse = true
//        exportSession.exportAsynchronously { () -> Void in
//            handler(exportSession)
//        }
//    }
//
//}
//
//extension FilterVideoViewController:
//UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return filterDisplayNameList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterVideoCollectionViewCell", for: indexPath) as! FilterVideoCollectionViewCell
//        cell.filterNameLabel.text = filterDisplayNameList[indexPath.item]
//        cell.commonImageView.image = imageArray[indexPath.item]
//        if selectedIndex == indexPath.item {
//            cell.commonImageView.layer.borderWidth = 1
//            cell.commonImageView.layer.borderColor = KAppRedColor.cgColor
//        }else {
//            cell.commonImageView.layer.borderWidth = 0
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: 120, height: 150)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.imgViewPreview.image = imageArray[indexPath.row]
//        selectedIndex = indexPath.row
//        applyFilterOnVideo(type: filterDisplayNameList[indexPath.row])
//        self.collectionView.reloadData()
//    }
//
//    func applyProcessing() {
//        guard let image = currentFilter.outputImage else { return }
//        currentFilter.setValue(5, forKey: kCIInputIntensityKey)
//
//        if let cgimg = context.createCGImage(image, from: image.extent) {
//            let processedImage = UIImage(cgImage: cgimg)
//            thumbnailImage = processedImage
//        }
//    }
//
//    func applyFilterOnVideo(type: String){
//        ProgressHud.showActivityLoader()
//        switch type {
//        case "Default":
//            self.videoURL = self.tempUrl
//            setVideoView()
//        case "White Balance":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//
////            if isFromLibrary {
////                videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.height), height: Int(videoSize.width)))
////            }else{
////                videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
////            }
//
//
//            videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            print("url::-\(tempUrl?.absoluteString)")
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalWhiteBalanceFilter()
//            filter.temperature = 7000
//
//
//
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//          //  videoSource.add(consumer: filterr)
//
//
//            videoWriter.start { (type) in
//
//            }
//
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                             self.setVideoView()
////                        if self.isFromLibrary {
////                            self.rotateFilter()
////                        }else {
////                            self.setVideoView()
////                        }
//                    }
//                }
//            }
//
//        case "Luminance":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//           videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalLuminanceFilter()
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//        case "Highlight Shadow":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//            videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalHighlightShadowFilter()
//            filter.highlights = 0.5
//            filter.shadows = 0.5
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//        case "Vibrance":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//           // videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: 1080, height: 1920))
//
//            videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalVibranceFilter()  // BBMetalColorInversionFilter()
//            filter.vibrance = 1
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//
//        case "Saturation":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//           videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalSaturationFilter()  // BBMetalColorInversionFilter()
//            filter.saturation = 2
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//
//        case "Hue":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//             videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalHueFilter()  // BBMetalColorInversionFilter()
//            filter.hue = 90
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//        case "Gamma":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//             videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalGammaFilter()
//            filter.gamma = 1.5
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//        case "Bilateral":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//             videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalBilateralBlurFilter()  // BBMetalColorInversionFilter()
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//
//
//        case "Sharpen":
//            let filePath = NSTemporaryDirectory() + "test.mp4"
//            let outputUrl = URL(fileURLWithPath: filePath)
//            try? FileManager.default.removeItem(at: outputUrl)
//             videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//            videoSource = BBMetalVideoSource(url: tempUrl!)
//            videoSource.audioConsumer = videoWriter
//
//            let filter = BBMetalSharpenFilter()
//            filter.sharpeness = 0.5
//            videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//            videoWriter.start { (type) in
//
//            }
//            videoSource.start(progress: { (frameTime) in
//                print("frameTime:::--\(frameTime)")
//            }) { [weak self] (_) in
//                guard let self = self else { return }
//                self.videoWriter.finish {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        self.videoURL = outputUrl
//                        self.setVideoView()
//                    }
//                }
//            }
//        default:
//            break
//        }
//    }
//
//    func rotateFilter(){
//        let filePath = NSTemporaryDirectory() + "test.mp4"
//        let outputUrl = URL(fileURLWithPath: filePath)
//        try? FileManager.default.removeItem(at: outputUrl)
//         videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(videoSize.width), height: Int(videoSize.height)))
//
//        videoSource = BBMetalVideoSource(url: videoURL!)
//        videoSource.audioConsumer = videoWriter
//
//        let filter = BBMetalRotateFilter(angle: 90, fitSize: true)
//        videoSource.add(consumer: filter).add(consumer: videoWriter)
//
//        videoWriter.start { (type) in
//
//        }
//
//        videoSource.start(progress: { (frameTime) in
//            print("frameTime:::--\(frameTime)")
//        }) { [weak self] (_) in
//            guard let self = self else { return }
//            self.videoWriter.finish {
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else { return }
//                    self.videoURL = outputUrl
//                    self.setVideoView()
//                }
//            }
//        }
//    }
//
//
//    func setVideoView(){
//       // self.outerView.transform =   .identity
//        self.player.pause()
//        ProgressHud.hideActivityLoader()
//        self.player.seek(to: .zero)
//        self.setUpVideoPlayerViewController()
//        self.player.play()
//        self.videoWriter = nil
//        self.videoSource = nil
//    }
//
//}
//
//
//extension FilterVideoViewController{
//
////    func callApiForSaveVideo(data:NSData,isSaveToGallery:Int){
////        var params = [String: Any]()
////        params["is_save_to_gallery"] = isSaveToGallery
////        //   var imageData = self.file ?? AttachmentInfo()
////        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
////        var videoData = self.file ?? AttachmentInfo()
////        videoData.apiKey = Constants.kVideo_File
////        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
////
////            if(isSaveToGallery == 0){
////                if let obj = resposne?.object  {
////                    if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
////                        vc.videoID = obj.video_id
////                        vc.videoURL = self.videoURL
////                        vc.file = self.file
////                        vc.data = data
////                        vc.homeObj = self.homeObj
////                        self.navigationController?.pushViewController(vc, animated: true)
////                    }
////                }
////            }else{
////                if let vc = UIStoryboard.challenge.get(GalleryViewController.self) {
////                    self.navigationController?.pushViewController(vc, animated: true)
////                }
////
////            }
////        }
////    }
//
//
//    func callApiForSaveVideo(data:NSData, url : URL){
//        var params = [String: Any]()
//        params["is_save_to_gallery"] = 0
//        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
//        var videoData = self.file ?? AttachmentInfo()
//        videoData.apiKey = Constants.kVideo_File
//        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
//            if let obj = resposne?.object  {
//             //   if self.videoType == .gallery {
//                    if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
//                        vc.challengeId = self.challengeId
//                        vc.homeObj = self.homeObj
//                        vc.videoID = obj.video_id
//
//                    // vc.videoObj = self.videoObj
//                      //  vc.videoType = self.videoType
//                        vc.videoURL = self.videoURL
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//               // }
//            }
//        }
//
//    }
//
//
//}
//
