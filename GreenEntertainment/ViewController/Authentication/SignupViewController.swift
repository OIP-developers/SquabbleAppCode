//
//  SignupViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 09/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import AVFoundation
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var termsAcceptButton: UIButton!
    
    var usernameValidated = false
    var emailValidated = false
    var mobile_numberValidated = false
    var zip_codeValidated = false
    var passwordValidated = false
    var confirm_passwordValidated = false
    var country_codeValidated = false
    
    var user = User()
    var flagImage = UIImage()
    var firebaseUser : [String:String] = [String:String]()
    var userProfile = UserProfile()
    var placeholderList = ["Username","Email","","Zip Code","Password","Confirm Password"]
    var image = UIImage()
    var file: AttachmentInfo?
    
    // MARK: - UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
        
    }
    
    // MARK: - Helper Method
    func customSetup(){
        setAttributedTermsAndCondition()
        user.mobile_number_country_code = "+1"
        user.countryFlag = UIImage.init(named: "us")
        self.file = AttachmentInfo(withImage: image , imageName: "profile_pic")
    }
    
    /*\func validateField()  -> Bool {
        var isValid  = false
        if (user.username)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyUsername.rawValue)
            isValid =  false
        }else if (user.username?.count ?? 0 < 2) {
            AlertController.alert(message: ValidationMessage.InvalidUsername.rawValue)
            isValid =  false
        }else if !(user.username?.isValidUserName ?? false) {
            AlertController.alert(message: ValidationMessage.InvalidUsername.rawValue)
            isValid =  false
        }else if (user.email)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyEmail.rawValue)
            isValid =  false
        } else if !(user.email?.isEmail ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidEmail.rawValue)
            isValid =  false
        }else if (user.phone_number)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyPhoneNumber.rawValue)
            isValid =  false
        }
        else if !(user.mobile_number_country_code?.isEmpty ?? false) {
            if user.mobile_number_country_code?.trimWhiteSpace == "+1" {
                if !((user.phone_number)?.isValidMobile(testStr: (user.phone_number ?? "")) ?? false) {
                    AlertController.alert(message: ValidationMessage.ValidPhoneNumber.rawValue)
                    isValid =  false
                }
            }else {
                if !((user.phone_number)?.isValidMobileNumber() ?? false) {
                    AlertController.alert(message: ValidationMessage.ValidPhoneNumber.rawValue)
                    isValid =  false
                }
            }
            if (user.password)?.isEmpty ?? true  {
                AlertController.alert(message: ValidationMessage.EmptyPassword.rawValue)
                isValid =  false
            }else if !(user.password?.isValidPassword ?? false){
               AlertController.alert(message: ValidationMessage.kMessage.rawValue)
                isValid =  false
//            }else if (user.password?.count ?? 0 < 8) {
//                AlertController.alert(message: ValidationMessage.InvalidPassword.rawValue)
//                isValid =  false
            }else if (user.confirm_password)?.isEmpty ?? true  {
                AlertController.alert(message: ValidationMessage.EmptyConfirmPassword.rawValue)
                isValid =  false
            } else if (user.confirm_password?.count ?? 0 < 8) {
                AlertController.alert(message: ValidationMessage.InvalidConfirmPassword.rawValue)
                isValid =  false
            }else if (user.confirm_password) != user.password {
                AlertController.alert(message: ValidationMessage.InvalidConfirmPassword.rawValue)
                isValid =  false
            }else if !(user.isAgreeToTnC ?? false){
                AlertController.alert(message: ValidationMessage.AcceptTermsAndCondition.rawValue)
                isValid =  false
            }else  {
                user.errorMessage  = ""
                user.errorIndex  = -1
                isValid =  true
            }
        }
        else if (user.phone_number?.count ?? 0 < 8) {
            AlertController.alert(message: ValidationMessage.ValidPhoneNumber.rawValue)
            isValid =  false
        }
        else if (user.password)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyPassword.rawValue)
            isValid =  false
        } else if (user.password?.count ?? 0 < 8) {
            AlertController.alert(message: ValidationMessage.InvalidPassword.rawValue)
            isValid =  false
        }else if (user.confirm_password)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyConfirmPassword.rawValue)
            isValid =  false
        } else if (user.confirm_password?.count ?? 0 < 8) {
            AlertController.alert(message: ValidationMessage.InvalidConfirmPassword.rawValue)
            isValid =  false
        }else if !(user.isAgreeToTnC ?? false){
            AlertController.alert(message: ValidationMessage.AcceptTermsAndCondition.rawValue)
            isValid =  false
        }else  {
            user.errorMessage  = ""
            user.errorIndex  = -1
            isValid =  true
        }
        return isValid
        
    }*/
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        

        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
        
    }
}

