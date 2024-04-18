//
//  FollowTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var donateImageView: UIImageView!

    
    var followClicked: ((Bool) -> Void)? = nil
    var timer = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = KAppDarkGrayColor.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSetup(obj: FollowUsers, type: String, isMyProfile: Bool = false){
        /*switch type {
        case .followers:
            
                   if obj.is_following == 0, obj.request_status == "" {
                      // followButton.isSelected = false
                    followButton.setTitle("Follow", for: .normal)
                     //  followLabel.text = "Follow"
                   }else if obj.setting == "1", obj.is_following == 0, obj.request_status == "0" {
                     followButton.setTitle("Requested", for: .normal)
                        //   followLabel.text = "Requested"
                   }else if obj.is_following == 1{
                     //  followButton.isSelected = true
                     followButton.setTitle("Unfollow", for: .normal)
                     //  followLabel.text = "Unfollow"
                   }else {
                       //followLabel.text = "Follow"
                     followButton.setTitle("Follow", for: .normal)
                      // followButton.isSelected = false
                   }
                   
          //  followButton.setTitle( obj.followingStatus ?? false ?  "Unfollow" : "Follow", for: .normal)
            widthConstraint.constant = 80
            followButton.isHidden = AuthManager.shared.loggedInUser?.user_id == obj.user_id

        default:
            if isMyProfile {
                followButton.setTitle(obj.is_following == 0 ?  "Follow" : "Unfollow", for: .normal)
                widthConstraint.constant = 100
            }else {
                if obj.is_following == 0, obj.request_status == "" {
                    // followButton.isSelected = false
                    followButton.setTitle("Follow", for: .normal)
                    followButton.backgroundColor = KAppRedColor

                    //  followLabel.text = "Follow"
                }else if obj.setting == "1", obj.is_following == 0, obj.request_status == "0" {
                    followButton.setTitle("Requested", for: .normal)
                    followButton.backgroundColor = KAppRedColor

                    //   followLabel.text = "Requested"
                }else if obj.is_following == 1{
                    //  followButton.isSelected = true
                    followButton.setTitle("Unfollow", for: .normal)
                    followButton.backgroundColor = KAppRedColor
                    //  followLabel.text = "Unfollow"
                }else {
                    //followLabel.text = "Follow"
                    followButton.setTitle("Follow", for: .normal)
                    followButton.backgroundColor = KAppRedColor

                    // followButton.isSelected = false
                }
            }
            
        }*/
        //if obj != nil {
            followButton.isHidden = true
            nameLabel.text = obj.first_name
            
            if let url = URL(string: obj.profile_picture ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
        //} else {
        //    followButton.isHidden = true
        //}
        //if obj != nil {
            followButton.isHidden = true
            nameLabel.text = obj.first_name

            if let url = URL(string: obj.profile_picture ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
        //} else {
        //    followButton.isHidden = true
        //}
        
    }
    
    func cellSetupForShare(obj: User) {
        widthConstraint.constant = 70
        
        if obj.selectedStatus == 0 {
            followButton.setTitle("Send", for: .normal)
            followButton.backgroundColor = KAppRedColor
            followButton.layer.borderColor = UIColor.white.cgColor
            followButton.layer.borderWidth =  0
            followButton.isUserInteractionEnabled = true
        }else if obj.selectedStatus == 1 {
            followButton.setTitle("Undo", for: .normal)
            followButton.backgroundColor =  .clear
            followButton.layer.borderColor = UIColor.white.cgColor
            followButton.layer.borderWidth =  1
            followButton.isUserInteractionEnabled = true
        }else {
            followButton.setTitle("Sent", for: .normal)
            followButton.backgroundColor =  .clear
            followButton.layer.borderColor = UIColor.white.cgColor
            followButton.layer.borderWidth =  1
            followButton.isUserInteractionEnabled = false
        }
        
        if let url = URL(string: obj.image ?? "") {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
        nameLabel.text = obj.username
        
       
    }
    
    @IBAction func followButtonAction(_ sender: UIButton){
        followClicked?(true)
    }

}
