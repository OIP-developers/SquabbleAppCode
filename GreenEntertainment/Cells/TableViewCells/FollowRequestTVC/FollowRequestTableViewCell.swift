//
//  FollowRequestTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 27/10/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class FollowRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commonLabel: UILabel!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var crossCompletion: (() -> Void)? = nil
    var acceptCompletion: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSetup(obj: NotificationModel){
        timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
        let body = "\(obj.who_followed_username ?? "") sent you follow request"
        commonLabel.attributedText = body.getAttributedString(obj.who_followed_username ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
        if let url = URL(string: obj.who_followed_image ?? "") {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
        }
    }
    
    @IBAction func crossButtonAction(_ sender: UIButton){
        self.crossCompletion?()
    }
    
    @IBAction func acceptButtonAction(_ sender: UIButton){
        self.acceptCompletion?()
    }

}
