//
//  ChallengeListCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 17/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import ActiveLabel
import AVFoundation



class ChallengeListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!

    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var challengeNameLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!

    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var donateView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shootView: UIView!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var tapBackwardButton: UIButton!
    @IBOutlet weak var tapForwardButton: UIButton!

    @IBOutlet weak var voteView: UIView!
    @IBOutlet weak var sliderView: MPVolumeView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var menuTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTopButtonConstraint: NSLayoutConstraint!

    
    var messageClickCompletion:(()  -> Void)? = nil
    var shareClickCompletion:(()  -> Void)? = nil
    var followClickCompletion:(()  -> Void)? = nil
    var donateClickCompletion:(()  -> Void)? = nil
    var feedClickCompletion:(()  -> Void)? = nil
    var shootClickCompletion:(()  -> Void)? = nil
    var profileClickCompletion:(()  -> Void)? = nil
    var voteClickCompletion:(()  -> Void)? = nil
    var muteClickCompletion:(()  -> Void)? = nil


    var player = AVPlayer()
    var isPlayed = false
    let avPlayerViewController = AVPlayerViewController()
    var viewCompletion:(()  -> Void)? = nil
    var isVideoPlay = true
    var isOpen = false
    var isPlaying = false
    var playerView: VideoPlayerView!

    
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        Logs.show(message: "pressed")
        showHidePopupContents(value: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        avPlayerViewController.view.frame = CGRect(x: videoPlayerView.frame.origin.x, y: 0, width: videoPlayerView.frame.size.width, height:  videoPlayerView.frame.size.height)
//        avPlayerViewController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
//        avPlayerViewController.showsPlaybackControls = false
        
        
        playerView = VideoPlayerView(frame: videoPlayerView.frame)
        videoPlayerView.addSubview(playerView)
        showHidePopupContents(value: true)
        
//        profileImageView.layer.cornerRadius = 20
//        profileImageView.clipsToBounds = true
//        profileImageView.layer.borderWidth = 1.0
//        profileImageView.layer.masksToBounds = true
//        profileImageView.layer.borderColor = KAppDarkGrayColor.cgColor
//       // thumbnailImageView.contentMode = .scaleAspectFill
//        followButton.aroundShadow(.black)
//        var topSafeArea : CGFloat = 0
//        if #available(iOS 11.0, *) {
//            topSafeArea = APPDELEGATE.window?.rootViewController!.view.safeAreaInsets.top ?? 0
//        } else {
//            topSafeArea = APPDELEGATE.window?.rootViewController!.topLayoutGuide.length ?? 0
//        }
//        menuTopButtonConstraint.constant =  topSafeArea == 0.0 ? -20 : 25
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
         //   self.videoPlayerView.isHidden = true
          //  avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
        playerView.cancelAllLoadingRequest()
        showHidePopupContents(value: true)
    //        NotificationCenter.default.removeObserver(self)
        
      //  self.player.pause()
      //  self.player.replaceCurrentItem(with: nil)
//            self.player = AVPlayer()
//            self.avPlayerViewController.player = AVPlayer()
      //  self.videoPlayerView.isHidden = false
        
    }
    
    
    @objc func playerDidFinishPlaying(){
    }
    
    
    func replay(){
        if !isPlaying {
            playerView.replay()
            resumeLayer(layer: playPauseButton.layer)
            //isPlaying = true
            play()
        }
    }
    
    func play() {
        if !isPlaying {
            playerView.play()
            isPlaying = true
            resumeLayer(layer: playPauseButton.layer)

        }
    }
    
    func pause(){
        if isPlaying {
            playerView.pause()
            isPlaying = false
            pauseLayer(layer: playPauseButton.layer)
        }
    }

    
    
    func setPlayer(urlString: String) {
        
        Logs.show(message: "setPlayer Vid URL :::: \(urlString)")
        if let url = URL(string: urlString) {
            playerView.configure(url: url, fileExtension: "mp4")
            thumbnailImageView.isHidden = true
            self.activityIndicator.isHidden = true
        }
        
        /*playPauseButton.isHidden = true
        if let url = URL(string: urlString) {
            //player = AVPlayer(url: url)
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: item)
            player.play()
            
        }
        

        
        sliderView.showsVolumeSlider = false
        sliderView.isHidden = true
        //sliderView.showsVolumeSlider = true
        thumbnailImageView.isHidden = true
        self.avPlayerViewController.player = self.player
        player.play()
        self.activityIndicator.isHidden = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            player.isMuted = true
        }
        
        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect

        var isFirstTime = true
        isVideoPlay = true
        self.avPlayerViewController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.avPlayerViewController.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                
                if (self?.avPlayerViewController.player?.currentItem?.isPlaybackLikelyToKeepUp) != nil {
        
                    self?.playPauseButton.isHidden = false
                    
                    if self?.isVideoPlay ?? true {
                        self?.thumbnailImageView.isHidden = true
                        self?.isVideoPlay = false
                    }
                    if let currentTime = self?.avPlayerViewController.player?.currentItem?.currentTime().seconds {
                        
                        
                        
                        if currentTime > 2 {
                            if isFirstTime {
                                self?.viewCompletion?()
                                isFirstTime = false
                            }
                        }
                    }
                }
            }
        }*/
    }
    
    func setPlayer(object: RewardsModel) {
        playPauseButton.isHidden = true
        if let url = URL(string: object.aws_video_path ?? "") {
            object.player = AVPlayer(url: url)
            //object.player?.pause()
        }
        sliderView.showsVolumeSlider = false
        sliderView.isHidden = true
        //sliderView.showsVolumeSlider = true
        thumbnailImageView.isHidden = false
        self.player = object.player ?? AVPlayer()
        self.avPlayerViewController.player = self.player
        self.activityIndicator.isHidden = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            player.isMuted = true
        }
        //   print("status",object.player)
        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
        //  avPlayerViewController.player?.currentItem?.preferredForwardBufferDuration = 0
        //  avPlayerViewController.player?.automaticallyWaitsToMinimizeStalling = false
        // avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //  self.avPlayerViewController.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        var isFirstTime = true
        isVideoPlay = true
        self.avPlayerViewController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.avPlayerViewController.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                
                if let isPlaybackLikelyToKeepUp = self?.avPlayerViewController.player?.currentItem?.isPlaybackLikelyToKeepUp {
                    //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
                    // print("isPlaybackLikelyToKeepUp::--\(isPlaybackLikelyToKeepUp)")
                    self?.playPauseButton.isHidden = false

                    if self?.isVideoPlay ?? true {
                        self?.thumbnailImageView.isHidden = true
                        //  self?.activityIndicator.isHidden = isPlaybackLikelyToKeepUp
                        //  self?.activityIndicator.startAnimating()
                        self?.isVideoPlay = false
                    }
                    
                    
                    if let currentTime = self?.avPlayerViewController.player?.currentItem?.currentTime().seconds {
                        
                        
                        
                        if currentTime > 2 {
                            if isFirstTime {
                                self?.viewCompletion?()
                                isFirstTime = false
                            }
                        }
                        //                        if currentTime < 0.3 {
                        //                            self?.thumbnailImageView.isHidden = false
                        //                            self?.activityIndicator.isHidden = false
                        //                        }
                        //                        if currentTime > 1.0 {
                        //                            self?.thumbnailImageView.isHidden = true
                        //                        }
                    }
                }
            }
        }
        
        
        //self.avPlayerViewController.player?.play()
        
        //        if(object.isPlayed){
        //            self.avPlayerViewController.player?.pause()
        //        }else{
        //            self.avPlayerViewController.player?.play()
        //        }
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        if keyPath == "playbackBufferEmpty" {
//
//            print("Show loader")
//            self.activityIndicator.isHidden = false
//            self.activityIndicator.startAnimating()
//
//        } else if keyPath == "playbackLikelyToKeepUp" {
//
//            print("Hide loader")
//            self.activityIndicator.isHidden = true
//            self.activityIndicator.stopAnimating()
//
//        } else if keyPath == "playbackBufferFull" {
//            print("Hide loader")
//            self.activityIndicator.isHidden = true
//            self.activityIndicator.stopAnimating()
//        }
//    }
//
    //video player methods
    func setUpVideoPlayerViewController(cell:ChallengeListCollectionViewCell) {
    }

    
    
    func showHidePopupContents(value: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.bottomStackView.subviews.forEach { btn in
                btn.isHidden = value
            }
            self.rightStackView.subviews.forEach { btn in
                btn.isHidden = value
            }
        }
        if value {
            return
        }
        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    @objc func fireTimer() {
        Logs.show(message: "fire")
        showHidePopupContents(value: true)
    }
    
    @IBAction func messageButtonAction(_ sender: UIButton){
        self.messageClickCompletion?()
    }
    @IBAction func feedButtonAction(_ sender: UIButton){
        self.feedClickCompletion?()
    }
    @IBAction func shootButtonAction(_ sender: UIButton){
        self.shootClickCompletion?()
    }
    @IBAction func shareButtonAction(_ sender: UIButton){
        self.shareClickCompletion?()
    }
    @IBAction func donateButtonAction(_ sender: UIButton){
        self.donateClickCompletion?()
    }
    @IBAction func followButtonAction(_ sender: UIButton){
        self.followClickCompletion?()
    }
    @IBAction func profileButtonAction(_ sender: UIButton){
        self.profileClickCompletion?()
    }
    
    @IBAction func voteButtonAction(_ sender: UIButton){
           self.voteClickCompletion?()
       }
    @IBAction func muteButtonAction(_ sender: UIButton){
        self.muteClickCompletion?()
    }
    
    
    
    
    @IBAction func playPauseActionBtn(_ sender: Any) {
       
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if isPlaying {
            playPauseButton.isHidden = false
            pause()
        } else {
            playPauseButton.isHidden = true
            replay()
        }
    }
    
    
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
}



