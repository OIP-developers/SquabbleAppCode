//
//  SendingMoneyViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import SimpleAnimation
import UICircularProgressRing


class SendingMoneyViewController: UIViewController {
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var sendingLabel: UILabel!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var bankImage: UIImageView!
    @IBOutlet weak var profileView: UIView!
    
    var transferType: TransferType = .bank
    var amount = ""
    var userName = ""
    var userImage = ""
    var timer = Timer()
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    func customSetup(){
        customiseView()
        self.amountLabel.attributedText =  getTextWithTokenImage(startString: " ", price: " \(Int(amount) ?? 0)", imageAddtionalSize: -25)
       // amountLabel.text = "$ \(amount)"
        statusImage.isHidden = true
        self.sendingLabel.isHidden = false
        
        statusView.popIn(fromScale: 0.3, duration: 1, delay: 0.2) { (status) in
            self.statusImage.popIn(fromScale: 0.8, duration: 1, delay: 1) { (status) in
                self.statusImage.isHidden = false
                self.sendingLabel.isHidden = false
                
                if Int(self.amount) ?? 0 > 1 {
                    self.sendingLabel.text = self.transferType == .bank ? "Transferring gifts to bank" : self.transferType == .wallet ? "Tokens added successfully" : self.transferType == .gift ? "Gifts purchased successfully." : "Gifts sent to \(self.userName)"
                }else {
                    self.sendingLabel.text = self.transferType == .bank ? "Transferring gift to bank" : self.transferType == .wallet ? "Token added successfully" : self.transferType == .gift ? "Gift purchased successfully." : "Gift sent to \(self.userName)"
                }
                
            }
        }
        
        delay(delay: 3) {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: WalletViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }else if controller.isKind(of: UserProfileViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }else if controller.isKind(of: ChatViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }else if controller.isKind(of: ChallengeListViewController.self){
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        
        switch transferType {
        case .wallet:
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                profileImage.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            break
        case .bank:
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                profileImage.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "", price: " \(Int(amount) ?? 0)", imageAddtionalSize: 0, imageName: "ic_giftbox",imageOffsetY: -1)
            break
        case .donate:
            profileImage.layer.cornerRadius = 23
            profileImage.clipsToBounds = true
            profileImage.layer.borderWidth = 1.0
            profileImage.layer.masksToBounds = true
            profileImage.layer.borderColor = KAppDarkGrayColor.cgColor
            
            bankImage.layer.cornerRadius = 23
            bankImage.clipsToBounds = true
            bankImage.layer.borderWidth = 1.0
            bankImage.layer.masksToBounds = true
            bankImage.layer.borderColor = KAppDarkGrayColor.cgColor
            
            
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                profileImage.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            
            if let url = URL(string: userImage) {
                bankImage.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "", price: " \(Int(amount) ?? 0)", imageAddtionalSize: 0, imageName: "ic_giftbox",imageOffsetY: -1)
            break
            
        case .gift:
            self.amountLabel.attributedText =  getTextWithTokenImage(startString: "", price: " \(Int(amount) ?? 0)", imageAddtionalSize: 0, imageName: "ic_giftbox",imageOffsetY: -1)
            profileImage.image = UIImage.init(named: "icn_add_money")
            bankImage.image = UIImage.init(named: "ic_purchase_gifts")
//            profileImage.image = UIImage.init(named: "ic_donate_token")
//            bankImage.image = UIImage.init(named: "ic_gift_filled")
            
            profileImage.layer.borderWidth = 0.0

            break
        }
    }
    
    func  customiseView(){
        viewHeightConstraint.constant = transferType == .bank ? 60 : 0
        sendImage.isHidden = transferType == .wallet
        profileImage.isHidden = transferType == .wallet
        bankImage.isHidden = transferType == .wallet
        profileView.isHidden = transferType == .wallet
        if Int(self.amount) ?? 0 > 1 {
            self.sendingLabel.text = transferType == .bank ? "Transferring Gifts to Bank" : transferType == .wallet ? "Sending tokens to Wallet" : transferType == .gift ? "Purchasing Gifts" :  "Sending gifts to \(userName)"
        }else {
        self.sendingLabel.text = transferType == .bank ? "Transferring Gift to Bank" : transferType == .wallet ? "Sending token to Wallet" : transferType == .gift ? "Purchasing Gift" :  "Sending gift to \(userName)"
        }
        topConstraint.constant = 68   // transferType == .bank ? 68 :  30
    }
    
    @objc func updateTimerProgress() {
        counter += 1
        UIView.animate(withDuration: 0.001) {
            self.view.layoutIfNeeded()
        }
        if counter == 3 {
            self.timer.invalidate()
        }
    }
    
}
