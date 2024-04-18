//
//  SenderChatCell.swift
//  HP
//
//  Created by apple on 05/11/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import UIKit


class SenderChatCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shapeView: ChatView!
    @IBOutlet weak var seenImageView: UIImageView!
    
    
    var vc : UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shapeView.messageType = .sent
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        messageLabel.addGestureRecognizer(tap)
        
        shapeView.setNeedsDisplay()
    }

    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        //print("tap working")
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        
        let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        vc.selectedIndex = 4
        goneToVideo = true
        self.vc.navigationController?.pushViewController(vc, animated: true)
    }
    
    func populateCell(obj: ChatModelExt) {
        messageLabel.text = obj.message
        
        if obj.message.contains("Video : ") {
            messageLabel.isUserInteractionEnabled = true
            let splitString = obj.message.components(separatedBy: "Video : ")
            
            videoToGo = splitString[1]
            
            let fullString = obj.message
            let range = (fullString! as NSString).range(of: videoToGo)
            let attributedString = NSMutableAttributedString(string: fullString!)
            
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: range)
            
            attributedString.addAttribute(NSAttributedString.Key.font,
                                          value: UIFont.boldSystemFont(ofSize: 16),
                                          range: range)
            
            messageLabel.attributedText = attributedString
        } else {
            messageLabel.text = obj.message
            messageLabel.isUserInteractionEnabled = false
        }
        
        timeLabel.text = AppFunctions.convertDateStringFormat(originalDateString: obj.time)
        
      //  seenImageView.image = UIImage.init(named: model.read_status == "1" ? "icn_double_check" : "icn_single_tick")
        seenImageView.image = UIImage.init(named: "icn_double_check")
        seenImageView.tintColor = .red//model.read_status == "1"  ? .red  : .lightGray

        shapeView.messageType = .sent
        shapeView.setNeedsDisplay()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
