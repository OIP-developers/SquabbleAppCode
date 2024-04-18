//
//  ChallengePostViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 16/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseStorage
import Photos
import UIMultiPicker

class ChallengePostViewController: UIViewController {
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneBtnPressed(_ sender: Any) {
        pickerView.isHidden = true
        if selectedChalangesAray.count == 0 {
            AppFunctions.showSnackBar(str: "No Challenge Selected")
            return
        }
        participateChllenge(vidId: vidId)
    }
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    
    
    //MARK:- Suggestion Tableview outlet
           @IBOutlet weak var tagSuggestionTableView: UITableView! {
               didSet {
                   tagSuggestionTableView.accessibilityIdentifier = "TagableTableView"
                   tagSuggestionTableView.dataSource = self
                   tagSuggestionTableView.delegate = self
                   tagSuggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagableTableView")
               }
           }
           
           // MARK: - UI Components
           @IBOutlet weak var tagging: Tagging! {
               didSet {
                   tagging.accessibilityIdentifier = "Tagging"
                   tagging.textView.accessibilityIdentifier = "TaggingTextView"
                   tagging.textView.text = "Add Caption"
                if tagging.textView.text == "Add Caption" {
                    tagging.textView.textColor = .gray
                }else {
                    tagging.textView.textColor = .black
                }
                   
                   tagging.textView.font = UIFont(name: "Rubik", size: 14)
                  // tagging.borderColor = UIColor.darkGray
                  // tagging.layer.borderWidth = 0.5
                   
                   tagging.textView.borderColor = .clear
                   
                  // tagging.cornerRadius = 20
                   tagging.textInset = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
                  // tagging.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
                   tagging.backgroundColor = .white
                   tagging.defaultAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Rubik", size: 14)!]
                   tagging.symbolAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                  // tagging.taggedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.underlineStyle: NSNumber(value: 1)]
                   tagging.dataSource = self
                   //tagging.symbol = " @"

                   
               }
           }
       
           private var userName: [String] = []
           private var selectedUserID: [String] = []
           private var users = [User]()
    
    var paramArray = [[String: Any]]()
    var allVidParamArray = [[String: Any]]()
    var params = [String: Any]()
    var thumbnailImage = UIImage()
    var selectedCategories = [String]()
    var thumbNailUrl = ""
    var videoUrl = ""
    var isForChallange = false
    var challangeType = ""
    
    var vidId = ""
    var chalangesArray = [String]()
    var chalanges = [ChallengesModel]()
    var selectedChalangesAray = [Int]()
    var selectedChalangesArayIds = [String]()
      
    var userList = [FollowUsers()]
    
           private var matchedList: [String] = [] {
               didSet {
                   tagSuggestionTableView.reloadData()
                       //tagableTableView.reloadSections(IndexSet(integer: 0), with: .fade)
               }
           }
          
           private var taggedList: [TaggingModel] = [] {
               didSet {
                   
                   self.selectedUserID.removeAll()
                
                tagging.symbol = (tagging.textView.text.count == 1 && tagging.textView.text == "@") ? "@" : " @"
                   
                   for i in 0 ..< taggedList.count {
                       for j in 0 ..< users.count {
                           if taggedList[i].text == users[j].username  {
                            self.selectedUserID.append(users[j].user_id ?? "")
                           }
                       }
                   }
                   
                   for  index in 0 ..< self.selectedUserID.count {
                   print("self.selectedUserID[\(index)] \(self.selectedUserID[index])")
                   }
                   
                   for i in 0 ..< taggedList.count {
                    userName.append(taggedList[i].text)
                    print(taggedList[i].text)
                    
                   }
                 // taggedTableView.reloadSections(IndexSet(integer: 0), with: .fade)
               }
           }
           
       
    
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!

    
    var videoID : Int?
    var nameArray = [HomeModel]()
    //var challengeNameArray = ["Dance","Tech","Science","Cooking","Random"]
    var CategoryNameArray = [String]()
    var CategoryArray = [CategoriesModel]()
    var challengeId : String?
    var videoURL: URL?
    var file: AttachmentInfo?
    var data : NSData?
    var videoObj = RewardsModel()
    var homeObj = HomeModel()
    