extension SignupViewController {
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
//        if validateField() {
//            // TODO
//            callApiForRegistration()
//        }
//        self.tableView.reloadData()
                
        if !usernameValidated || !emailValidated || !mobile_numberValidated || !zip_codeValidated || !passwordValidated || !confirm_passwordValidated || !country_codeValidated {
            AlertController.alert(title: "", message: "Fill up right information")
            return
        }
        callApiForRegistration()
    }
    
    @IBAction func signInButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if let vc = UIStoryboard.auth.get(LoginViewController.self) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func acceptButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        user.isAgreeToTnC = !(user.isAgreeToTnC ?? false)
        sender.isSelected = !sender.isSelected
    }
}

extension SignupViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MobileTableViewCell") as! MobileTableViewCell
                cell.mobileTextField.delegate = self
                cell.mobileTextField.tag = indexPath.row
                cell.mobileTextField.placeholder = "Mobile Number"
                cell.mobileTextField.text = firebaseUser["mobile_number"]
                cell.codeLabel.text = firebaseUser["country_code"]
                cell.flagImageView.image = flagImage
                cell.codeCompletion =  {
                    self.openCountryPicker()
                }
                cell.mobileTextField.addTarget(self, action: #selector(editChangeTextField(_ :)), for: .editingChanged)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell", for: indexPath) as! AuthTableViewCell
                cell.commonTextField.delegate = self
                cell.commonTextField.tag = indexPath.row
                cell.commonTextField.placeholder = placeholderList[indexPath.row]
                
                switch indexPath.row {
                    case 0:
                        cell.commonTextField.setTexFieldProperty(keyboardType: .default, returnType: .next, autoCaptalise: .none, isSecure: false)
                        cell.commonTextField.text = firebaseUser["username"]
                    case 1:
                        cell.commonTextField.setTexFieldProperty(keyboardType: .emailAddress, returnType: .next, autoCaptalise: .none, isSecure: false)
                        cell.commonTextField.text = firebaseUser["email"]
                    case 3:
                        cell.commonTextField.setTexFieldProperty(keyboardType: .numberPad, returnType: .next, autoCaptalise: .none, isSecure: false)
                        cell.commonTextField.text = firebaseUser["zip_code"]
                    case 4:
                        cell.commonTextField.setTexFieldProperty(keyboardType: .default, returnType: .next, autoCaptalise: .none, isSecure: true)
                        cell.commonTextField.text = firebaseUser["password"]
                    case 5:
                        cell.commonTextField.setTexFieldProperty(keyboardType: .default, returnType: .next, autoCaptalise: .none, isSecure: true)
                        cell.commonTextField.text = firebaseUser["confirm_password"]
                    default:
                        print("")
                }
                
                return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}


extension SignupViewController: UITextFieldDelegate {
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
        //Logs.show(message: "TF STRING: \(string)")

