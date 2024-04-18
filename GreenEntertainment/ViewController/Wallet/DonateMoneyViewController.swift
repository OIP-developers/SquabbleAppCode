//
//  DonateMoneyViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class DonateMoneyViewController: UIViewController {
    @IBOutlet weak var addMessageButton: UIButton!
    @IBOutlet weak var messageTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var donateNameLabel: UILabel!
    @IBOutlet weak var dollarLabel: UILabel!

    
    var userId: String?
    var userName: String?
    var amount = ""
    var userImage : String?
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getWalletBalance()
    }
    
    //MARK:- Helper Method
    func customSetup(){
        messageTextField.isHidden = true
        donateNameLabel.text = "Send Gifts to \(userName ?? "")"
        dollarLabel.attributedText = getTextWithTokenImage(startString: "", price: "", imageAddtionalSize: 3, imageName: "ic_giftbox")
    }
    
    //MARK:- UIButton Method
    @IBAction func addMessageButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        addMessageButton.isHidden = true
        messageTextField.isHidden = false
    }
    
    @IBAction func donateButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        amount = (amountTextField.text?.trimWhiteSpace ?? "") as String
        if amount.last == "." {
            amount = String(amount.dropLast())
        }
        
        if amountTextField.text?.isEmpty ?? false {
            AlertController.alert(message: ValidationMessage.EmptyDonateAmount.rawValue)
        }else if let transferAmount = Double(amount){
            if transferAmount < 1 {
                AlertController.alert(message: ValidationMessage.MinimumAmount.rawValue)
            }else if !(amountTextField.text?.containsNumberOnly() ?? false){
                AlertController.alert(message: ValidationMessage.ValidAmount.rawValue)
            }else {
                if let totalAmount = AuthManager.shared.loggedInUser?.gift_balance {
                    if let transferAmount = Double(amount){
                        if totalAmount < Int(transferAmount) {
                            if let vc = UIStoryboard.wallet.get(InsufficientPopupViewController.self){
                                vc.modalPresentationStyle = .custom
                                vc.modalTransitionStyle = .crossDissolve
                                vc.isFromGift = true
                                vc.completion = {
                                    
//                                    if Int(transferAmount) > Int(AuthManager.shared.loggedInUser?.user_balance ?? 0.0) {
//                                        if let vc = UIStoryboard.wallet.get(WalletViewController.self) {
//                                          //  vc.transferType = .wallet
//                                            self.navigationController?.pushViewController(vc, animated: true)
//                                        }
//                                    }else {
//                                        if let vc = UIStoryboard.wallet.get(PurchaseGiftsViewController.self) {
//                                            vc.transferType = .wallet
//                                            self.navigationController?.pushViewController(vc, animated: true)
//                                        }
//                                    }
                                    
                                    
                                    if let vc = UIStoryboard.wallet.get(PurchaseGiftsViewController.self) {
                                      //  vc.transferType = .wallet
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                                navigationController?.present(vc, animated: true, completion: nil)
                            }
                            
                        }else {
                            AlertController.alert(title: "", message: "Are you sure?", buttons: ["Yes","No"]) { (alert, selectedIndex) in
                                if selectedIndex == 0 {
                                    self.donateMoneyToUser()
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension DonateMoneyViewController: UITextFieldDelegate  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 0 { // amount field
            if str.length > 8 || string == " " || string == "."{
                return false
            }
            ///Check the specific textField
            let textArray = str.components(separatedBy: ".")
            if textArray.count > 2 { //Allow only one "."
                return false
            }
            if textArray.count == 2 {
                let lastString = textArray.last
                if lastString!.count > 2 { //Check number of decimal places
                    return false
                }
            }
            
        } else if textField.tag == 1 { // message field
            if str.length > 100  {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            amount = textField.text?.trimWhiteSpace as! String
        }
    }
    
}


extension DonateMoneyViewController {
    func donateMoneyToUser(){
        
        var param = [String: Any]()
        param["receiver_id"] = userId
        param["donation_amount"] = self.amount
        param["message"] = messageTextField.text?.trimWhiteSpace.base64Encoded()
        
        WebServices.donateMoneyToUser(params: param) { (response) in
            if response?.statusCode == 200 {
                self.getWalletBalance()
                if let vc = UIStoryboard.wallet.get(SendingMoneyViewController.self) {
                    vc.transferType = .donate
                    vc.amount = self.amount
                    vc.userName = self.userName ?? ""
                    vc.userImage = self.userImage ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func getWalletBalance(){
        WebServices.getAccountBalance { (response) in
            if let object = response?.object {
                let auth = AuthManager.shared.loggedInUser
                auth?.user_balance = object.user_balance
                AuthManager.shared.loggedInUser = auth
            }
        }
    }
}
