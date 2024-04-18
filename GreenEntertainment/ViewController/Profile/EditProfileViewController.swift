//
//  ProfileViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 09/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Photos
import FirebaseDatabase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseStorage

class EditProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var user = User()
    var isFromEdit = false
    var image = UIImage()
    var file: AttachmentInfo?
    
    var profImage = UIImage()
    var profilePicUrl = ""
    var fName = ""
    var lName = ""
    var gender = ""
    var social_fb = ""
    var social_insta = ""
    var social_tt = ""
    var social_x = ""
    var dob = ""
    var userName = ""
    var email = ""
    var phone = ""
    var zipCode = ""
    
    var userId = ""
    
    
    
    var userProfile = [String : Any]()
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func customSetup(){
        profileImageView.layer.cornerRadius = 75
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = KAppDarkGrayColor.cgColor
        if isFromEdit{
        
            if let profilePic_Url = userProfile["profilePic_Url"] {
                profilePicUrl = profilePic_Url as! String
                if let url = URL(string: profilePicUrl ) {
                    self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
                }
            }
            if let f_name = userProfile["fNmae"] {
                fName = f_name as! String
            }
            if let l_name = userProfile["lNmae"] {
                lName = l_name as! String
            }
            if let gend_er = userProfile["gender"] {
                gender = gend_er as! String
            }
            if let do_b = userProfile["dob"] {
                dob = do_b as! String
            }
            if let username = userProfile["username"] {
                userName = username as! String
            }
            if let email_address = userProfile["email_address"] {
                email = email_address as! String
            }
            if let mobile_number = userProfile["mobile_number"] {
                phone = mobile_number as! String
            }
            if let zip_Code = userProfile["zip_code"] {
                zipCode = zip_Code as! String
            }
            
            if let social_fbp = userProfile["social_fb"] {
                social_fb = social_fbp as! String
            }
            if let social_instap = userProfile["social_insta"] {
                social_insta = social_instap as! String
            }
            if let social_ttp = userProfile["social_tiktk"] {
                social_tt = social_ttp as! String
            }
            if let social_xp = userProfile["social_x"] {
                social_x = social_xp as! String
            }
            
            tickButton.isHidden =  false
            crossButton.isHidden =  false
            saveButton.isHidden =  true
            
        } else {
            user.email = AuthManager.shared.loggedInUser?.email
            user.username = AuthManager.shared.loggedInUser?.username
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
            }
            user.zip_code = AuthManager.shared.loggedInUser?.zip_code
            user.mobile_number_country_code = AuthManager.shared.loggedInUser?.mobile_number_country_code
            user.phone_number = AuthManager.shared.loggedInUser?.phone_number
        }
    }
    
    func validateField()  -> Bool {
        var isValid  = false
        if (user.first_name)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyFirstName.rawValue)
            isValid =  false
        } else if !(user.first_name?.isValidName ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidFirstName.rawValue)
            isValid =  false
        } else if (user.last_name)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyLastName.rawValue)
            isValid =  false
        } else if !(user.last_name?.isValidName ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidLastName.rawValue)
            isValid =  false
        }else if (user.gender)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyGender.rawValue)
            isValid =  false
        }else if !((user.gender)?.containsAlphabetsOnly() ?? false)   {
            AlertController.alert(message: ValidationMessage.InvalidGender.rawValue)
            isValid =  false
        }else if (user.dobTimestamp)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyAge.rawValue)
            isValid =  false
        }else if (user.username)?.isEmpty ?? true {
            AlertController.alert(message: ValidationMessage.EmptyUsername.rawValue)
            isValid =  false
        }else if (user.username?.count ?? 0 < 2) {
            AlertController.alert(message: ValidationMessage.InvalidUsername.rawValue)
            isValid =  false
        }else if !(user.username?.isValidUserName ?? false) {
            AlertController.alert(message: ValidationMessage.InvalidUsername.rawValue)
            isValid =  false
        }
        else if (user.email)?.isEmpty ?? true  {
            AlertController.alert(message: ValidationMessage.EmptyEmail.rawValue)
            isValid =  false
        } else if !(user.email?.isEmail ?? false)  {
            AlertController.alert(message: ValidationMessage.InvalidEmail.rawValue)
            isValid =  false
        }
        else  {
            user.errorMessage  = ""
            user.errorIndex  = -1
            isValid =  true
        }
        return isValid
        
    }
    
    func updateValuesApi(){
        let values = ["first_name": fName,
                      "last_name": lName,
                      "email": email,
                      "username": userName,
                      "profile_picture": profilePicUrl,
                      "facebook": social_fb,
                      "instagram": social_insta,
                      "tiktok": social_tt,
                      "x": social_x] as [String : Any]
        
        APIService
            .singelton
            .updateUserProfile(id: userId, pram: values)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            ProgressHud.hideActivityLoader()
                            navigationController?.popViewController(animated: true)
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
    func updateValues(){
        let ref = Database.database().reference().root
        let id = Auth.auth().currentUser?.uid
        
        let values = ["fNmae": fName,
                      "lNmae": lName,
                      "email_address": email,
                      "username": userName,
                      "zip_code": zipCode,
                      "profilePic_Url": profilePicUrl,
                      "gender": gender,
                      "social_fb": social_fb,
                      "social_insta": social_insta,
                      "social_tiktk": social_tt,
                      "social_x": social_x,
                      "dob": dob] as [String : Any]
        
        Logs.show(message: "Values: \(values) ")

        
        ref.child("Users").child(id!).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if(error != nil){
                Logs.show(message: "Values Not Saved: \(String(describing: error?.localizedDescription))")
                ProgressHud.hideActivityLoader()
                return
            }
            Logs.show(message: "Values Updated... \(ref)")
            ProgressHud.hideActivityLoader()
        })
        
    }
    
    //MARK:- UIButton Method
    @IBAction func tickButtonAction(_  sender:  UIButton){
        self.view.endEditing(true)
        //if validateField(){
            if isFromEdit {
                Logs.show(message: "tickButtonAction started")
                ProgressHud.showActivityLoaderWithTxt(text: "Uploading...")

                if profImage.size.width == 0 {
                    updateValues()
                    updateValuesApi()
                } else {
                    uploadProfilePic(image: profImage)
                }
            }
        //}
    }
    
    @IBAction func crossButtonAction(_  sender:  UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveButtonAction(_  sender:  UIButton){
        self.view.endEditing(true)
        if validateField(){
            callApiForEditProfile()
        }
    }
    
    @IBAction func cameraButtonAction(_  sender:  UIButton){
        self.view.endEditing(true)
        cameraImageAction()
    }
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource  {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  section == 0 ? 6 : 4
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        default:
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.width, height: 30))
            let label = UILabel.init(frame: CGRect.init(x: 20, y: -10, width: self.tableView.frame.width, height: 30))
            view.backgroundColor = KAppBlackColor
            label.backgroundColor = KAppBlackColor
            label.text = "Add social media links"
            label.font = Fonts.Rubik.regular.font(.large)
            label.textColor = .darkGray
            view.addSubview(label)
            return view
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1 : 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NameTextFieldTableViewCell") as! NameTextFieldTableViewCell
                cell.firstTextField.delegate = self
                cell.secondTextField.delegate = self
                cell.firstTextField.placeholder = "First Name *"
                cell.firstTextField.text = fName
                cell.firstTextField.setTexFieldProperty(keyboardType: .asciiCapable, returnType: .next, autoCaptalise: .words, isSecure: false)
                cell.firstTextField.tag = 0
                cell.secondTextField.tag = 1
                cell.secondTextField.placeholder = "Last Name *"
                cell.secondTextField.text = lName
                cell.secondTextField.setTexFieldProperty(keyboardType: .asciiCapable, returnType: .next, autoCaptalise: .words, isSecure: false)
                cell.firstTextField.isUserInteractionEnabled = true
                cell.secondTextField.isUserInteractionEnabled = true
                cell.genderButton.isHidden = true
                cell.dobButton.isHidden = true
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NameTextFieldTableViewCell") as! NameTextFieldTableViewCell
                cell.firstTextField.delegate = self
                cell.secondTextField.delegate = self
                cell.firstTextField.placeholder = "Gender *"
                cell.firstTextField.text = gender
                cell.firstTextField.setTexFieldProperty(keyboardType: .asciiCapable, returnType: .next, autoCaptalise: .words, isSecure: false)
                cell.firstTextField.tag = 2
                cell.secondTextField.tag = 3
                cell.genderButton.tag = 1000
                cell.dobButton.tag = 1001
                cell.genderButton.isHidden = false
                cell.dobButton.isHidden = false
                cell.genderButton.addTarget(self, action: #selector(genderSelection(_ :)), for: .touchUpInside)
                cell.dobButton.addTarget(self, action: #selector(ageSelection(_ :)), for: .touchUpInside)
                cell.firstTextField.isUserInteractionEnabled = false
                cell.secondTextField.isUserInteractionEnabled = false
                cell.secondTextField.placeholder = "Date Of Birth *"
                    cell.secondTextField.text = getReadableDateForAge(timeStamp: dob ) //dob.isEmpty ?  getReadableDateForAge(timeStamp: dob ) : ""
                cell.secondTextField.setTexFieldProperty(keyboardType: .numberPad, returnType: .next, autoCaptalise: .words, isSecure: false)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell") as! AuthTableViewCell
                cell.commonTextField.tag = 4
                cell.commonTextField.delegate =  self
                cell.commonTextField.placeholder  = "Username *"
                cell.commonTextField.setTexFieldProperty(keyboardType: .emailAddress, returnType: .next, autoCaptalise: .none, isSecure: false)
                cell.commonTextField.text =  userName
                cell.commonTextField.isEnabled = true
                cell.commonTextField.isUserInteractionEnabled = true
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell") as! AuthTableViewCell
                cell.commonTextField.tag = 5
                cell.commonTextField.delegate =  self
                cell.commonTextField.placeholder  = "Email *"
                cell.commonTextField.isUserInteractionEnabled = isFromEdit
                cell.commonTextField.isEnabled = true
                cell.commonTextField.setTexFieldProperty(keyboardType: .emailAddress, returnType: .next, autoCaptalise: .none, isSecure: false)
                cell.commonTextField.text =  email
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell") as! AuthTableViewCell
                cell.commonTextField.tag = 6
                cell.commonTextField.delegate =  self
                cell.commonTextField.placeholder  = "Mobile Number *"
                cell.commonTextField.isUserInteractionEnabled = false
                cell.commonTextField.isEnabled = false
                cell.commonTextField.text = phone
//                    if phone.contains(find: "+1") {
//                        .toPhoneNumber() //"\(user.mobile_number_country_code ?? "+91")-\(user.phone_number ?? "")".toPhoneNumber()
//                    }
                    //else {
                    //cell.commonTextField.text =  "\(user.mobile_number_country_code ?? "+91")-\(user.phone_number ?? "")"
                    //}
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTableViewCell") as! AuthTableViewCell
                cell.commonTextField.tag = 7
                cell.commonTextField.delegate =  self
                cell.commonTextField.placeholder  = "Zipcode"
                cell.commonTextField.isUserInteractionEnabled = true
                cell.commonTextField.isEnabled = true
                cell.commonTextField.setTexFieldProperty(keyboardType: .numberPad, returnType: .next, autoCaptalise: .none, isSecure: false)
                cell.commonTextField.text =  zipCode
                return cell
                
            }
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SocialTableViewCell") as! SocialTableViewCell
                cell.commonTextField.delegate = self
                cell.commonImageView.image = UIImage.init(named: "icn_facebook")
                cell.commonTextField.placeholder = "Username"
                cell.commonTextField.tag = 8
                cell.commonTextField.text =  social_fb
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SocialTableViewCell") as! SocialTableViewCell
                cell.commonTextField.delegate = self
                cell.commonTextField.placeholder = "Username"
                cell.commonImageView.image = UIImage.init(named: "icn_instagram")
                cell.commonTextField.tag = 9
                cell.commonTextField.text =  social_insta
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SocialTableViewCell") as! SocialTableViewCell
                cell.commonTextField.delegate = self
                cell.commonTextField.placeholder = "Username"
                cell.commonImageView.image = UIImage.init(named: "icn_twitter")
                cell.commonTextField.tag = 10
                cell.commonTextField.text =  social_x
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SocialTableViewCell") as! SocialTableViewCell
                cell.commonTextField.delegate = self
                cell.commonTextField.placeholder = "Username"
                cell.commonImageView.image = UIImage.init(named: "icn_tiktok")
                cell.commonTextField.tag = 11
                cell.commonTextField.text =  social_tt
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}


extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
                fName =  textField.text!.trimWhiteSpace
        case 1:
            lName =  textField.text!.trimWhiteSpace
        case 2:
            gender =  textField.text!.trimWhiteSpace
        case 3:
            dob =  textField.text!.trimWhiteSpace
        case 4:
            userName =  textField.text!.trimWhiteSpace
        case 5:
            email =  textField.text!.trimWhiteSpace
        case 6:
            phone =  textField.text!.trimWhiteSpace
        case 7:
            zipCode =  textField.text!.trimWhiteSpace
        case 8:
            social_fb =  textField.text!.trimWhiteSpace
        case 9:
            social_insta =  textField.text!.trimWhiteSpace
        case 10:
            social_x =  textField.text!.trimWhiteSpace
        default:
            social_tt =  textField.text!.trimWhiteSpace
        }
    }
    
    /*\func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 5  {
            textField.resignFirstResponder()
            if let vc = UIStoryboard.profile.get(UpdateEmailViewController.self) {
                self.view.endEditing(true)
                vc.user.email = self.user.email
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.emailCompletion = { (status, email) in
                    if status {
                        if let vc = UIStoryboard.auth.get(ForgotPasswordViewController.self) {
                            vc.screenType = .updateEmail
                            vc.userObj.email = email
                            vc.otpCompletion = { (status, email) in
                                self.user.email = email
                                self.tableView.reloadData()
                            }
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    
                }
                
                self.navigationController?.present(vc, animated: false, completion: nil)
            }
            return false
        }
        return true
    }*/
    
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
        
        if textField.tag == 0 { // first name  field
            if str.length > 64 {
                return false
            }
        } else if textField.tag == 1 { // last  name field
            if str.length > 64  {
                return false
            }
        } else if textField.tag == 2 { // gender field
            if str.length > 12 || string == " " {
                return false
            }
        } else if textField.tag == 3 { // age field
            if str.length > 3 || string == " " {
                return false
            }
        } else if textField.tag == 4 { // username field
            if str.length > 64 || string == " " {
                return false
            }
        }else if textField.tag == 5 { // email field
            if str.length > 64 || string == " " {
                return false
            }
        } else if textField.tag == 7 { // zipcode
            if str.length > 6 || string == " " {
                return false
            }
        } else if textField.tag == 8 { // fb field
            if str.length > 100 || string == " " {
                return false
            }
        } else if textField.tag == 9 { // insta field
            if str.length > 100 || string == " " {
                return false
            }
        } else if textField.tag == 10 { // twitter field
            if str.length > 100 || string == " " {
                return false
            }
        }else if textField.tag == 11 { // tiktok field
            if str.length > 100 || string == " " {
                return false
            }
        }
        return true
    }
    
    @objc func genderSelection(_ sender: UIButton){
        self.view.endEditing(true)
        RPicker.selectOption(title: "Gender", cancelText: "Cancel", doneText: "Done", dataArray: ["Male","Female","Other"], selectedIndex: 0) { (selectedValue, selectedIndex) in
            self.gender = selectedValue
            self.tableView.reloadData()
        }
    }
    
    @objc func ageSelection(_ sender: UIButton){
        self.view.endEditing(true)
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = -10
        let maxDate = calendar.date(byAdding: comps, to: Date())
        comps.year = -110
        let minDate = calendar.date(byAdding: comps, to: Date())
        
        
        RPicker.selectDate(title: "Date Of Birth", cancelText: "Cancel", doneText: "Done", datePickerMode: .date, selectedDate: maxDate ?? Date() , minDate: nil, maxDate: nil, style: .Wheel) { (date) in
            
           // let age = self.getAgeFromDOF(date: "\(date)")
            let age = self.getAgeFromDateOfBirth(date: date)
            if age < 10 {
                delay(delay: 0.8) {
                    AlertController.alert(message: "You must be 10 years old to create a profile on Squabble. Users under 10 years old must have parental written consent to create a profile.")
                }
                
                self.dob = ""
                //self.user.dobTimestamp = ""
            }else {
                self.dob = date.timestamp()
                //self.user.dobTimestamp = date.timestamp()
            }
            
            self.tableView.reloadData()
        }
    }
    
    func dateString(_ format: String = "MM-dd-YYYY, hh:mm a", date: Date = Date()) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
}


