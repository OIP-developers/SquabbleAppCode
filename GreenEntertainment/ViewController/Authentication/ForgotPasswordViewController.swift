//
//  ForgotPasswordViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 05/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var textSix: UITextField!
    @IBOutlet weak var textFive: UITextField!
    @IBOutlet weak var textFirst: UITextField!
    @IBOutlet weak var textSecond: UITextField!
    @IBOutlet weak var textThird: UITextField!
    @IBOutlet weak var textFourth: UITextField!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!
    var userObj = User()
    var image = UIImage()
    var otpCompletion: ((Bool, String) -> Void)? = nil
    var otpStr = ""
    var screenType: OTPScreenType = .forgotPassword
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func moveToScreen(){
        if screenType == .verification {
            UserDefaults.standard.set(true, forKey: "loggedInUser")
            UserDefaults.standard.synchronize()
            if let vc  = UIStoryboard.main.get(SignupCompleteViewController.self){
                vc.image = image
                navigationController?.pushViewController(vc, animated: true)
            }
        }else if screenType == .updateEmail {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: EditProfileViewController.self) {
                    self.otpCompletion?(true, userObj.email ?? "")
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }else {
            if let vc  = UIStoryboard.auth.get(ResetPasswordViewController.self){
                vc.user = userObj
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
extension ForgotPasswordViewController {
    fileprivate func customSetup(){
        switch screenType {
        case .forgotPassword:
            headerLabel.text = Constants.kForgotPassword
            //subHeaderLabel.text = "Enter the otp we have just sent to your registered mobile no./ Email ID"
//            if userObj.mobile_number_country_code == "+1" {
//                subHeaderLabel.text = "Please type the verification code sent to \(userObj.mobile_number_country_code ?? "+91")-\((userObj.phone_number ?? "").toPhoneNumber()) / \(userObj.email ??  "")"
//
//            }else {
//                subHeaderLabel.text = "Please type the verification code sent to \(userObj.mobile_number_country_code ?? "+91")-xxxxxx\(String(userObj.phone_number?.suffix(4) ?? "")) / \(userObj.email ??  "")"
//            }
            
            subHeaderLabel.text = "Enter the otp we have just sent to your registered \(userObj.mobile_number_country_code ?? "")-xxxxxx\(String(userObj.phone_number?.suffix(3) ?? "")) / \(userObj.email ?? "")"

        case .verification:
            headerLabel.text = Constants.kVerificationCode
            if AuthManager.shared.loggedInUser?.mobile_number_country_code == "+1" {
                subHeaderLabel.text = "Please type the verification code sent to \(AuthManager.shared.loggedInUser?.mobile_number_country_code ?? "+91")-\((AuthManager.shared.loggedInUser?.phone_number ?? "").toPhoneNumber()) / \(AuthManager.shared.loggedInUser?.email ??  "")"
            }else {
                subHeaderLabel.text = "Please type the verification code sent to \(AuthManager.shared.loggedInUser?.mobile_number_country_code ?? "+91")-\(AuthManager.shared.loggedInUser?.phone_number ?? "") / \(AuthManager.shared.loggedInUser?.email ??  "")"
            }
            
        default:
            headerLabel.text = Constants.kVerificationCode
            if AuthManager.shared.loggedInUser?.mobile_number_country_code == "+1" {
                subHeaderLabel.text = "Please type the verification code sent to \(AuthManager.shared.loggedInUser?.mobile_number_country_code ?? "+91")-\((AuthManager.shared.loggedInUser?.phone_number ?? "").toPhoneNumber()) / \(AuthManager.shared.loggedInUser?.email ??  "")"
            }else {
                subHeaderLabel.text = "Please type the verification code sent to \(AuthManager.shared.loggedInUser?.mobile_number_country_code ?? "+91")-\(AuthManager.shared.loggedInUser?.phone_number ?? "") / \(AuthManager.shared.loggedInUser?.email ??  "")"
            }
            
        }
    }
}

extension ForgotPasswordViewController {
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        
        otpStr = textFirst.text! + textSecond.text! + textThird.text! + textFourth.text! + "\(textFive.text!)" + "\(textSix.text!)"
        
        if otpStr.length == 0  {
            AlertController.alert(title: "", message: "Please enter otp.")
        }else if otpStr.trimWhiteSpace.length < 6{
            AlertController.alert(title: "", message: "Please enter valid otp.")
        } else {
            // Call Api
            callApiForOTP()
        }
    }
    
    @IBAction func resendButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        apiforResendOtp()
    }
}


// MARK: - Delegates
extension ForgotPasswordViewController: UITextFieldDelegate {
    //MARK: - UITextFieldDelegateMethods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.count)! < 1, string.count > 0 {
            let nextTag = textField.tag + 1
            
            // get next responder
            var nextResponder =  self.view.viewWithTag(nextTag) as? UITextField
            
            if nextResponder == nil {
                nextResponder =  self.view.viewWithTag(1001) as? UITextField
            }
            textField.text = string
            nextResponder?.becomeFirstResponder()
            return false
            
        } else if (textField.text?.count)! >= 1, string.count == 0 {
            // on deleting value from Textfield
            let previousTag = textField.tag - 1
            
            // get next responder
            var previousResponder = self.view.viewWithTag(previousTag) as? UITextField
            
            if previousResponder == nil {
                previousResponder = self.view.viewWithTag(1001) as? UITextField
            }
            textField.text = " "
            previousResponder?.becomeFirstResponder()
            return false
            
        } else if (textField.text?.length)! == 1 {
            let nextTag = textField.tag + 1
            textField.text = " "
            // get next responder
            let nextResponder = self.view.viewWithTag(nextTag) as? UITextField
            textField.text = string
            nextResponder?.becomeFirstResponder()
            return false
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        otpStr = textFirst.text! + textSecond.text! + textThird.text! + textFourth.text! + "\(textFive.text!)" + "\(textSix.text!)"
    }
}

