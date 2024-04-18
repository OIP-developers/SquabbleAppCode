//
//  EditVideoViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 05/10/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class EditVideoViewController: UIViewController {
    
    //MARK:- Suggestion Tableview outlet
    @IBOutlet weak var editVideoTableView: UITableView! {
        didSet {
            
        }
    }
    
    private var userName: [String] = []
    private var users = [User]()
    private var selectedUserID: [String] = []
    
    // MARK: - UI Components
    @IBOutlet weak var tagging: Tagging! {
        didSet {
            tagging.accessibilityIdentifier = "Tagging"
            tagging.textView.accessibilityIdentifier = "TaggingTextView"
            tagging.textView.text = "Add Caption"
            tagging.textView.textColor = .black
            tagging.textView.font = UIFont(name: "Rubik", size: 14)
            tagging.textView.borderColor = .clear
            tagging.textInset = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
            tagging.backgroundColor = .white
            tagging.defaultAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Rubik", size: 14)!]
            tagging.symbolAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            tagging.dataSource = self
            tagging.symbol = " @"
            
        }
    }
    
    private var matchedList: [String] = [] {
        didSet {
            editVideoTableView.reloadData()
        }
    }
    
    private var taggedList: [TaggingModel] = [] {
        
        didSet {
            
            for i in 0 ..< taggedList.count {
                for j in 0 ..< users.count {
                    if taggedList[i].text == users[j].username  {
                        self.selectedUserID.append(users[j].user_id ?? "")
                    }
                }
            }
            
            for item in taggedList {
                userName.append(item.text)
            }
            
        }
    }
    
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    
    
    var videoID : Int?
    var nameArray = [HomeModel]()
    var challengeId : String?
    var videoURL: URL?
    var file: AttachmentInfo?
    var data : NSData?
    var videoObj = RewardsModel()
    var homeObj = HomeModel()
    
    var url = ""
    var isFromEdit = false
    var thumbnail = UIImage()
    
    var editCompletion: ((String, String, [TaggedUser]) -> Void)? = nil
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        editVideoTableView.accessibilityIdentifier = "TagableTableView"
        editVideoTableView.dataSource = self
        editVideoTableView.delegate = self
        editVideoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagableTableView")
        self.initialMethod()
        customizeSuggestionTableViewLayer()
        getFollwerFollowingList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        challengeButton.isHidden = videoObj.is_posted == "0"
        self.challengeButton.setTitle((homeObj.challenge_id != nil) ? homeObj.title : "", for: .normal)
        if (homeObj.challenge_id != nil) {
            self.challengeId = homeObj.challenge_id
        }
    }
    
    //MARK:- Helper Method
    
    func initialMethod(){
        
        for i in 0 ..< taggedList.count {
            userName.append(taggedList[i].text)
            print(taggedList[i].text)
        }
        
        tagging.textView.text =  videoObj.video_text?.base64Decoded()
        for item in videoObj.tagged_user {
            tagging.updateTaggedList(allText: tagging.textView.text, tagText: item.username ?? "")
            self.taggedList.append(TaggingModel.init(text: item.username ?? "", range: NSRange()))
        }
        for j in 0 ..< videoObj.tagged_user.count {
            self.selectedUserID.append(videoObj.tagged_user[j].user_id ?? "")
        }
        
        captionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openVideoAction))
        self.challengeImageView.isUserInteractionEnabled = true
        self.challengeImageView.addGestureRecognizer(gesture)
        captionTextView.text = videoObj.video_text?.base64Decoded()
        tagging.textView.text =  videoObj.video_text?.base64Decoded()
        
        if(videoObj.video_thumbnail != nil){
            if let url = URL(string: videoObj.video_thumbnail ?? "") {
                self.challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
        }else{
            let url = videoURL
            let thumbnailImage = getThumbnailImage(forUrl: url!)
            challengeImageView.image = thumbnail  // thumbnailImage?.fixOrientation
        }
        
    }
    
    //MARK:- Suggestion TableView layer
    func customizeSuggestionTableViewLayer() {
        // corner radius
        editVideoTableView.layer.cornerRadius = 10
        
        // border
        editVideoTableView.layer.borderWidth = 1.0
        editVideoTableView.layer.borderColor = UIColor.black.cgColor
        
        // shadow
        editVideoTableView.layer.shadowColor = UIColor.darkGray.cgColor
        editVideoTableView.layer.shadowOffset = CGSize(width: 1, height: 1)
        editVideoTableView.layer.shadowOpacity = 0.7
        editVideoTableView.layer.shadowRadius = 4.0
        editVideoTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    
    @objc func openVideoAction(){
        self.matchedList.removeAll()
        if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
            vc.isfromPost = true
            vc.videoObj = videoObj
            vc.videoURL = self.videoURL
            vc.videoType = .gallery
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func removeDuplicateElements(post: [String]) -> [String] {
        var uniquePosts = [String]()
        for item in post {
            if !uniquePosts.contains(where: {$0 == item }) {
                uniquePosts.append(item)
            }
        }
        return uniquePosts
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
    
    // MARK: - UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        self.editCompletion?(self.videoObj.video_text ?? "", self.videoObj.video_id ?? "", self.videoObj.tagged_user)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if self.tagging.textView.text.trimWhiteSpace.isEmpty {
            AlertController.alert(message: "Please add caption")
        }else {
            callApiForUpdateVideo()
        }
    }
    
}

//api
extension EditVideoViewController{
    
    func callApiForUpdateVideo() {
        var params = [String: Any]()
        params["video_id"] = self.videoID
        params["is_posted"] = self.videoObj.is_posted
        params["caption"] = self.tagging.textView.text == "Add Caption" ? "" : self.tagging.textView.text.trimWhiteSpace.base64Encoded()
        params["caption_without_encoded"] = self.tagging.textView.text == "Add Caption" ? "" : self.tagging.textView.text.trimWhiteSpace
        params["tag_user"] = self.removeDuplicateElements(post: self.filterTaggableData())
        
        WebServices.editVideoCaption(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let obj = response.object {
                        self.editCompletion?(self.tagging.textView.text == "Add Caption" ? "" : self.tagging.textView.text.trimWhiteSpace.base64Encoded() ?? "", self.videoObj.video_id ?? "", obj.tagged_user)
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }else if response.statusCode == 0 {
                    AlertController.alert(message: "\(response.message ?? "")")
                }
            }
        })
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
    
    func getFollwerFollowingList() {
        
        var param = [String: Any]()
        param["type_id"] = "1"
        param["user_id"] = AuthManager.shared.loggedInUser?.user_id
        WebServices.getFollowerFollowing(params: param) { (response) in
            if let arr = response?.array {
                self.users = arr
                self.tagging.tagableList = arr.map { ($0.username ?? "") }
                self.editVideoTableView.reloadData()
            }
        }
    }
    
}

extension EditVideoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
        
        self.matchedList.removeAll()
    }
    
    
}


extension EditVideoViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == self.editVideoTableView else {
            return taggedList.count
        }
        
        return matchedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView == editVideoTableView else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagableTableView", for: indexPath)
            let model = taggedList[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.textLabel?.text = "\(model.text) - \(model.range)"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagableTableView", for: indexPath)
        cell.textLabel?.text = matchedList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == editVideoTableView else {return}
        self.tagging.updateTaggedList(allText: self.tagging.textView.text, tagText: self.matchedList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        self.matchedList.removeAll()
        
    }
}

// MARK: - TaggingDataSource
extension EditVideoViewController: TaggingDataSource {
    
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String]) {
        matchedList = tagableList
    }
    
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {
        self.taggedList = taggedList
    }
}

