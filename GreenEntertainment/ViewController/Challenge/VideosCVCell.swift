//
//  VideosCVCell.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on Thursday15/09/2022.
//  Copyright © 2022 Quytech. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import ActiveLabel

class VideosCVCell: UICollectionViewCell {
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var imagesView: UIImageView!
    var player = AVPlayer()
    var isPlaying = false
    var viewCompletion:(()  -> Void)? = nil
    let avPlayerViewController = AVPlayerViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadImage(name: String) {
        imagesView.image = UIImage(named: name)
    }

    func setPlayer(urlString: String) {
        
        Logs.show(message: "setPlayer Vid URL :::: \(urlString)")
        
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
        }
   
        self.avPlayerViewController.player = self.player
        player.play()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            player.isMuted = true
        }
        
        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
        
        var isFirstTime = true
        isPlaying = true
        self.avPlayerViewController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.avPlayerViewController.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                
                if (self?.avPlayerViewController.player?.currentItem?.isPlaybackLikelyToKeepUp) != nil {
                    
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
        }
    }
    
}
