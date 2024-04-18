//
//  LeaderboardImageCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ScalingCarousel

class LeaderboardImageCollectionViewCell: ScalingCarouselCell {
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followView: UIView!
    var cellClicked: ((Bool) -> Void)? = nil
    var profileClicked: ((Bool) -> Void)? = nil
    var shareClicked: ((Bool) -> Void)? = nil
    var followClicked: ((Bool) -> Void)? = nil

    
    func cellSetup(obj: VideosModel) {
        challengeImageView.contentMode = .scaleAspectFill
        if let url = URL(string: obj.thumbnail_url ?? "") {
            challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
        }
        if let url = URL(string: obj.user.profile_picture ?? "") {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
        let voteDouble = Double(obj.likes_count ?? 0)
        let voteStr = voteDouble > 1 ? "\(voteFormatPoints(num: voteDouble)) Votes" : "\(voteFormatPoints(num: voteDouble)) Vote"
        voteLabel.attributedText = voteStr.getAttributedString(voteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        usernameLabel.text = obj.user.first_name
        
        let viwsDouble = Double(obj.likes_count ?? 0)
        let likeStr = viwsDouble > 1 ? "\(voteFormatPoints(num: viwsDouble)) Views" : "\(voteFormatPoints(num: viwsDouble)) View"
        likeLabel.attributedText = likeStr.getAttributedString(viwsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        likeLabel.isHidden = true
        followButton.isSelected = false
        //followView.isHidden = obj.is_following == 3
        followLabel.text = followButton.isSelected ? "Following" : "Follow"
        
        /*if obj.is_following == 0, obj.request_status == "" {
            followButton.isSelected = false
            followLabel.text = "Follow"
        } else if obj.setting == "1", obj.is_following == 0, obj.request_status == "0" {
            followLabel.text = "Requested"
        } else if obj.is_following == 1{
            followButton.isSelected = true
            followLabel.text = "Unfollow"
        } else {
            followLabel.text = "Follow"
            followButton.isSelected = false
        }*/
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = KAppDarkGrayColor.cgColor
    }
    
    /*func cellSetup(obj: RewardsModel) {
        challengeImageView.contentMode = .scaleAspectFill
        if let url = URL(string: obj.video_thumbnail ?? "") {
            challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
        }
        if let url = URL(string: obj.user_image ?? "") {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
        let voteDouble = Double(obj.votes_count ?? "0") ?? 0.0
        let voteStr = voteDouble > 1 ? "\(voteFormatPoints(num: voteDouble)) Votes" : "\(voteFormatPoints(num: voteDouble)) Vote"
        voteLabel.attributedText = voteStr.getAttributedString(voteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        usernameLabel.text = obj.username
        
        let viwsDouble = Double(obj.views_count ?? "0") ?? 0.0
        let likeStr = viwsDouble > 1 ? "\(voteFormatPoints(num: viwsDouble)) Views" : "\(voteFormatPoints(num: viwsDouble)) View"
        likeLabel.attributedText = likeStr.getAttributedString(viwsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        followButton.isSelected = obj.is_following == 1
        followView.isHidden = obj.is_following == 3
        followLabel.text = followButton.isSelected ? "Following" : "Follow"
        
        if obj.is_following == 0, obj.request_status == "" {
            followButton.isSelected = false
            followLabel.text = "Follow"
        }else if obj.setting == "1", obj.is_following == 0, obj.request_status == "0" {
            followLabel.text = "Requested"
        }else if obj.is_following == 1{
            followButton.isSelected = true
            followLabel.text = "Unfollow"
        }else {
            followLabel.text = "Follow"
            followButton.isSelected = false
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = KAppDarkGrayColor.cgColor
    }*/
    
    @IBAction func videoButtonAction(_ sender: UIButton){
        cellClicked?(true)
    }
    @IBAction func profileButtonAction(_ sender: UIButton){
        profileClicked?(true)
    }
    
    @IBAction func followButtonAction(_ sender: UIButton){
        followClicked?(true)
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton){
        shareClicked?(true)
    }
    

}
