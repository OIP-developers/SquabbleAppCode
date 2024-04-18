//
//  SenderImageTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class SenderImageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shapeView: ChatView!
    @IBOutlet weak var messageStatusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shapeView.messageType = .sent
        shapeView.setNeedsDisplay()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCell(with model: Chat) {
//        if let url = URL(string: model.url ?? "") {
//            messageImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
//        }
        messageImageView.image = UIImage(named: "sizzle_card")
        
        timeLabel.text = "Time"//Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: model.created_timestamp ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(model.created_timestamp ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: model.created_timestamp ?? "", format: "MM/dd/yyyy")
        
        messageStatusImageView.image = UIImage.init(named: "icn_double_check")
        messageStatusImageView.tintColor = .red//model.read_status == "1"  ? .red  : .lightGray
        shapeView.messageType = .sent
        shapeView.setNeedsDisplay()
    }
    
}
