//
//  NotificationFollowTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class NotificationFollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var donationLabel: UILabel!

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followWidthConstraint: NSLayoutConstraint!
    
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
    
    func cellSetup(obj: NotificationModel){
        
        statusView.isHidden = true
        switch obj.notification_type {
        case Constants.kACCEPTED_REQUEST:
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followButton.isHidden = true //obj.is_following == 1
            let body = "\(obj.who_followed_username ?? "") accepted your request"
            titleLabel.attributedText = body.getAttributedString(obj.who_followed_username ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            if let url = URL(string: obj.who_followed_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kUSER_FOLLOW:
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followButton.isHidden = true //obj.is_following == 1
            let body = "\(obj.who_followed_username ?? "") followed you"
            titleLabel.attributedText = body.getAttributedString(obj.who_followed_username ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            if let url = URL(string: obj.who_followed_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kVIDEO_SHARE:
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followButton.isHidden = true
            titleLabel.attributedText = obj.body?.getAttributedString(obj.user_fullname_sharing_video ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            if let url = URL(string: obj.user_image_sharing_video ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kVIDEO_VOTE:
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            if let url = URL(string: obj.sender_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            followButton.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kGOT_NEW_BADGE:
            titleLabel.text = obj.body
            if let url = URL(string: obj.badge_thumbnail ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followButton.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kWINNER_ANNOUNCEMENT:
            titleLabel.attributedText = obj.body?.getAttributedString(obj.winner_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followButton.isHidden = true
            if let url = URL(string: obj.winner_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kWINNER_NOTIFIED:
        timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
        followButton.isHidden = true
        titleLabel.text = obj.body
        //titleLabel.attributedText = obj.body?.getAttributedString(obj.who_followed_fullname ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
        if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kMONEY_ADDED_TO_WALLET,Constants.kREFUND_TO_WALLET,Constants.kRANDOM_VOTER_PRIZE:
            followButton.isHidden = true
            profileImageView.image = UIImage(named: "icn_add_money_white")
            titleLabel.attributedText = obj.body?.getAttributedString(obj.winner_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kWITHDRAW_MONEY_FROM_WALLET,Constants.kWITHDRAW_MONEY_REQUEST_APPROVED:
            followButton.isHidden = true
            profileImageView.image = UIImage(named: "icn_send money to bank")
            titleLabel.attributedText = obj.body?.getAttributedString(obj.winner_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kDONATION_SENT:
            followButton.isHidden = true
            if let url = URL(string: obj.receiver_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
            }
            
            
          //  let totalStr = "\(obj.body ?? "") \n\(obj.donation_message ?? "")"
            titleLabel.attributedText = obj.body?.getAttributedString(obj.receiver_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            if obj.donation_message ?? "" == "" {
                donationLabel.text = ""
            }else {
                donationLabel.text = (obj.donation_message ?? "").base64Decoded()
            }
            statusView.isHidden = true
            followWidthConstraint.constant = 0
        case Constants.kDONATION_RECEIVED:
            followButton.isHidden = true
            if let url = URL(string: obj.sender_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            if obj.donation_message ?? "" == "" {
                donationLabel.text = ""
            }else {
                donationLabel.text = (obj.donation_message ?? "").base64Decoded()
            }
            statusView.isHidden = true
            followWidthConstraint.constant = 0
        case Constants.kREWARD_CLAIMED:
            followButton.isHidden = true
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
            }
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            statusView.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kWITHDRAW_MONEY_FROM_WALLET:
            followButton.isHidden = true
             profileImageView.image = UIImage(named: "icn_send money to bank")
            
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            statusView.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kMANUAL_NOTIFICATION:
            followButton.isHidden = true
             profileImageView.image = UIImage(named: "sizzle_card")
            
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            statusView.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        case Constants.kVIDEO_TAG:
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            if let url = URL(string: obj.sender_image ?? "") {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            followButton.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        default:
            followButton.isHidden = true
            profileImageView.image = UIImage(named: "sizzle_card")
            
            titleLabel.attributedText = obj.body?.getAttributedString(obj.sender_name ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
            timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
            statusView.isHidden = true
            followWidthConstraint.constant = 0
             donationLabel.text = ""
        }
        
    
    }
    
}
