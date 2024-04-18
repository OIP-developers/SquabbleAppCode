//
//  VideoCellController.swift
//  VideoUI
//
//  Created by PT.Koanba on 10/09/22.
//

import Foundation
import Video
import UIKit
import AVFoundation
import MediaPlayer

public protocol VideoCellControllerDelegate {
    func didRequestVideo()
    func didCancelVideoRequest()
}


public final class VideoCellController: HLSVideoView {
    private let delegate: VideoCellControllerDelegate
    private var cell: VideoCell?
    private var isPlaying: Bool? = false
    private var row: Int?
    
    private(set) public var playerLooper: AVPlayerLooper?
    private(set) public var player: AVQueuePlayer?

    public init(delegate: VideoCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in collectionView: UICollectionView, indexPath: IndexPath, fromVC: String, video: VideosModel) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCell
        row = indexPath.row
        if fromVC == "Feed" || fromVC == "Search" {
            cell?.btnsView.isHidden = false
        } else {
            cell?.btnsView.isHidden = true
        }
        Logs.show(message: "SSSS: \(video.userVote) -- \(video.caption)")
        if video.userVote {
            cell?.voteBtn.tintColor = UIColor(named: "RED")
        } else {
            cell?.voteBtn.tintColor = .systemGray6
        }
        
        if video.postedUserFollow {
            cell?.followBtn.tintColor = UIColor(named: "RED")
        } else {
            cell?.followBtn.tintColor = .systemGray6
        }
        
        // user id == like user if check
        /*if let likes = video.likes {
            for like in likes {
                if like.userId == AppFunctions.getUserID() {
                    cell?.voteBtn.tintColor = UIColor(named: "RED")
                } else {
                    cell?.voteBtn.tintColor = .systemGray6
                }
            }
        } else {
            let dict = AppFunctions.getLike()
            if dict.keys.first == video.id && dict.values.first as? String == "like" {
                cell?.voteBtn.tintColor = UIColor(named: "RED")
                
            } else {
                cell?.voteBtn.tintColor = .systemGray6
            }
        }*/
        
        cell?.captionLbl.text = video.caption
        cell?.tagsLbl.text = "#\(video.name ?? "")"
        
        if let player = player {
            cell?.setVideo(with: player)
        }else{
            delegate.didRequestVideo()
        }
        Logs.show(message: "RELOADED VIDEO CELL")
        return cell!
    }
    
    func willDisplay(_ cell:UICollectionViewCell, in collectionView: UICollectionView, indexPath: IndexPath, video: VideosModel)  {
        (cell as? VideoCell)?.playPauseIV.isHidden = true
        if video.user != nil {
            (cell as? VideoCell)?.profilePic = video.user.profile_picture != nil ? video.user.profile_picture : "https://firebasestorage.googleapis.com:443/v0/b/squabble-42140.appspot.com/o/Images_Folder%2FprofImage_1664971698.jpg?alt=media&token=5ba6958c-4993-4728-ac4f-d96f448428fc"
        } else {
            (cell as? VideoCell)?.profilePic = "https://firebasestorage.googleapis.com:443/v0/b/squabble-42140.appspot.com/o/Images_Folder%2FprofImage_1664971698.jpg?alt=media&token=5ba6958c-4993-4728-ac4f-d96f448428fc"
        }
        
        (cell as? VideoCell)?.showHidePopupContents(value: false)

       
        if let player = player {
            (cell as? VideoCell)?.setVideo(with: player)
        }else{
            delegate.didRequestVideo()
        }
    }
    
    func preload() {
        delegate.didRequestVideo()
    }

    func cancelLoad() {
        player?.pause()
        releaseCellForReuse()
        delegate.didCancelVideoRequest()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    public func display(_ model: HLSVideoViewModel) {
        if let item = model.playerItem {
            let player = AVQueuePlayer(playerItem: item)
            ///player.volume = 0
            playerLooper = AVPlayerLooper(player: player, templateItem: item)
            self.player = player
            if row == 0 {
                self.player?.play()
            }
            //cell?.setVideo(with: player)
            cell?.setVideo(with: player, vidModel: model.video)
        }
        // Save ID here
        
        cell?.videoLoadingIndicator.startAnimating()
        
    }

    private func releaseCellForReuse() {
        cell?.releasePlayerForReuse()
        cell = nil
    }
    
    func muteButtonPressed() {
        DispatchQueue.main.async {
            if AppFunctions.getMute() {
                AppFunctions.saveMute(val: false)
                self.player?.volume = 1.0
            } else {
                AppFunctions.saveMute(val: true)
                self.player?.volume = 0
            }
            self.cell?.updateMuteButton()
        }
    }
    
    func muteButtonLongPressed() {
        DispatchQueue.main.async {
            self.cell?.updateMuteButton()
        }
    }
}

