//
//  AddAccountViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Stripe

class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    
    var placeholderArray =  [Constants.kBankName,Constants.kAccountNumber,Constants.kAccountHolderName,Constants.kRoutingNumber,Constants.kSwiftCode]
    var transferType: TransferType = .bank
    var addCompletion : ((String) -> Void)? = nil
    var isFromEdit = false
    var bank = Bank()
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selectLabel.text = isFromEdit ? Constants.kUpdateAccount : Constants.kAddAccount
        proceedButton.setTitle(isFromEdit ? Constants.kUpdate : Constants.kProceed, for: .normal)
    }
    
    //MARK:- Helper Methodœ
    
    func validateField()  -> Bool {
        var isValid  = false
        if (bank.bank_name)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyBankName.rawValue)
            isValid =  false
        }else if !(bank.bank_name?.isValidName ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidBankName.rawValue)
        }else if (bank.account_number)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyAccountNumber.rawValue)
            isValid =  false
        }else if !(bank.account_number?.containsNumberOnly() ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidAccountNumber.rawValue)
        } else if (bank.account_number?.count ?? 0 < 8) {
            AlertController.alert(message: ValidationMessage.InvalidAccountNumber.rawValue)
        }else if (bank.account_holder_name)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyName.rawValue)
        }else if !(bank.account_holder_name?.isValidName ?? false) {
            AlertController.alert(message: ValidationMessage.InvalidName.rawValue)
        }else if (bank.account_holder_name)?.length ?? 0 < 2  {
            AlertController.alert(message: ValidationMessage.InvalidName.rawValue)
        }else if (bank.routing_number)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyRoutingNumber.rawValue)
            isValid =  false
        }
        else {
            isValid =  true
        }
        return isValid
        
    }
    
    //MARK:- UIButton Method
    @IBAction func proceedButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if validateField() {
            if isFromEdit {
                updateBank()
            }else {
                addBank()
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
}

extension AddAccountViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell", for: indexPath) as! AuthTableViewCell
        cell.commonTextField.delegate = self
        cell.commonTextField.placeholder  = placeholderArray[indexPath.row]
        cell.commonTextField.tag = indexPath.row
        
        switch indexPath.row {
        case 0:
            cell.commonTextField.setTexFieldProperty(keyboardType: .asciiCapable, returnType: .next, autoCaptalise: .none, isSecure: false)
            cell.commonTextField.text = bank.bank_name
        case 1:
            cell.commonTextField.setTexFieldProperty(keyboardType: .numberPad, returnType: .next, autoCaptalise: .none, isSecure: false)
            cell.commonTextField.text = bank.account_number
        case 2:
            cell.commonTextField.setTexFieldProperty(keyboardType: .asciiCapable, returnType: .next, autoCaptalise: .none, isSecure: false)
            cell.commonTextField.text = bank.account_holder_name
        case 3:
            cell.commonTextField.setTexFieldProperty(keyboardType: .numberPad, returnType: .next, autoCaptalise: .none, isSecure: false)
            cell.commonTextField.text = bank.routing_number
        default:
            cell.commonTextField.setTexFieldProperty(keyboardType: .asciiCapable, returnType: .done, autoCaptalise: .words, isSecure: false)
            cell.commonTextField.text = bank.swift_code
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}


extension AddAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 0 { // bank name  field
            if str.length > 100  {
                return false
            }
        }else if textField.tag == 1 { // account number field
            if str.length > 16 || string == " " {
                return false
            }
        }else if textField.tag == 2 { // account holder name field
            if str.length > 100 {
                return false
            }
        } else if textField.tag == 3 { // routing field
            if str.length > 11 || string == " " {
                return false
            }
        }
        else if textField.tag == 4 { // swift field
            if str.length > 11 || string == " " {
                return false
            }
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            bank.bank_name = textField.text?.trimWhiteSpace
        case 1:
            bank.account_number = textField.text?.trimWhiteSpace
        case 2:
            bank.account_holder_name = textField.text?.trimWhiteSpace
        case 3:
            bank.routing_number = textField.text?.trimWhiteSpace
        default:
            bank.swift_code = textField.text?.trimWhiteSpace
        }
    }
    
}


extension AddAccountViewController {
    
    func addBank(){
        var param = [String: Any]()
        param["bank_business_name"] = bank.bank_name
        param["account_holder_name"] = bank.account_holder_name
        param["account_number"] = bank.account_number
        param["routing_number"] = bank.routing_number
        param["swift_code"] = bank.swift_code
        
        WebServices.addBankAccount(params: param) { (response) in
            if response?.statusCode == 200 {
                AlertController.alert(title: "", message: "\(response?.message ?? "")", buttons: ["OK"]) { (alert, index) in
                    self.addCompletion?(response?.object?.user_bank_details_id ?? "")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    func updateBank(){
        var param = [String: Any]()
        param["bank_business_name"] = bank.bank_name
        param["account_holder_name"] = bank.account_holder_name
        param["account_number"] = bank.account_number
        param["routing_number"] = bank.routing_number
        param["swift_code"] = bank.swift_code
        param["user_bank_details_id"] = bank.user_bank_details_id
        
        WebServices.updateBankAccount(params: param) { (response) in
            if response?.statusCode == 200 {
                AlertController.alert(title: "", message: "\(response?.message ?? "")", buttons: ["OK"]) { (alert, index) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    
}