    var videoType: VideoType = .myPost
    var url = ""
    var isFromEdit = false
    var isFromProfile = false
    var thumbnail = UIImage()
    var videoCount = 0
    var dynamic_error_message = ""
    var isFiltered = false

    
   //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
        //getChalngesList()
        self.customizeSuggestionTableViewLayer()
        getCountApi()
        self.getFollwerFollowingList()
        
        tagging.textView.text = "Add Caption"
        if tagging.textView.text == "Add Caption" {
            tagging.textView.textColor = .gray
        }else {
            tagging.textView.textColor = .black
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.challengeButton.setTitle((homeObj.challenge_id != nil) ? homeObj.title : "Challenge Name", for: .normal)
        if (homeObj.challenge_id != nil) {
            self.challengeId = homeObj.challenge_id
        }
        
        getChallengesName()
    }
    
    //MARK:- Helper Method
    func initialMethod(){
        captionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openVideoAction))
        self.challengeImageView.isUserInteractionEnabled = true
        self.challengeImageView.addGestureRecognizer(gesture)
        galleryButton.isHidden = videoType == .gallery
        stackHeightConstraint.constant = videoType ==  .gallery ? 50 : 120
        
        if videoObj.video_text != "" {
            for  index in 0 ..< self.selectedUserID.count {
                print("self.selectedUserID[\(index)] \(self.selectedUserID[index])")
            }
            
            
            for i in 0 ..< taggedList.count {
                userName.append(taggedList[i].text)
                print(taggedList[i].text)
            }
            
            tagging.textView.text =  videoObj.video_text?.base64Decoded()
            for item in videoObj.tagged_user {
                tagging.updateTaggedList(allText: tagging.textView.text, tagText: item.username ?? "")
                self.taggedList.append(TaggingModel.init(text: item.username ?? "", range: NSRange()))
            }
            //for i in 0 ..< taggedList.count {
            for j in 0 ..< videoObj.tagged_user.count {
                //  if taggedList[i].text == videoObj.tagged_user[j].username  {
                self.selectedUserID.append(videoObj.tagged_user[j].user_id ?? "")
                // }
            }
            tagging.textView.textColor = .black
            // }
            
        }
        
        //captionTextView.text = videoObj.video_text?.base64Decoded()
        //tagging.textView.text = videoObj.video_text?.base64Decoded()