extension EditProfileViewController {
    
    
    func callApiForEditProfile(){
        var params = [String: Any]()
        params["email_address"] = user.email
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "fdfdsf"
        params["device_id"] = AuthManager.shared.deviceID ?? "dsfdsf"
        params["zip_code"] = user.zip_code
        params["username"] = user.username
        params["first_name"] = user.first_name
        params["last_name"] = user.last_name
        params["gender"] = user.gender
        params["age"] =  self.user.dobTimestamp
        params["twitter_account"] = user.twitterUserName
        params["instagram_account"] = user.instaUserName
        params["facebook_account"] = user.fbUserName
        params["tiktok_account"] = user.tiktokUserName
        params["dob"] = getReadableDateForAge(timeStamp: user.dobTimestamp ?? "")
        
        
        var imageData = self.file ?? AttachmentInfo()
        imageData.apiKey = Constants.kImage_URL
        
        WebServices.editProfile(params: params, files: [imageData]) { (resposne) in
            if let obj = resposne?.object  {
                self.user = obj
                self.saveData()
                if self.isFromEdit {
                    AlertController.alert(title: "Success!!", message: "\(resposne?.message ?? "")", buttons: ["OK"]) { (alert, index) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }else {
                    if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.navigationBar.isHidden = true
                        APPDELEGATE.navigationController = navigationController
                        APPDELEGATE.window?.rootViewController = navigationController
                    }
                }
            }
        }
    }
    
    
    func saveData(){
        let user = AuthManager.shared.loggedInUser
        user?.first_name = self.user.first_name
        user?.last_name = self.user.last_name
        user?.email = self.user.email
        user?.phone_number = self.user.phone_number
        user?.mobile_number_country_code = self.user.mobile_number_country_code
        user?.zip_code = self.user.zip_code
        user?.username = self.user.username
        user?.fbUserName = self.user.fbUserName
        user?.instaUserName = self.user.instaUserName
        user?.twitterUserName = self.user.twitterUserName
        user?.tiktokUserName = self.user.tiktokUserName
        user?.gender = self.user.gender
        user?.age = self.user.age
        user?.image = self.user.image
        
        AuthManager.shared.loggedInUser = user
        
    }
    
