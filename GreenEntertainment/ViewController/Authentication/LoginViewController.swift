//
//  LoginViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var placeholderArray = ["Email","Password"]
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
        if (user.email)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyEmail.rawValue)
            isValid =  false
        } else if !(user.email?.isEmail ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidEmail.rawValue)
            isValid =  false
        } else if (user.password)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyPassword.rawValue)
            isValid =  false
        } else if (user.password?.count ?? 0 < 2) {
            AlertController.alert(message: ValidationMessage.InvalidPasswordEnter.rawValue)
            isValid =  false
        }else  {
            user.errorMessage  = ""
            user.errorIndex  = -1
            isValid =  true
        }
        return isValid
        
    }
    
    func validateFieldForForget()  -> Bool {
        var isValid  = false
        if (user.email)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyEmail.rawValue)
            isValid =  false
        } else if !(user.email?.isEmail ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidEmail.rawValue)
            isValid =  false
        } else  {
            user.errorMessage  = ""
            user.errorIndex  = -1
            isValid =  true
        }
        return isValid
        
    }
    
}

extension LoginViewController {
    @IBAction func skipButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        UserDefaults.standard.set(false, forKey: "loggedInUser")
        
        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
        
//        if let vc = UIStoryboard.challenge.get(ChallengeListViewController.self) {
//            let navigationController = UINavigationController(rootViewController: vc)
//            navigationController.navigationBar.isHidden = true
//            APPDELEGATE.navigationController = navigationController
//            APPDELEGATE.window?.rootViewController = navigationController
//        }
    }
    
    @IBAction func signInButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if validateField() {
            // TODO
            signUserIn(email: (user.email!), pass: (user.password!))
        }
    }
    
    @IBAction func forgotPasswordButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if validateFieldForForget() {
            Auth.auth().sendPasswordReset(withEmail: user.email ?? "") { error in
                // Your code here
                Logs.show(message: error?.localizedDescription ?? "")
                if let err = error {
                    AlertController.alert(message: error?.localizedDescription ?? "")
                    return
                }
                AlertController.alert(message: "An Email is sent to given Email address, navigate the link to reset password")
            }
            //callApiForForgotPassword()
        }
    }
    
    @IBAction func signupButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
//        if let vc = UIStoryboard.auth.get(CameraViewController.self) {
//            navigationController?.pushViewController(vc, animated: true)
//        }
        
        if let vc = UIStoryboard.auth.get(SignupViewController.self) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension LoginViewController: UITableViewDelegate,UITableViewDataSource {
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
            cell.commonTextField.setTexFieldProperty(keyboardType: .emailAddress, returnType: .next, autoCaptalise: .none, isSecure: false)
            cell.commonTextField.text = user.email
        default:
            cell.commonTextField.setTexFieldProperty(keyboardType: .default, returnType: .done, autoCaptalise: .none, isSecure: true)
            cell.commonTextField.text = user.password
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}


extension LoginViewController: UITextFieldDelegate {
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
            if str.length > 256 || string == " " {
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
            user.email = textField.text?.trimWhiteSpace
        default:
            user.password = textField.text?.trimWhiteSpace
        }
    }
    
}

extension LoginViewController {
    func callApiForLogin() {
        
        ProgressHud.showActivityLoader()
        
        var params = [String: Any]()
        params["email_address"] = user.email
        params["password"] = user.password
        params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        Auth.auth().signIn(withEmail: user.email ?? "", password: user.password ?? "") { [weak self] authResult, error in
            //            guard let strongSelf = self else { return }
            // ...
            if error != nil {
                // UI: Alert Controller
                print(" ‼️ Please check you email or password & try again: \(String(describing: error?.localizedDescription))")
                AppFunctions.showSnackBar(str: "‼️ Please check you email or password & try again: \(error?.localizedDescription ?? "")")
                ProgressHud.hideActivityLoader()
                return
            }
            // login user Data object
            print("Login Auth Result:  \(String(describing: authResult))")

            UserDefaults.standard.set(true, forKey: "loggedInUser")
            self?.getMyProfile()
        }
            //ProgressHud.hideActivityLoader()

            // perform seague to dashboard or camera via TobbarViewController

        
    }
    
    func signUserIn(email:String, pass: String) {
        
        let pram : [String : Any] = ["email": email,
                                     "password" :pass]
        
        Logs.show(message: "SKILLS PRAM: \(pram) ")
        
        APIService
            .singelton
            .userSignIn(Pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.callApiForLogin()
                        } else {
                            print("‼️ Sign In error: \(val)")
                            AppFunctions.showSnackBar(str: "‼️ Sign In error: \(val)")
                            ProgressHud.hideActivityLoader()
                        }
                    case .error(let error):
                        print("‼️ Sign In error: \(error)")
                        AppFunctions.showSnackBar(str: "‼️ Sign In error: \(error)")
                        ProgressHud.hideActivityLoader()

                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func getMyProfile() {
        Logs.show(message: "Saved Vids :::: ")
        
        APIService
            .singelton
            .getMyProfile()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            Logs.show(message: "\(val.id ?? "")")
                            AppFunctions.saveUserID(id: val.id ?? "")
                            UserDefaults.standard.set(val.id ?? "", forKey: "loggedInUserUID")
                            if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                                let navigationController = UINavigationController(rootViewController: vc)
                                navigationController.navigationBar.isHidden = true
                                APPDELEGATE.navigationController = navigationController
                                APPDELEGATE.window?.rootViewController = navigationController
                            }
                        } else {
                            ProgressHud.hideActivityLoader()
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func callApiForForgotPassword() {
        var params = [String: Any]()
        params["email_address"] = user.email //AuthManager.shared.loggedInUser?.email
        params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        WebServices.forget_password(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let user = response.object {
                        if let vc = UIStoryboard.auth.get(ForgotPasswordViewController.self) {
                            vc.userObj = user
                            vc.screenType = .forgotPassword
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        })
    }
}