//        if let url = URL(string: videoObj.video_thumbnail ?? "") {
//            self.challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
//        }
        
        if(videoObj.video_thumbnail != nil){
        if let url = URL(string: videoObj.video_thumbnail ?? "") {
            self.challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        }else{
            let url = videoURL
            let thumbnailImage = getThumbnailImage(forUrl: url!)
            challengeImageView.image = thumbnail  // thumbnailImage?.fixOrientation
        }
        
        challengeImageView.image = thumbnailImage
        
    }
    
    func sizeOfFile(data: Data) -> String {
        let imageSize: Int = data.count
        Logs.show(message:"There were \(imageSize) bytes")
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(imageSize))
    }
    
    func currentTimeInMilliSeconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    
    func updloadVidData() {
        
        var finalVidData : Data? = nil
        do {
            let data = try Data(contentsOf: videoURL!, options: .mappedIfSafe)
            Logs.show(message: "pickedVideo Converted size of file in MB: \(self.sizeOfFile(data: data))")
        } catch let error {
            print("*** Error : \(error.localizedDescription)")
        }
        do {
            finalVidData = try Data(contentsOf: videoURL!)
        } catch let error {
            Logs.show(message: "finalData Error: \(String(describing: error.localizedDescription))")
            
        }
        Logs.show(message: "finalData : \(String(describing: finalVidData))")
        //var params = [String: Any]()
        //Logs.show(message: "FilterdURL: \(String(describing: url))")

        params["liked_count"] = 0
        params["comments_count"] = 0
        params["created_At"] = "\(Date().millisecondsSince1970)"
        params["uploaded_by"] = Auth.auth().currentUser!.uid
        
        
        let storageRefImage =
        Storage.storage().reference().child("Images_Folder").child("Image_\(Date().millisecondsSince1970).jpg")
        if let uploadData = self.thumbnailImage.jpegData(compressionQuality: 0.5) {
            
            storageRefImage.putData(uploadData, metadata: nil
                                    , completion: { (metadata, error) in
                if let error = error {
                    Logs.show(message: "Image Not Upload: \(error)")
                    AppFunctions.showSnackBar(str: "Upload Error!")
                    
                }else{
                    storageRefImage.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            Logs.show(message: "Image Not Dwonload: \(String(describing: error?.localizedDescription))")
                            return
                        }
                        Logs.show(message: "downloadURL Image Saved: \(downloadURL)")
                        self.thumbNailUrl = "\(downloadURL)"
                        self.params["thumbnail_url"] = "\(downloadURL)"
                    }
                }
            })
        }
        
        
        let storageRef =
        Storage.storage().reference().child("Videos_Folder").child("Video_\(Date().millisecondsSince1970)")
        if let uploadData = finalVidData as Data? {
            let metaData = StorageMetadata()
            metaData.contentType = "video/mp4"
            
            storageRef.putData(uploadData, metadata: metaData
                               , completion: { (metadata, error) in
                Logs.show(message: "VID Upload MetaData: \(String(describing: metadata))")
                if let error = error {
                    Logs.show(message: "VID Not Upload: \(error)")
                    AppFunctions.showSnackBar(str: "Upload Error!")
                    ProgressHud.hideActivityLoader()
                    
                }else{
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            Logs.show(message: "VID Not Dwonload: \(String(describing: error?.localizedDescription))")
                            ProgressHud.hideActivityLoader()
                            return
                        }
                        Logs.show(message: "downloadURL VID Saved: \(downloadURL)")
                        self.videoUrl = "\(downloadURL)"
                        self.params["video_url"] = "\(downloadURL)"
                        
                        do {
                            let data = try Data(contentsOf: downloadURL, options: .mappedIfSafe)
                            Logs.show(message: "pickedVideo Converted size of downloaded file in MB: \(self.sizeOfFile(data: data))")
                        } catch let error {
                            print("*** Error : \(error.localizedDescription)")
                        }
                        
                        self.params["Challange_name"] = self.selectedCategories.first
                        self.params["caption"] = self.tagging.textView.text ?? ""
                        
                        
                        //self.userVidSave()
                        self.UploadVideoToAPINew()
                        self.allVidSave()
                        
                    }
                }
            })
        }
    }
    
    func userVidSave() {
        /// USER VIDEOS

        let videoDB = Database.database().reference()
        
        let videoReference = videoDB.child("Videos").child(Auth.auth().currentUser!.uid)
        videoReference.getData(completion: { [weak self] err, snapShot in
            if snapShot?.hasChildren() == true {
                for vids in snapShot!.children {
                    let snap = vids as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    let id = dict["video_id"] as! String
                    self?.params["video_id"] = "\(Int(id)! + 1)"
                    self?.paramArray.append(dict)
                }
                self?.paramArray.append(self!.params)
                videoReference.setValue(self?.paramArray) { err , snapshot in
                    if err != nil {
                        Logs.show(message: "ERRR: \(err?.localizedDescription ?? "")")
                    }
                    Logs.show(message: "SNAP VIDEO: \(snapshot)")
                    
                }
            } else {
                self?.params["video_id"] = "1"
                self?.paramArray.append(self!.params)
                videoReference.setValue(self?.paramArray) { err , snapshot in
                    if err != nil {
                        Logs.show(message: "ERRR: \(err?.localizedDescription ?? "")")
                    }
                    Logs.show(message: "SNAP VIDEO: \(snapshot)")
                    
                }
            }
            //AlertController.alert(title: "Success", message: "Video uploaded and saved to photos.)")
            
        })
    }
    
    func allVidSave() {
        /// ALL VIDEOS
        ///
        let videoDB = Database.database().reference()

        let allVideoReference = videoDB.child("All_Videos")
        allVideoReference.getData(completion: { [weak self] err, snapShot in
            if snapShot?.hasChildren() == true {
                for vids in snapShot!.children {
                    //Logs.show(message: "Saved ALL Vids 1 : \(vids)")
                    let snap = vids as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    let id = dict["video_id"] as! String
                    self?.params["video_id"] = "\(Int(id)! + 1)"
                    //Logs.show(message: "Saved ALL video_id 1 : \(id) --- \(String(describing: self?.params["video_id"])) ---- \(Int(id) ?? 0)")
                    
                    self?.allVidParamArray.append(dict)
                }
                //Logs.show(message: "Saved param Array 2 : \(self?.allVidParamArray)")
                self?.allVidParamArray.append(self!.params)
                allVideoReference.setValue(self?.allVidParamArray) { err , snapshot in
                    if err != nil {
                        Logs.show(message: "ERRR: \(err?.localizedDescription ?? "")")
                        ProgressHud.hideActivityLoader()

                    }
                    //Logs.show(message: "SNAP ALL VIDEO: \(snapshot)")
                    ProgressHud.hideActivityLoader()
                }
            } else {
                //Logs.show(message: "Saved ALL Vids 0 : empty")
                Logs.show(message: "Saved param Array 0 : \(self?.allVidParamArray)")
                self?.params["video_id"] = "1"
                self?.allVidParamArray.append(self!.params)
                allVideoReference.setValue(self?.allVidParamArray) { err , snapshot in
                    if err != nil {
                        Logs.show(message: "ERRR: \(err?.localizedDescription ?? "")")
                        ProgressHud.hideActivityLoader()
                    }
                    Logs.show(message: "SNAP ALL VIDEO: \(snapshot)")
                    
                    //ProgressHud.hideActivityLoader()
                }
            }
        })
    }
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
    
    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: outputURL, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        //print(error.localizedDescription)
                        Logs.show(message: "Filterd VID Saved: !NOT successfully \(error.localizedDescription)")
                    } else {
                        Logs.show(message: "Filterd VID Saved: successfully")
                    }
                    completion?(error)
                }
            }
        }
    }
    
    func customizeSuggestionTableViewLayer() {
            // corner radius
            tagSuggestionTableView.layer.cornerRadius = 10

            // border
            tagSuggestionTableView.layer.borderWidth = 1.0
            tagSuggestionTableView.layer.borderColor = UIColor.black.cgColor

            // shadow
            tagSuggestionTableView.layer.shadowColor = UIColor.darkGray.cgColor
            tagSuggestionTableView.layer.shadowOffset = CGSize(width: 1, height: 1)
            tagSuggestionTableView.layer.shadowOpacity = 0.7
            tagSuggestionTableView.layer.shadowRadius = 4.0
            tagSuggestionTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    
    func removeDuplicateElements(post: [String]) -> [String] {
          var uniquePosts = [String]()
          for post in post {
              if !uniquePosts.contains(where: {$0 == post }) {
                  uniquePosts.append(post)
              }
          }
          return uniquePosts
      }
    
    @objc func openVideoAction(){
        if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
            vc.isfromPost = true
            vc.videoObj = videoObj
            vc.videoURL = self.videoURL
            vc.videoType = .gallery
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    // MARK: - UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        //  self.callApiForDiscardingVideo()
//        if self.videoType == .gallery {
//            self.navigationController?.popViewController(animated: true)
//        }else {
            /*if isFromEdit || isFromProfile {
                self.navigationController?.popViewController(animated: true)
            } else {
                AlertController.alert(title: "Discard Video?", message: "If you go back now, you will lose your video."
                , buttons: ["Discard","Keep"]) { (alert, index) in
                    if index == 0 {
                        self.callApiForDiscardingVideo()
                    }
                }
            }*/
      //  }
    }
    
    @IBAction func challengeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.CategoryNameArray.count > 0 {
            RPicker.selectOption(title: "Select Categories", cancelText: "Cancel", dataArray: self.CategoryNameArray.map{($0)}, selectedIndex: 0) {[weak self] (selctedText, atIndex) in
                self?.challengeButton.setTitle(selctedText, for: .normal)
                self?.selectedCategories.append(selctedText)
                
                /*let dict = self?.nameArray[atIndex]
                if self?.nameArray[atIndex].check_if_participated != "0"{
                    self?.challengeButton.setTitle("Challenge Name", for: .normal)
                    Alerts.shared.show(alert: .warning, message: "Already participated.", type: .warning)
                }else {
                    self?.challengeId = dict?.challenge_id
                    self?.homeObj.challenge_id = dict?.challenge_id
                    self?.challengeButton.setTitle(selctedText, for: .normal)
                }*/
            }
        }
        
        /*if self.nameArray.count > 0 {
        RPicker.selectOption(title: "Select Challenge Name", cancelText: "Cancel", dataArray: self.nameArray.map{($0.title ?? "")}, selectedIndex: 0) {[weak self] (selctedText, atIndex) in
            let dict = self?.nameArray[atIndex]
            if self?.nameArray[atIndex].check_if_participated != "0"{
                self?.challengeButton.setTitle("Challenge Name", for: .normal)
                Alerts.shared.show(alert: .warning, message: "Already participated.", type: .warning)
            }else {
                self?.challengeId = dict?.challenge_id
                self?.homeObj.challenge_id = dict?.challenge_id
                self?.challengeButton.setTitle(selctedText, for: .normal)
            }
            }
        } else {
            AlertController.alert(message: "No challenge available.")
        }*/
    }
    
    @IBAction func postButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        
        /*if selectedCategories.isEmpty {
            AlertController.alert(title: "Alert", message: "Please select any Category to post video.")
            return
        }*/
        
        ProgressHud.showActivityLoaderWithTxt(text: "Uploading...")

        isForChallange = true
        updloadVidData()
        
        /*\if self.challengeId != nil && homeObj.challenge_id != nil{
            let obj = self.nameArray.filter{$0.challenge_id == self.challengeId }.first
            let dateSt = "\(Date().toMillis() ?? 0)"
            if Int(obj?.start_timestamp ?? "0") ?? 0 > Int(dateSt) ?? 0 {
                 AlertController.alert(title: "Alert", message: "You can't participate in this challenge as it has yet not started.")
            }
            //else if videoCount == 20 {
           //     AlertController.alert(message: self.dynamic_error_message)
           // }
        else {
                callApiForPostChallenge()
            }
        }else{
            AlertController.alert(title: "Alert", message: "Please select any challenge to post video.")
        }*/
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton){
        
        self.view.endEditing(true)
        
        /*if selectedCategories.isEmpty {
            AlertController.alert(title: "Alert", message: "Please select any Category to post video.")
            return
        }*/
        
        ProgressHud.showActivityLoaderWithTxt(text: "Uploading...")
        
        updloadVidData()
        
        
        /*self.saveVideoToAlbum(videoURL!) { err in
            if let er = err {
                Logs.show(message: "Filterd VID Not Saved: \(er)")
                return
            }
            AlertController.alert(message: "Saved to gallery")
            // }
            Logs.show(message: "Filterd VID Saved2: successfully")
        }*/
//        if videoCount == 20 {
//            AlertController.alert(message: self.dynamic_error_message)
//        }else {
//            callApiForSaveVideoToGalary()
//        }
    }
    
    //MARK: MultiPicker Func
    
    func setupMultiPickerView() {
        multiPickerView.options = chalangesArray
        
        multiPickerView.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        
        multiPickerView.color = .gray
        multiPickerView.tintColor = .white
        multiPickerView.font = .systemFont(ofSize: 18, weight: .semibold)
        
        multiPickerView.highlight(0, animated: false)
    }
    
    @objc func selected(_ sender: UIMultiPicker) {
        
        Logs.show(message: "Selected Index: \(sender.selectedIndexes)")
        
        selectedChalangesAray = sender.selectedIndexes
        Logs.show(message: "Selected CHALLENGES: \(selectedChalangesAray)")
        
    }

}

