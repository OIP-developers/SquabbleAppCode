//
//  PostsCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 11/07/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import ActiveLabel

class PostsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var leftVoteLabel: UILabel!
    @IBOutlet weak var leftViewsLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var postBottomView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var editStackView: UIStackView!
    @IBOutlet weak var voteView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var unvoteLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var voteViewHeight: NSLayoutConstraint!

    @IBOutlet weak var tapBackwardButton: UIButton!
    @IBOutlet weak var tapForwardButton: UIButton!

    @IBOutlet weak var editStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var voteBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var voteLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var voteButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var sliderView: MPVolumeView!
    @IBOutlet weak var voteBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var menuTopButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!


    
    var playClickCompletion:(()  -> Void)? = nil
    var forwardClickCompletion:(()  -> Void)? = nil
    var backwardClickCompletion:(()  -> Void)? = nil
    var shareClickCompletion:(()  -> Void)? = nil
    var editClickCompletion:(()  -> Void)? = nil
    var deleteClickCompletion:(()  -> Void)? = nil
    var voteClickCompletion:(()  -> Void)? = nil
    var muteClickCompletion:(()  -> Void)? = nil
    
    var player = AVPlayer()
       var isPlayed = false
       let avPlayerViewController = AVPlayerViewController()
    var isFirstTime = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avPlayerViewController.view.frame = CGRect(x: videoPlayerView.frame.origin.x, y: 0, width: videoPlayerView.frame.size.width, height:  videoPlayerView.frame.size.height)
        avPlayerViewController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
        avPlayerViewController.showsPlaybackControls = false
        videoPlayerView.addSubview(avPlayerViewController.view)
        
        var topSafeArea : CGFloat = 0
        if #available(iOS 11.0, *) {
            topSafeArea = APPDELEGATE.window?.rootViewController!.view.safeAreaInsets.top ?? 0
        } else {
            topSafeArea = APPDELEGATE.window?.rootViewController!.topLayoutGuide.length ?? 0
        }
        menuTopButtonConstraint.constant =  topSafeArea == 0.0 ? 8 : 52
      
    }
    
    override func prepareForReuse() {
             super.prepareForReuse()
            // self.videoPlayerView.isHidden = true
         //    avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect

     //        NotificationCenter.default.removeObserver(self)
             self.player = AVPlayer()
             self.avPlayerViewController.player = AVPlayer()
       //  self.videoPlayerView.isHidden = false
         
     }
    
    
    @objc func playerDidFinishPlaying(){
    }
    
    func setPlayer(object: RewardsModel) {
        thumbnailImageView.isHidden = false
       // thumbnailImageView.contentMode = .scaleAspectFill
        self.player = object.player ?? AVPlayer()
        self.avPlayerViewController.player = self.player
        sliderView.showsVolumeSlider = false
        sliderView.isHidden = true
       // self.thumbnailImageView.isHidden = false
     //   print("status",object.player)
      //  avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
        do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            player.isMuted = true
        }

      //  self.videoPlayerView.isHidden = false
     //   self.avPlayerViewController.player?.play()

//        if(object.isPlayed){
//            self.avPlayerViewController.player?.pause()
//            playPauseButton.isHidden = false
//        }else{
//            self.avPlayerViewController.player?.play()
//            playPauseButton.isHidden = true
//        }
        self.activityIndicator.isHidden = true

        self.avPlayerViewController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
                   [weak self] time in
            

                   if self?.avPlayerViewController.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {

                       if let isPlaybackLikelyToKeepUp = self?.avPlayerViewController.player?.currentItem?.isPlaybackLikelyToKeepUp {
                           //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
                         //  print("isPlaybackLikelyToKeepUp::--\(isPlaybackLikelyToKeepUp)")
                           
                           
                           self?.thumbnailImageView.isHidden = isPlaybackLikelyToKeepUp
                           if let currentTime = self?.avPlayerViewController.player?.currentItem?.currentTime().seconds {
                           // print("currentTime::--\(currentTime)")
                             self?.thumbnailImageView.isHidden = true
                            if currentTime < 0.3 {
                               
                                
//                                if self?.isFirstTime ?? true {
//                                    self?.thumbnailImageView.isHidden = false
//                                    self?.activityIndicator.isHidden = false
//                                }else {
//                                    self?.thumbnailImageView.isHidden = true
//                                    self?.activityIndicator.isHidden = true
//                                }
                               
                            }
                            
                               if currentTime > 1.0 {
                                   self?.thumbnailImageView.isHidden = true
                               }
                           }
                       }
                   }
               }
      //  self.isFirstTime = false
               
    }
    
    func cellSetup(obj: RewardsModel, type: VideoType){
        DispatchQueue.main.async {
           // self.playPauseButton.setImage(UIImage.init(named: obj.isPlayed ? "" : "icn_play"), for: .normal)
        }
      
        leftView.isHidden = type ==  .gallery
        rightView.isHidden = type == .gallery
        if type == .gallery {
            editStackBottomConstraint.constant = -65
            shareBottomConstraint.constant = 5
        }
        
//        if type == .gallery {
//            rightView.isHidden = true  // obj.is_save_to_gallery == "1"
//        }else {
//            rightView.isHidden = false
//        }
        
        let voteDouble = Double(obj.votes_count ?? "0") ?? 0.0
        let voteStr = voteDouble > 1 ? "\(voteFormatPoints(num: voteDouble)) Votes" : "\(voteFormatPoints(num: voteDouble)) Vote"
        voteLabel.attributedText = voteStr.getAttributedString( voteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        
        let viwsDouble = Double(obj.views_count ?? "0") ?? 0.0
        let likeStr = viwsDouble > 1 ? "\(voteFormatPoints(num: viwsDouble)) Views" : "\(voteFormatPoints(num: viwsDouble)) View"
        viewsLabel.attributedText = likeStr.getAttributedString(viwsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        captionLabel.text = obj.video_text?.base64Decoded()
        
        let winnerVoteDouble = Double(obj.winner_votes_count ?? "0") ?? 0.0
        let winnerVoteStr = winnerVoteDouble > 1 ? "\(voteFormatPoints(num: winnerVoteDouble)) Votes" : "\(voteFormatPoints(num: winnerVoteDouble)) Vote"
        leftVoteLabel.attributedText = winnerVoteStr.getAttributedString( voteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        let winnerViewsDouble = Double(obj.winner_views_count ?? "0") ?? 0.0
        let winnerlikeStr = winnerViewsDouble > 1 ? "\(voteFormatPoints(num: winnerViewsDouble)) Views" : "\(voteFormatPoints(num: winnerViewsDouble)) View"
        leftViewsLabel.attributedText = winnerlikeStr.getAttributedString(winnerViewsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        voteButton.isSelected = obj.is_voted == 1
        unvoteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
    }
    
    
    @IBAction func playButtonAction(_ sender: UIButton){
        self.playClickCompletion?()
    }
    @IBAction func backwardButtonAction(_ sender: UIButton){
        self.backwardClickCompletion?()
    }
    @IBAction func forwardButtonAction(_ sender: UIButton){
        self.forwardClickCompletion?()
    }
    @IBAction func shareButtonAction(_ sender: UIButton){
        self.shareClickCompletion?()
    }
    
    @IBAction func editButtonAction(_ sender: UIButton){
        self.editClickCompletion?()
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton){
        self.deleteClickCompletion?()
    }
    
    @IBAction func voteButtonAction(_ sender: UIButton){
        self.voteClickCompletion?()
    }
    
    @IBAction func muteButtonAction(_ sender: UIButton){
        self.muteClickCompletion?()
    }
}
