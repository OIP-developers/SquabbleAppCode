//
//  PurchaseGiftsViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 22/04/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit

class PurchaseGiftsViewController: UIViewController {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tokenBalanceLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var giftPurchaseLabel: UILabel!

    var transferType: TransferType = .bank
    var amount : String = ""
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let balance = Int(AuthManager.shared.loggedInUser?.user_balance ?? 0)
        self.tokenBalanceLabel.text = "\(balance)"
        tokenLabel.text = "1 Token = 1 Gift"
        amountLabel.attributedText = getTextWithGiftImage(startString: "", price: "Total Tokens Used: ",lastString: " 10",imageAddtionalSize: -30, imageName: "ic_donate_token")
        amountTextField.addTarget(self, action: #selector(textFieldChange(_ :)), for: .editingChanged)
    }
    
    @objc func textFieldChange(_ textField: UITextField){
        let price = (Int(textField.text ?? "0") ?? 0)
        amountLabel.attributedText = getTextWithGiftImage(startString: "", price: "Total Tokens Used: ",lastString: " \(price)",imageAddtionalSize: -30, imageName: "ic_donate_token")
    }
    
    //MARK:- UIButton Action Method
    
    @IBAction func proceedButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        amount = (amountTextField.text?.trimWhiteSpace ?? "") as String
        if amount.last == "." {
            amount = String(amount.dropLast())
        }
        if amountTextField.text?.isEmpty ?? false {
            AlertController.alert(message: ValidationMessage.EmptyAmount.rawValue)
        }else if let transferAmount = Double(amount){
            if transferAmount < 1 {
                AlertController.alert(message: ValidationMessage.MinimumAmount.rawValue)
            }else if !(amountTextField.text?.containsNumberOnly() ?? false){
                AlertController.alert(message: ValidationMessage.ValidAmount.rawValue)
            }else  {
                if let totalAmount = AuthManager.shared.loggedInUser?.user_balance {
                    if totalAmount >= transferAmount {
                        // Call API
                        addGiftsToWallet()
                    }else {
                        if let vc = UIStoryboard.wallet.get(InsufficientPopupViewController.self){
                            vc.modalPresentationStyle = .custom
                            vc.modalTransitionStyle = .crossDissolve
                            vc.completion = {
                                if let vc = UIStoryboard.wallet.get(AddTokenViewController.self) {
                                 //   vc.transferType = .wallet
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                            navigationController?.present(vc, animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }else if !amount.containsNumberWithOneDecimalOnly() {
            AlertController.alert(message: ValidationMessage.ValidAmount.rawValue)
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
}

extension PurchaseGiftsViewController: UITextFieldDelegate  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 0 { // amount field
            if str.length > 8 || string == " " || string == "." {
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
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        amount = textField.text?.trimWhiteSpace as! String
    }
}

extension PurchaseGiftsViewController {
    func addGiftsToWallet(){
        var param = [String: Any]()
        param["amount"] = "\(amount)"
        
        WebServices.addGiftToWallet(params: param, loader : true) { (response) in
            if let vc = UIStoryboard.wallet.get(SendingMoneyViewController.self) {
                vc.transferType = self.transferType
                vc.amount = self.amount
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