//MARK: api Calls
extension ChallengePostViewController{
    
    func getMyProfile() {
        
        APIService
            .singelton
            .getMyProfile()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            if val.follower != nil {
                                self.userList = val.follower
                            }
                            if val.following != nil {
                                self.userList += val.following
                            }
                            
                            tagging.hashtagTaggableList = userList.compactMap({$0.first_name})

                            
                            
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
    
    
    func getChallengesName(){
        
        APIService
            .singelton
            .getCategory()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.CategoryArray = val
                            //self.CategoryNameArray =
                            tagging.hashtagTaggableList = self.CategoryArray.compactMap({$0.name})
                            
                            //tagging.atTaggableList = val.compactMap({$0.id})
                            self.challengeButton.setTitle(self.CategoryNameArray.first , for: .normal)
                            Logs.show(message: "\(val.count) ,, \(tagging.hashtagTaggableList)")
                        } else {
                            Logs.show(message: "Val 0")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)

     }
    
    func getChalngesList() {
        Logs.show(message: "Saved Vids :::: ")
        
        APIService
            .singelton
            .getChalenges()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            self.chalanges = val
                            if self.challangeType == "" {
                                self.chalangesArray = val.compactMap({ "\($0.name ?? "") -- \($0.type ?? "")"  })
                            } else {
                                self.chalangesArray = val.filter({ $0.type == self.challangeType }).compactMap({ "\($0.name ?? "")"  })
                            }
                            
                            //self.chalangesArray = val.compactMap({ "\($0.name ?? "")"  })
                            self.setupMultiPickerView()
                        } else {
                            AppFunctions.showSnackBar(str: "No Challenges available")
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
    
    
    func participateChllenge(vidId: String) {
        
        //ProgressHud.showActivityLoader()
        
        //for selectedIndexOfCHArray in selectedChalangesAray {
            selectedChalangesArayIds.append(AppFunctions.getChalID())
        //}
        
        let pram : [String : Any] = ["challenges": selectedChalangesArayIds]
        
        Logs.show(message: "SKILLS PRAM: \(pram) , \(vidId)")
        
        APIService
            .singelton
            .participateInChallenge(Pram: pram, vidId: vidId)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            AppFunctions.showSnackBar(str: "Video Added in challenge...")
                            
                            ProgressHud.hideActivityLoader()
                            AlertController.alert(title: "Congratulations!", message: "You just uploaded a video to challenge(s)!.", acceptMessage: "OK") {
                                self.isForChallange = false
                                // FINISH
                                if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    navigationController.navigationBar.isHidden = true
                                    self.tabBarController?.selectedIndex = 2
                                    APPDELEGATE.navigationController = navigationController
                                    APPDELEGATE.window?.rootViewController = navigationController
                                }
                            }
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in Uploading to challenge")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
    func UploadVideoToAPINew(){
        
        //let chalID : [String] = CategoryArray.filter{$0.name == selectedChallenge}.first?.id
        //let catIds : [String] = CategoryArray.filter{$0.name == selectedCategories[]}
        var catIDs = [String]()
        if (selectedCategories.isEmpty){
            if CategoryArray.isEmpty {
                let arraySlice = CategoryArray.prefix(upTo: 5)
                let newArray = Array(arraySlice)
                catIDs = newArray.map{$0.id}
            }
        } else {
            for cat in selectedCategories {
                catIDs.append( CategoryArray.filter{$0.name == cat}.first?.id ?? "")
            }
        }

        ProgressHud.showActivityLoader()
        let pram : [String : Any] = ["name": selectedCategories.first ?? "General",
                                     "categories": catIDs,
                                     "caption": self.tagging.textView.text ?? "",
                                     "thumbnail_url": thumbNailUrl,
                                     "video_url": videoUrl]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .uploadVideo(Pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            ProgressHud.hideActivityLoader()
                            if self.isForChallange {
                                //self.vidId = val.id
                                participateChllenge(vidId: val.id)
                                /*self.pickerView.isHidden = false
                                self.selectedChalangesAray.removeAll()
                                self.selectedChalangesArayIds.removeAll()
                                self.multiPickerView.selectedIndexes = []*/
                            } else {
                                AlertController.alert(title: "", message: "You just uploaded a video to your profile!.", acceptMessage: "OK") {
                                    // FINISH
                                    if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                                        let navigationController = UINavigationController(rootViewController: vc)
                                        navigationController.navigationBar.isHidden = true
                                        vc.selectedIndex = 4
                                        APPDELEGATE.navigationController = navigationController
                                        APPDELEGATE.window?.rootViewController = navigationController
                                    }
                                }
                            }
                        } else {
                            ProgressHud.hideActivityLoader()
                            AlertController.alert(title: "Failure", message: "Video Not Posted.", acceptMessage: "OK") {
                                // FINISH
                                if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    navigationController.navigationBar.isHidden = true
                                    vc.selectedIndex = 4
                                    APPDELEGATE.navigationController = navigationController
                                    APPDELEGATE.window?.rootViewController = navigationController
                                }
                            }
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }

    
    
