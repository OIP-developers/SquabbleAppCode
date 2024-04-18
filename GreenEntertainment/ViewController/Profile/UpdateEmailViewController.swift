//
//  UpdateEmailViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 26/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class UpdateEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    
    var user = User()
    var emailCompletion:((Bool, String) -> Void)? = nil
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = user.email
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func validateField()  -> Bool {
        var isValid  = false
        if (user.email)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyEmail.rawValue)
            isValid =  false
        } else if !(user.email?.isEmail ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidEmail.rawValue)
            isValid =  false
        } else  {
            isValid =  true
        }
        return isValid
        
    }
    
    //MARK:- UIButton Method
    @IBAction func crossButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        emailCompletion?(false, emailTextField.text?.trimWhiteSpace ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if validateField(){
            updateEmail()
        }
    }
}

extension UpdateEmailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        user.email = textField.text?.trimWhiteSpace
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if str.length > 256 || string == " " {
            return false
        }
        return true
    }
}


extension UpdateEmailViewController {
    func updateEmail(){
        
        var param = [String: Any]()
        param["email_address"] =  user.email
        WebServices.updateExistingEmail(params: param) { (response) in
            if response?.statusCode == 200 {
                if self.user.email == AuthManager.shared.loggedInUser?.email {
                    self.emailCompletion?(false, self.emailTextField.text?.trimWhiteSpace ?? "")
                    self.dismiss(animated: false, completion: nil)
                }else  {
                    self.emailCompletion?(true, self.emailTextField.text?.trimWhiteSpace ?? "")
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
}
