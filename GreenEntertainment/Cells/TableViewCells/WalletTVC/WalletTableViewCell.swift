//
//  WalletTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 16/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var commonImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        commonImageView.layer.cornerRadius = commonImageView.frame.height / 2
        commonImageView.clipsToBounds = true
        commonImageView.layer.borderWidth = 1.0
        commonImageView.layer.masksToBounds = true
        commonImageView.layer.borderColor = KAppDarkGrayColor.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSetup(obj: Account){
        if obj.transaction_type == "1" && obj.credit_debit == "1"{   //Money added to wallet
            commonImageView.image = UIImage(named: "ic_add_gift")
            let dobPrize = Double(obj.amount ?? "0.0")
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "+ ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
           // amountLabel.text = String(format: "+ $ %.2f", dobPrize!)
            nameLabel.text = (Int(dobPrize ?? 0.0)) > 1 ? "Added gifts to wallet" :  "Added gift to wallet"
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
          //  pendingLabel.isHidden = true
        }   else if obj.transaction_type == "1" && obj.credit_debit == "0"{   //Money added to wallet
            commonImageView.image = UIImage(named: "icn_add_money_white")
            let dobPrize = Double(obj.amount ?? "0.0")
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "+ ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: -40)
           // amountLabel.text = String(format: "+ $ %.2f", dobPrize!)
            nameLabel.text = (Int(dobPrize ?? 0.0)) > 1 ? "Added tokens to wallet" :  "Added token to wallet"
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
          //  pendingLabel.isHidden = true
        }else if obj.transaction_type == "2" {  // donation sent
            if let url = URL(string: obj.receiver_profile_image ?? "") {
                commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            
            if obj.donation_message != "" {
                let dobPrize = Double(obj.amount ?? "0.0")
                if (Int(dobPrize ?? 0.0)) > 1 {
                    let totalStr = "Sent gifts to \(obj.receiver_username ?? "")\n\(obj.donation_message?.base64Decoded() ?? "")"
                    
                    nameLabel.attributedText = totalStr.getAttributedString(obj.donation_message?.base64Decoded() ?? "", color: .darkGray, font: Fonts.Rubik.regular.font(.medium))
                }else {
                    let totalStr = "Sent gift to \(obj.receiver_username ?? "")\n\(obj.donation_message?.base64Decoded() ?? "")"
                    
                    nameLabel.attributedText = totalStr.getAttributedString(obj.donation_message?.base64Decoded() ?? "", color: .darkGray, font: Fonts.Rubik.regular.font(.medium))
                }
                
            }else {
                nameLabel.text = Int(obj.amount ?? "0") ?? 0 > 1 ?  "Sent gifts to \(obj.receiver_username ?? "")" : "Sent gift to \(obj.receiver_username ?? "")"
            }
            
            //nameLabel.text = "Donated money to \(obj.receiver_username ?? "")"
            let dobPrize = Double(obj.amount ?? "0.0")
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
         //   pendingLabel.isHidden = true
        }else if obj.transaction_type == "3" {  // donation recieved
            if let url = URL(string: obj.user_profile_image ?? "") {
                commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            if obj.donation_message != "" {
                let dobPrize = Double(obj.amount ?? "0.0")
                if (Int(dobPrize ?? 0.0)) > 1 {
                    let totalStr = "Recieved gifts from \(obj.receiver_username ?? "")\n\(obj.donation_message?.base64Decoded() ?? "")"
                    
                    nameLabel.attributedText = totalStr.getAttributedString(obj.donation_message?.base64Decoded() ?? "", color: .darkGray, font: Fonts.Rubik.regular.font(.medium))
                }else {
                    let totalStr = "Recieved gift from \(obj.receiver_username ?? "")\n\(obj.donation_message?.base64Decoded() ?? "")"
                    
                    nameLabel.attributedText = totalStr.getAttributedString(obj.donation_message?.base64Decoded() ?? "", color: .darkGray, font: Fonts.Rubik.regular.font(.medium))
                }
                
            }else {
                nameLabel.text = (Int(obj.amount ?? "0") ?? 0) > 1 ? "Recieved gifts from \(obj.receiver_username ?? "")" :  "Recieved gift from \(obj.receiver_username ?? "")"
            }
            
          //  nameLabel.text = "Recieved money from \(obj.username ?? "")"
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
            let dobPrize = Double(obj.amount ?? "0.0")
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "+ ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
          //  amountLabel.text = String(format: "+ $ %.2f", dobPrize!)
         //   pendingLabel.isHidden = true
        }else if obj.transaction_type == "4" {  // prize
            
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                           commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
                       }
                       nameLabel.text = "Prize won in challenge"
                       timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
                       let dobPrize = Double(obj.amount ?? "0.0")
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "+ ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                       //amountLabel.text = String(format: "+ $ %.2f", dobPrize!)
           // pendingLabel.isHidden = true
            
        }else if obj.transaction_type == "5" {  // withdraw
            commonImageView.image = UIImage(named: "icn_send money to bank")
            let dobPrize = Double(obj.amount ?? "0.0")
            
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
//            pendingLabel.isHidden = false
//            pendingLabel.text = obj.withdraw_status
            if obj.withdraw_status == "Pending" {
                if Int(obj.amount ?? "0") ?? 0 > 1 {
                    nameLabel.attributedText = "Transferring gifts from wallet to bank\nProcessing...".getAttributedString("Processing...", color: RGBA(0, g: 144, b: 255, a: 1.0), font: Fonts.Rubik.regular.font(.large))
                    self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                }else {
                    nameLabel.attributedText = "Transferring gift from wallet to bank\nProcessing...".getAttributedString("Processing...", color: RGBA(0, g: 144, b: 255, a: 1.0), font: Fonts.Rubik.regular.font(.large))
                    self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                }
                
               // amountLabel.text = String(format: "- $ %.2f", dobPrize!)
                
            }else if obj.withdraw_status == "Cancelled" {
                if Int(obj.amount ?? "0") ?? 0 > 1 {
                    nameLabel.attributedText = "Transferring gifts from wallet to bank\nTransaction Cancelled".getAttributedString("Transaction Cancelled", color: KAppRedColor, font: Fonts.Rubik.regular.font(.large))
                    self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                }else {
                    nameLabel.attributedText = "Transferring gift from wallet to bank\nTransaction Cancelled".getAttributedString("Transaction Cancelled", color: KAppRedColor, font: Fonts.Rubik.regular.font(.large))
                    self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                }
                
              //  amountLabel.text = String(format: "- $ %.2f", dobPrize!)
            }else {
                if Int(obj.amount ?? "0") ?? 0 > 1 {
                    nameLabel.attributedText = "Transferring gifts from wallet to bank\nSuccessfull".getAttributedString("Successfull", color: RGBA(35, g: 233, b: 54, a: 1.0), font: Fonts.Rubik.regular.font(.large))
                    self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                }else {
                    nameLabel.attributedText = "Transferring gift from wallet to bank\nSuccessfull".getAttributedString("Successfull", color: RGBA(35, g: 233, b: 54, a: 1.0), font: Fonts.Rubik.regular.font(.large))
                    self.amountLabel.attributedText =  getTextWithTokenImage(startString: "- ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
                }
                
               // amountLabel.text = String(format: "- $ %.2f", dobPrize!)
            }
        }else if obj.transaction_type == "6" {   //6=>random voter prize
            commonImageView.image = UIImage(named: "icn_add_money_white")
            let dobPrize = Double(obj.amount ?? "0.0")
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "+ ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
          //  amountLabel.text = String(format: "+ $ %.2f", dobPrize!)
            nameLabel.text = "Random voter prize added to wallet"
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
        }else if obj.transaction_type == "7"{     // 7=>refund to wallet
            commonImageView.image = UIImage(named: "icn_add_money_white")
            let dobPrize = Double(obj.amount ?? "0.0")
          //  amountLabel.text = String(format: "+ $ %.2f", dobPrize!)
            nameLabel.text = Int(dobPrize ?? 0.0) > 1 ? "Refunded gifts to wallet" : "Refunded gift to wallet"
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "+ ", price: " \(Int(dobPrize ?? 0.0))", imageAddtionalSize: 0, imageName: "ic_gift",imageOffsetY: -1)
            timeLabel.text = getReadableTime(timeStamp: obj.created_timestamp ?? "")
        }
    }

}