    func callApiForPostChallenge() {
        var params = [String: Any]()
        params["challenge_id"] = (self.challengeId != nil) ? self.challengeId : homeObj.challenge_id
        params["video_id"] = self.videoID
        params["video_text"] = self.tagging.textView.text.trimWhiteSpace.base64Encoded()
        params["video_text_without_encoded"] = self.tagging.textView.text == "Add Caption" ? "" : self.tagging.textView.text.trimWhiteSpace
        params["tag_user"] = self.removeDuplicateElements(post: self.filterTaggableData())
        WebServices.postVideoToChallenge(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    self.navigationController?.popToRootViewController(animated: true)
                }else if response.statusCode == 0 {
                    AlertController.alert(message: "\(response.message ?? "")")
                }
            }
        })
    }
    
    func callApiForDiscardingVideo() {
           var params = [String: Any]()
           params["video_id"] = self.videoID
        if self.videoType == .gallery {
            params["flag"] = 1
           }
        
           WebServices.deleteVideo(params: params, successCompletion: { (response) in
               if let response = response {
                   if response.statusCode == 200 {
                       self.navigationController?.popToRootViewController(animated: true)
                   }
               }
           })
       }
    
    func callApiForSaveVideoToGalary() {
        var params = [String: Any]()
        params["video_id"] = self.videoID
        params["video_text"] = self.tagging.textView.text.trimWhiteSpace.base64Encoded()
        params["video_text_without_encoded"] = self.tagging.textView.text == "Add Caption" ? "" : self.tagging.textView.text.trimWhiteSpace
        params["tag_user"] = self.removeDuplicateElements(post: self.filterTaggableData())
        WebServices.saveVideoToGallery(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        })
    }
    
    func getFollwerFollowingList() {
        
        var param = [String: Any]()
        param["type_id"] = "1"
        param["user_id"] = AuthManager.shared.loggedInUser?.user_id
        WebServices.getFollowerFollowing(params: param) { (response) in
            if let arr = response?.array {
                self.users = arr
                self.tagging.tagableList = arr.map { ($0.username ?? "") }
                self.tagSuggestionTableView.reloadData()
            }
        }
    }
    
    func getCountApi(){
           WebServices.getCounts { (response) in
               if let obj = response?.object {
                   self.videoCount = obj.video_count ?? 0
                   self.dynamic_error_message = obj.dynamic_error_message ?? ""
               }
           }
       }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    func filterTaggableData() -> [String] {
           var userIdList = [String]()
           for item in self.users {
               let str = self.tagging.textView.text.prefix(1)
               if str == "@" {
                   let taggedName = "@\(item.username ?? "")"
                   if self.tagging.textView.text.contains(find: "\(taggedName)") {
                       let data = "\((self.users.filter{$0.username == item.username}).first?.user_id ?? "")"
                       userIdList.append(data)
                   }
               }else {
                   let taggedName = " @\(item.username ?? "")"
                   if self.tagging.textView.text.contains(find: "\(taggedName)") {
                       let data = "\((self.users.filter{$0.username == item.username}).first?.user_id ?? "")"
                       userIdList.append(data)
                   }
               }
               
           }
           return userIdList
       }

}


