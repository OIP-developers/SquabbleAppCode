//
//  ReceiverImageTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class ReceiverImageTableViewCell: UITableViewCell {
    
       @IBOutlet weak var messageImageView: UIImageView!
       @IBOutlet weak var timeLabel: UILabel!
       @IBOutlet weak var shapeView: ChatView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shapeView.messageType = .recieved
        shapeView.setNeedsDisplay()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func populateCell(with model: Chat) {
//           if let url = URL(string: model.url ?? "") {
//               messageImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
//           }
        messageImageView.image = UIImage(named: "sizzle_card")
           //timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: model.created_timestamp ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(model.created_timestamp ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: model.created_timestamp ?? "", format: "MM/dd/yyyy")
           
           shapeView.messageType = .recieved
           shapeView.setNeedsDisplay()
       }
    
}