       // let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"

        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 0 { // username field
//            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
//            let filtered = string.components(separatedBy: cs).joined(separator: "")
//            if str.length > 20 || string == " " {
//                return false
//            } else {
//                return (string == filtered)
//            }
           
            if str.length > 20 || string == " " {
                return false
            }
           
        }else if textField.tag == 1 { // email field
            if str.length > 256 || string == " " {
                return false
            }
        }else if textField.tag == 2  { // mobile field
            
            if str.length > 15 || string == " " {
                return false
            }
            
            
        }
        else if textField.tag == 3  { // zip field
            if str.length > 6 || string == " " {
                return false
            }
        }else if textField.tag == 4  { // password field
            if str.length > 16 || string == " " {
                return false
            }
        }
        else if textField.tag == 5  { // confirm password field
            
            if str.length > 16 || string == " " {
                return false
            }
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
                textField.text!.trimWhiteSpace.isValidUserName ? firebaseUser["username"] = textField.text?.trimWhiteSpace : print("Epmty UserName") // username
                if firebaseUser["username"] != "" {
                    usernameValidated = true
                }
        case 1:
                textField.text!.trimWhiteSpace.isValidEmail ? firebaseUser["email"] = textField.text?.trimWhiteSpace : print("Epmty email") //email
                if firebaseUser["email"] != "" {
                    emailValidated = true
                }
        case 2:
                textField.text!.replace(string: "-", replacement: "").isValidMobileNumber() ? firebaseUser["mobile_number"] = textField.text?.trimWhiteSpace : print("Epmty mobile_number") //phoneNum
                if firebaseUser["mobile_number"] != "" {
                    mobile_numberValidated = true
                }
        case 3:
                !textField.text!.trimWhiteSpace.isTFBlank ? firebaseUser["zip_code"] = textField.text?.trimWhiteSpace : print("Epmty zip_code") //zipcode
                if firebaseUser["zip_code"] != "" {
                    zip_codeValidated = true
                }
        case 4:
                !textField.text!.trimWhiteSpace.isTFBlank ? firebaseUser["password"] = textField.text?.trimWhiteSpace : print("Epmty password") //password
                if firebaseUser["password"] != "" {
                    passwordValidated = true
                }
        case 5:
                !textField.text!.trimWhiteSpace.isTFBlank && textField.text!.trimWhiteSpace == firebaseUser["password"] ? firebaseUser["confirm_password"] = textField.text?.trimWhiteSpace : print("Epmty confirm_password") //confirm_password
                if firebaseUser["confirm_password"] != "" {
                    confirm_passwordValidated = true
                }
        default:
            break
        }
    }
    
}