    func uploadProfilePic(image: UIImage) {
        Logs.show(message: "Image Saved started")

        let storageRefImage =
        Storage.storage().reference().child("Images_Folder").child("profImage_\(Date().millisecondsSince1970).jpg")
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            
            storageRefImage.putData(uploadData, metadata: nil
                                    , completion: { (metadata, error) in
                if let error = error {
                    Logs.show(message: "Image Not Upload: \(error)")
                    
                }else{
                    storageRefImage.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            Logs.show(message: "Image Not Dwonload: \(String(describing: error?.localizedDescription))")
                            ProgressHud.hideActivityLoader()
                            return
                        }
                        Logs.show(message: "downloadURL Image Saved: \(downloadURL)")
                        //self.params["thumbnail_url"] = "\(downloadURL)"
                        self.profilePicUrl = "\(downloadURL)"
                        self.updateValues()
                    }
                }
            })
        }
    }
    
}


extension EditProfileViewController {
    func cameraImageAction() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Open Camera", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.openCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Open Gallery", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.openGallary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openGallary(){
        self.view.endEditing(true)
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .custom
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            callCamera()
        } else  {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func callCamera(){
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.camera
        myPickerController.modalPresentationStyle = .custom
        self.present(myPickerController, animated: true, completion: nil)
    }
}

// MARK: - Delegates
extension EditProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //new
        if let image = info[picker.allowsEditing ? UIImagePickerController.InfoKey.editedImage : UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            profImage = image
            profileImageView.image = image
            self.view.setNeedsLayout()
            
            //let imageData: NSData = image.jpegData(compressionQuality: 0.4)! as NSData
            //let compressedImage = UIImage(data: imageData as Data)
            
            //self.profileImageView.image = compressedImage
            //self.file = AttachmentInfo(withImage: compressedImage! , imageName: "profile_pic")
            //self.profileImageView.contentMode = .scaleAspectFill
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
}

extension EditProfileViewController {
    func getAgeFromDOF(date: String) -> (Int,Int,Int) {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        let dateOfBirth = dateFormater.date(from: date)
        
        let calender = Calendar.current
        
        let dateComponent = calender.dateComponents([.year, .month, .day], from:
                                                        dateOfBirth!, to: Date())
        
        return (dateComponent.year!, dateComponent.month!, dateComponent.day!)
    }
    
    func getAgeFromDateOfBirth(date: Date) -> Int {
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.year, .month, .day], from:
                                                        date, to: Date())
            
        return dateComponent.year ?? 0
    }
}


extension String {
    public func toPhoneNumber() -> String {
        return replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
        
    }
}
