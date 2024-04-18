//
//  SendMoneyToBankViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class SendMoneyToBankViewController: UIViewController {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenPriceLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var giftBalanceLabel: UILabel!
    @IBOutlet weak var cashInLabel: UILabel!


    var transferType: TransferType = .bank
    var amount : String = ""
    var last_four_digits = ""
    
    var obj = TokenModel()
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tokenLabel.attributedText =  getTextWithSquabbleImage(startString: "", price: "", imageAddtionalSize: 2, imageName: "ic_giftbox")
        getTokenValue()
        giftBalanceLabel.text = "\(AuthManager.shared.loggedInUser?.gift_balance ?? 0)"
      //  cashInLabel.attributedText = getTextWithSquabbleImage(startString: "", price: "Cash In Gift ",imageName: "ic_squab_white")
        amountTextField.addTarget(self, action: #selector(textFieldChange(_ :)), for: .editingChanged)
        amountTextField.setLeftPaddingPoints(5)
        amountTextField.setRightPaddingPoints(5)
    }
    
    @objc func textFieldChange(_ textField: UITextField){
        let price = (Int(textField.text ?? "0") ?? 0)
        let totalPrice = (Double(price) * (obj.dollar_value ?? 0.0))
        totalAmountLabel.text = String(format: "Cash In Total: $ %.2f", totalPrice)
       
        // totalAmountLabel.text = "Total Amount to In Cash:- $ \(totalPrice)"
    }
    
    //MARK:- UIButton Method
    @IBAction func proceedButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        amount = (amountTextField.text?.trimWhiteSpace ?? "") as String
        if amountTextField.text?.isEmpty ?? false {
            AlertController.alert(message: ValidationMessage.EmptyAmount.rawValue)
        }else if !(amountTextField.text?.containsNumberOnly() ?? false){
            AlertController.alert(message: ValidationMessage.ValidAmount.rawValue)
        }else if let transferAmount = Double(amount){
            if transferAmount < 1 {
                AlertController.alert(message: ValidationMessage.MinimumAmount.rawValue)
            }else  {
                
                if let totalAmount = AuthManager.shared.loggedInUser?.gift_balance {
                    if totalAmount < Int(transferAmount) {
//                        if let vc = UIStoryboard.wallet.get(InsufficientPopupViewController.self){
//                            vc.modalPresentationStyle = .custom
//                            vc.modalTransitionStyle = .crossDissolve
//                            vc.completion = {
//                                if let vc = UIStoryboard.wallet.get(AddTokenViewController.self) {
//                                 //   vc.transferType = .wallet
//                                    self.navigationController?.pushViewController(vc, animated: true)
//                                }
//                            }
//                            navigationController?.present(vc, animated: true, completion: nil)
//                        }
                        
                        AlertController.alert(message: "Do not have sufficient gifts.")
                        
                    }else {
                          getBankAccount()
//                        if let vc = UIStoryboard.wallet.get(SelectBankAccountViewController.self){
//                            vc.transferType = transferType
//                            vc.amount = amount
//                            navigationController?.pushViewController(vc, animated: true)
//                        }
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

extension SendMoneyToBankViewController: UITextFieldDelegate  {
    
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
    
}


extension SendMoneyToBankViewController {
    func getBankAccount(){
        WebServices.getAccountDetail{ (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let obj = response.object {
                        if let vc = UIStoryboard.wallet.get(SelectBankAccountViewController.self){
                            vc.transferType = self.transferType
                            vc.amount = self.amount
//                            vc.last_four_digits = obj.last_four_digits ?? ""
//                            vc.bank_name = obj.bank_name ?? ""
//                            vc.bank_id = obj.bank_id ?? ""
                            vc.bankInfo = obj
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    else{
                        if let vc = UIStoryboard.wallet.get(AddStripeAccountViewController.self) {
                            vc.amount = self.amount
                            vc.bankAddcompletion = {
                                if let vc = UIStoryboard.wallet.get(SelectBankAccountViewController.self) {
                                    vc.transferType = .bank
                                    vc.amount = self.amount
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    }
                }
                
            }
        }
    }
    
    func getTokenValue(){
        WebServices.getTokenWithdrawValue{ (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let obj = response.object {
                        self.obj = obj
                        let totalPrice = (Double(10) * (obj.dollar_value ?? 0.0))
                        self.totalAmountLabel.text = String(format: "Cash In Total: $ %.2f", totalPrice)
                        self.tokenPriceLabel.text = String(format: "1 Gift = $ %.2f", (obj.dollar_value ?? 0.0))
                    }
                }
            }
        }
    }
}