extension SignupViewController {
    fileprivate func setAttributedTermsAndCondition() {
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        self.termsLabel.addGestureRecognizer(tapGesture)
        self.termsLabel.isUserInteractionEnabled = true
        
        let string = Constants.kAgreeTermsAndConditions
        let termsString = Constants.kTermsAndCondition
        let attributedString = NSMutableAttributedString(string: string)
        let firstAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: Fonts.Rubik.regular.font(.large)]
        let secondAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: Fonts.Rubik.regular.font(.large)]
        attributedString.addAttributes(firstAttributes, range: NSRange(location: 0, length: string.count-1))
        
        let range = attributedString.mutableString.range(of: termsString)
        if (range.location != NSNotFound && range.location + range.length <= attributedString.length) {
            // It's safe to use range on str
            attributedString.addAttributes(secondAttributes, range: range)
        }
        
        DispatchQueue.main.async {
            self.termsLabel.attributedText = attributedString
        }
        
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        
        /*if let vc = UIStoryboard.auth.get(StaticContentViewController.self){
            vc.screentype = .termsAndCondition
            vc.isFromSetting = true
            navigationController?.pushViewController(vc, animated: true)
        }*/
        
        guard let range = self.termsLabel.text?.range(of: Constants.kTermsAndCondition)?.nsRange else {
            return
        }
        if tap.didTapAttributedTextInLabel(label: self.termsLabel, inRange: range) {
            // Substring tapped
            if let vc = UIStoryboard.auth.get(StaticContentViewController.self){
                vc.agreeCompletion = { status in
                    if status {
                        self.user.isAgreeToTnC = true
                        self.termsAcceptButton.isSelected = true
                    }
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func openCountryPicker() {
        let storyboard = UIStoryboard(name: "Country", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CountryPickerViewController") as! CountryPickerViewController
        controller.completion = { [weak self] dict in
            self?.firebaseUser["country_code"] = "\(dict["dial_code"] ?? "")"
            self?.flagImage = UIImage(named: "\((dict["code"] ?? "").lowercased()).png")!
            
            if self?.firebaseUser["country_code"] != "" {
                self?.country_codeValidated = true
            }
            
            self?.user.mobile_number_country_code = " \(dict["dial_code"] ?? "")  "
            self?.user.countryFlag = UIImage(named: "\((dict["code"] ?? "").lowercased()).png")
            self?.user.phone_number = ""
            self?.tableView.reloadData()
        }
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
}


extension SignupViewController {
    
    func callApiForRegistration(){
        var params = [String: Any]()
        
        //params["device_type"] = "2"
        //params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        //params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        
        ProgressHud.showActivityLoader()
        
        params["email_address"] = firebaseUser["email"]
        params["username"] = firebaseUser["username"]
        params["password"] = firebaseUser["password"]
        params["mobile_number"] = "\(firebaseUser["country_code"] ?? "") \(firebaseUser["mobile_number"]?.replace(string: "-", replacement: "") ?? "")"
        params["zip_code"] = firebaseUser["zip_code"]

        params["social_fb"] = ""
        params["social_insta"] = ""
        params["social_x"] = ""
        params["social_tiktk"] = ""

        Logs.show(message: "PARAMS: \(params)")
        var imageData = self.file ?? AttachmentInfo()
        imageData.apiKey = Constants.kImage_URL
        // Athenticate Firebase here 📌
        Auth.auth().createUser(withEmail: firebaseUser["email"] ?? "", password: firebaseUser["password"] ?? "") { results , error  in
            // if signUp successfully get user UID and save user profile in Database
            if error != nil {
                print("Error ‼️", error?.localizedDescription as Any)
                AppFunctions.showSnackBar(str: "\(error?.localizedDescription ?? "")")
                ProgressHud.hideActivityLoader()
            }
            guard let profile = results else { return }
            params["uid"] = profile.user.uid
            
            
            print("Account created successfully ✅. User ID:", profile.user.uid)
            let seconds = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                APIService.singelton.userSignUp(id: profile.user.uid)
                AppFunctions.showSnackBar(str: "Account Created Successfully")
                ProgressHud.hideActivityLoader()
                self.navigationController?.popViewController(animated: true)
            }
            let userDB = Database.database().reference()
            let UsersReference = userDB.child("Users").child(profile.user.uid)
            UsersReference.setValue(params) { err , snapshot in
                if err != nil {
                    Logs.show(message: "ERRR: \(err?.localizedDescription ?? "")")
                    AppFunctions.showSnackBar(str: "\(error?.localizedDescription ?? ""))")
                    ProgressHud.hideActivityLoader()
                }
                Logs.show(message: "SNAP: \(snapshot)")
            }
            
//            let createdUserID = profile.user.uid // add uid to params veriable
//            let createdUserEmail = profile.user.email
//            params["userI_id", ] 
            
            // sending userProfile data to Database after signUP.
            // save(userData: params)
            //\let userDatabase = Firestore.firestore()
            /*\userDatabase.collection("Users").addDocument(data: ["email": "greenEnt@squabble.com", "uid": "34567897865"]) { err  in
                if err != nil {
                    print(err?.localizedDescription, "📌")
                }
                // Segue to profile page or homeDashboard.
            }*/
     
        }
        
        // Old networking signUP.
//        WebServices.signup(params: params, files: [imageData]) { (resposne) in
//            if resposne?.statusCode == 200 {
//            if let obj = resposne?.object  {
//                print("====objcheck",obj)
//                AuthManager.shared.loggedInUser = obj
//                if let vc  = UIStoryboard.auth.get(ForgotPasswordViewController.self){
//                    vc.screenType = .verification
//                    vc.image = self.image
//                    vc.userObj = self.user
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//            }else if resposne?.statusCode == 0{
//                AlertController.alert(title: "", message: resposne?.message ?? "")
//            }
//
//        }
        
    }
    
    private func save(userData profile: [String:Any]) {
        // save user profile to firebase
        
    }
//
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || (length == 10 && !hasLeadingOne) || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    
    @objc func editChangeTextField(_ textField: UITextField){
        if textField.tag == 2 && user.mobile_number_country_code?.trimWhiteSpace == "+1"{
            textField.text =  self.formatPhone(textField.text ?? "")
        }
    }
    
    func formatPhone(_ number: String) -> String {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let format: [Character] = ["X", "X", "X", "-", "X", "X", "X", "-", "X", "X", "X", "X"]
        
        var result = ""
        var index = cleanNumber.startIndex
        for ch in format {
            if index == cleanNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
}

extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}