extension ForgotPasswordViewController {
    func callApiForOTP() {
        var params = [String: Any]()

        params["otp_code"] = otpStr
        params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        if screenType == .forgotPassword {
            params["email_address"] = userObj.email
        }else if screenType == .verification {
           // params["email_address"] = AuthManager.shared.loggedInUser?.email ??  ""
            params["email_address"] = userObj.email
        }else {
            params["type"] = "new_email"
            params["email_address"] = userObj.email
        }
        
        WebServices.verifyOTP(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if self.screenType == .updateEmail {
                        AuthManager.shared.loggedInUser?.email = self.userObj.email
                    }else if response.statusCode == 219{
                        AlertController.alert(title: "", message: response.message ?? "")
                }else {
                        AuthManager.shared.loggedInUser = response.object
                    }
                    self.moveToScreen()
                }
            }
        })
    }
    func apiforResendOtp() {
        var params = [String: Any]()
        params["email_address"] = "\(userObj.email ?? "")"
        params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        if screenType == .forgotPassword {
            params["email_address"] = "\(userObj.email ?? "")"
            params["type"] = "forgot"
        }else if screenType == .verification {
            //params["email_address"] =
               // AuthManager.shared.loggedInUser?.email ??  ""
            params["email_address"] =
            userObj.email ??  ""
                params["type"] = "register"
        }else {
            params["type"] = "new_email"
            params["email_address"] = userObj.email
        }
        
        WebServices.resendOTP(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    self.textFirst.text = ""
                    self.textSecond.text = ""
                    self.textThird.text = ""
                    self.textFourth.text = ""
                    self.otpStr = ""
                    AlertController.alert(title: "", message: response.message ?? "")
                } else if response.statusCode == 219 {
                    AlertController.alert(title: "", message: response.message ?? "")
                }
            }
        })
    }
}


extension ForgotPasswordViewController {
    fileprivate func getFormattedEmail()  {
        let emailArr = self.userObj.email?.split(separator: "@")
        let str = "xxxxxx\(String(emailArr?[0].suffix(4) ?? ""))"
        let totalStr = "\(str)@\(emailArr?[1] ?? "")"
        print("\(totalStr)")
   // return totalStr
    }
}
