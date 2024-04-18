//
//  MessageListTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import SDWebImage


class MessageListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.darkGray.cgColor//KAppDarkGrayColor.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSetup(obj: ChatModel){
        if let url = URL(string: obj.profilePic ?? "") {
            profileImageView.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
            //profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
        }
        
        countLabel.isHidden = obj.chatMessages != nil ? obj.chatMessages.count == 0 : false
        photoLabel.textColor = UIColor.darkGray
        messageLabel.textColor = UIColor.darkGray
        messageLabel.text = obj.chatMessages != nil ? obj.chatMessages.last?.message : "" //obj.last_message?.base64Decoded()
        statusView.isHidden = true
        countLabel.text = "\(obj.chatMessages != nil ? obj.chatMessages.count : 0)"
        photoView.isHidden = true
        
        /*if obj.last_message_chat_type == "1" {
            photoView.isHidden = false
        }else if obj.last_message_chat_type == "3" {
            photoView.isHidden = true
            messageLabel.text = "Shared a video"
        }else {
            photoView.isHidden = true
            messageLabel.text = obj.last_message?.base64Decoded()
        }*/
        
        //timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.time ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.time ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.time ?? "", format: "MM/dd/yyyy")
        
        nameLabel.text = obj.name
    }

}
