//
//  MyRewardsTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class MyRewardsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var prizeAmountLabel: UILabel!
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    var claimButtonClicked: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func cellSetup(obj: RewardsModel){
        let dobPrize = Double(obj.challenge.price ?? "0.0")
        prizeAmountLabel.attributedText = getTextWithTokenImage(startString: " ", price: " \(obj.challenge.price ?? "")", imageAddtionalSize: 3, imageName: "ic_giftbox")
       // prizeAmountLabel.text = String(format: "$ %.2f", dobPrize!)
        nameLabel.text = obj.challenge.title
        claimButton.isUserInteractionEnabled = obj.challenge.claim_status == "2"
        if let url = URL(string: obj.video_thumbnail ?? "") {
            self.challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
//        else if obj.video_thumbnail ?? "" == "" {
//            self.challengeImageView.image = UIImage(named: "sizzle_card")
//        }
        
        dateLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp:obj.created_att ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_att ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_att ?? "", format: "MM/dd/yyyy")
      //  dateLabel.text = getDateForInfoFromTimeStamp(strDate: "\(obj.challenge.start_timestamp ?? "")")
        if obj.challenge.claim_status == "2" {
            claimButton.setTitle("Claimed", for: .normal)
            claimButton.backgroundColor = KAppGrayColor
            claimButton.isUserInteractionEnabled = false
        }else {
            claimButton.setTitle("Claim", for: .normal)
            claimButton.backgroundColor = KAppRedColor
            claimButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func claimButtonAction(_ sender: UIButton){
        claimButtonClicked?()
    }

}