extension ChallengePostViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == self.tagSuggestionTableView else {
            return tagging.taggedList.count
        }
        
        return matchedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView == tagSuggestionTableView else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagableTableView", for: indexPath)
            let model = taggedList[indexPath.row]
            cell.textLabel?.font = Fonts.Rubik.medium.font(.medium)
            cell.textLabel?.text = "\(model.text) - \(model.range)"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagableTableView", for: indexPath)
        cell.textLabel?.text = matchedList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == tagSuggestionTableView else {return}
        
        tagging.updateTaggedList(allText: tagging.textView.text, tagText: matchedList[indexPath.row])
        Logs.show(message: tagging.textView.text)
        
        if tagging.textView.text.contains(find: "#") {
            selectedCategories.append(CategoryArray.filter{$0.name == matchedList[indexPath.row]}.first!.name)
        } else {
        //selectedUsers.append(userList.filter{$0.first_name == matchedList[indexPath.row]}.first!.first_name)
        }
        
        Logs.show(message: "selected: " + "\(selectedCategories)")
        tableView.deselectRow(at: indexPath, animated: true)
        matchedList.removeAll()
    }
}

// MARK: - TaggingDataSource
extension ChallengePostViewController: TaggingDataSource {
    
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String]) {
        matchedList = tagableList
    }
    
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {
        self.taggedList = taggedList
        tagging.symbol = (tagging.textView.text.count == 1 && (tagging.textView.text == "@" || tagging.textView.text == "#")) ? tagging.textView.text : " "

    }
    
}

extension ChallengePostViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
}
