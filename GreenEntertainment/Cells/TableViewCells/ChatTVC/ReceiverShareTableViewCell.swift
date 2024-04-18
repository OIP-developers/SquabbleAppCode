//
//  ReceiverShareTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 23/10/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class ReceiverShareTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shapeView: ChatView!
    @IBOutlet weak var seenImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var playCompletion: (() -> Void)? = nil
    
    
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
//        if let url = URL(string: model.video_thumbnail ?? "") {
//            thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
//        }
        thumbnailImageView.image = UIImage(named: "sizzle_card")
        //timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: model.created_timestamp ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(model.created_timestamp ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: model.created_timestamp ?? "", format: "MM/dd/yyyy")
        DispatchQueue.main.async {
            self.topConstraint.constant = 5//model.share_message?.isEmpty ?? true ? 0 : 5
        }
        messageLabel.text = model.share_message?.base64Decoded()
        seenImageView.image = UIImage.init(named: "icn_double_check")
        seenImageView.tintColor = .lightGray//model.read_status == "1"  ? .red  : .lightGray
        shapeView.messageType = .sent
        shapeView.setNeedsDisplay()
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        playCompletion?()
    }
}
