//
//  ResetPasswordViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 05/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var placeholderArray = ["Password","Confirm Password"]
    var user = User()
    
    // MARK: - UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Helper Method
    func customSetup(){
        
    }
    
    func validateField()  -> Bool {
        var isValid  = false
        if (user.password)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyPassword.rawValue)
            isValid =  false
        }else if !(user.password?.isValidPassword ?? false){
             AlertController.alert(message: ValidationMessage.kMessage.rawValue)
             isValid =  false
//        } else if (user.password?.count ?? 0 < 8) {
//            AlertController.alert(message: ValidationMessage.InvalidPassword.rawValue)
//            isValid =  false
        } else if (user.confirm_password)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyConfirmPassword.rawValue)
            isValid =  false
        } else if (user.confirm_password?.count ?? 0 < 8) {
            AlertController.alert(message: ValidationMessage.InvalidConfirmPassword.rawValue)
            isValid =  false
        }else  {
            user.errorMessage  = ""
            user.errorIndex  = -1
            isValid =  true
        }
        return isValid
        
    }
    
}

extension ResetPasswordViewController {
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if validateField() {
            // TODO
            self.callApiForResetPassword()
        }
        self.tableView.reloadData()
    }
    
}

extension ResetPasswordViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell", for: indexPath) as! AuthTableViewCell
        cell.commonTextField.delegate = self
        cell.commonTextField.placeholder  = placeholderArray[indexPath.row]
        cell.commonTextField.tag = indexPath.row
        if user.errorIndex == indexPath.row {
            cell.commonTextField.errorMessage = user.errorMessage
        }else {
            cell.commonTextField.errorMessage = ""
        }
        
        switch indexPath.row {
        case 0:
            cell.commonTextField.setTexFieldProperty(keyboardType: .default, returnType: .next, autoCaptalise: .none, isSecure: true)
            cell.commonTextField.text = user.password
        default:
            cell.commonTextField.setTexFieldProperty(keyboardType: .default, returnType: .done, autoCaptalise: .none, isSecure: true)
            cell.commonTextField.text = user.confirm_password
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}


extension ResetPasswordViewController: UITextFieldDelegate {
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
        
        if textField.tag == 0 { // email field
            if str.length > 16 || string == " " {
                return false
            }
        } else if textField.tag == 1 { // password field
            if str.length > 16 || string == " " {
                return false
            }
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            user.password = textField.text?.trimWhiteSpace
        default:
            user.confirm_password = textField.text?.trimWhiteSpace
        }
    }
    
}


extension ResetPasswordViewController {
    func callApiForResetPassword() {
        var params = [String: Any]()
        params["password"] = user.password?.trimWhiteSpace
        params["confirm_password"] = user.confirm_password?.trimWhiteSpace
        params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        WebServices.reset_password(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    AlertController.alert(title: "Success!!!", message: "\(response.message ?? "")", buttons: ["OK"]) { (alert, index) in
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: LoginViewController.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                }
            }
        })
    }
}
