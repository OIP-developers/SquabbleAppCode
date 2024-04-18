//
//  ChatViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import SDWebImage


class ChatViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    
    //var user = User()
    //var file: AttachmentInfo?
    var chats = [ChatModelExt]()
    
    var chatModel = ChatModel()
    var db: Firestore!
    
    var offset =  0  // -10
    var user1 = [String:Any]()
    var isMoreData = true
    var isPresented = false
    var refreshControl: UIRefreshControl!
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.backgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        initialMethod()
        getMessageHistory()
        messagesListner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    
    
    //MARK:- Helper Method
    func initialMethod() {
        pullToRefersh()
        tableView.register(UINib(nibName: "SenderChatCell", bundle: nil), forCellReuseIdentifier: "SenderChatCell")
        tableView.register(UINib(nibName: "ReceiverChatCell", bundle: nil), forCellReuseIdentifier: "ReceiverChatCell")
        
        tableView.register(UINib(nibName: "SenderImageTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderImageTableViewCell")
        tableView.register(UINib(nibName: "ReceiverImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageTableViewCell")
        tableView.register(UINib(nibName: "SenderShareTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderShareTableViewCell")
        tableView.register(UINib(nibName: "ReceiverShareTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverShareTableViewCell")
        
        
        chatTextView.delegate = self
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.clipsToBounds = true
        userImageView.layer.borderWidth = 1.0
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderColor = UIColor.darkGray.cgColor
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openProfileScreen))
        self.userImageView.addGestureRecognizer(tapGesture)
        customSetup()
    }
    
    func customSetup(){
        if user1.keys.count > 0 {
            userNameLabel.text = user1["name"] as? String
            if let url = URL(string: user1["profilePic"] as? String ?? "") {
                userImageView.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
            }
        } else {
            userNameLabel.text = chatModel.name ?? ""
            if let url = URL(string: chatModel.profilePic ?? "") {
                userImageView.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }

            }
        }
        
    }
    
    func pullToRefersh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        // refresh tableView
        self.offset = self.offset + 10
        self.getMessageHistory()
        refreshControl.endRefreshing()
    }

    @objc func openProfileScreen(){
        /*if self.user.blocked_status == 1 {
            AlertController.alert(message: "User not found.")
        } else if self.user.check_if_you_block == 1 {
            AlertController.alert(title: "", message: "You blocked this account. To view profile unblock the user from settings.")
        }else {
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                vc.user.user_id = self.user.user_id
                vc.blockCompletion = { userId in
                    self.user.check_if_you_block = 1
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }*/
    }
    
    
    //MARK:- Keyboard Methods
    @objc func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            if let keyboardHeight = keyboardHeight {
                viewBottomConstraint.constant = -keyboardHeight
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.perform(#selector(self.scrollToBottom), with: nil, afterDelay: 0.0)
                })
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        viewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded()
        })
        self.perform(#selector(scrollToBottom), with: nil, afterDelay: 0.2)
    }
    
    //MARK:- Target Method
    @objc func scrollToBottom() {
        /*if self.chats.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.chats.count - 1 , section: 0), at:.bottom, animated: false)
        }*/
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        if isPresented {
            self.dismiss(animated: true)
        }   else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if chatTextView.text.isEmpty {
            AppFunctions.showSnackBar(str: "Please enter message.")
        }else {
            sendMessageToUser()
        }
    }

    
    @IBAction func donateButtonAction(_ sender: UIButton) {
        /*if self.user.blocked_status == 1 {
            AlertController.alert(message: "User not found")
        }else if self.user.check_if_you_block == 1 {
            AlertController.alert(title: "", message: "You blocked this account. To donate unblock the user from settings.")
        }else {
        if let vc = UIStoryboard.wallet.get(DonateMoneyViewController.self){
            vc.userId = user.user_id
            vc.userName = "\(user.username ?? "")"
            // \(user.last_name ?? "")"
            vc.userImage = user.image
            navigationController?.pushViewController(vc, animated: true)
        }
        }*/
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - UITableViewDelegateDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = chats[indexPath.row]
        Logs.show(message:  "UserID: " + AppFunctions.getUserID())
        if obj.sender_id == AppFunctions.getUserID() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderChatCell", for: indexPath) as! SenderChatCell
            cell.populateCell(obj: obj)
            cell.vc = self
            cell.shapeView.setNeedsDisplay()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverChatCell", for: indexPath) as! ReceiverChatCell
            cell.populateCell(obj: obj)
            cell.shapeView.setNeedsDisplay()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //pagination
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.frame.size.height + scrollView.contentOffset.y) >= scrollView.contentSize.height{
            //  self.offset = offset + 10
            if isMoreData {
                // getMessageHistory()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
}

//MARK: - decription and encryption
extension String {
    
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self.replacingOccurrences(of: "\n", with: "")) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension ChatViewController : UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard var str = textView.text, let range = Range(range, in: str) else { return true }
        str = str.replacingCharacters(in: range, with: text)
        
        let numLines = Double(textView.contentSize.height) / Double(textView.font?.lineHeight ?? 16)
        textView.isScrollEnabled = numLines > 6
        self.view.layoutSubviews()
        DispatchQueue.main.async {
            self.scrollToBottom()
        }
        
        return true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
    }
    
}

extension ChatViewController  {
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
            let alert  = UIAlertController(title: "Warning", message: "Don't have camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            //self.file = AttachmentInfo(withImage: pickedImage.compressImage(compressionQuality: 0.5, image: pickedImage) , imageName: "profile_pic")
            //sendMessageToUser()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController {
    
    func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let jsonData = try JSONEncoder().encode(value)
        return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
    }
    
    func sendMessageToUser() {
        //
        var dictModel = [String:Any]()
        var dictModelChat = [String:Any]()
        var dictModelChatArray = [[String:Any]]()
       
        var chat = [String:Any]()
        chat["sender_id"] = AppFunctions.getUserID()
        chat["receiver_id"] = user1.keys.count > 0 ? user1["receiver_id"] as? String : chatModel.receiver_id
        chat["name"] = user1.keys.count > 0 ? user1["name"] as? String : chatModel.name
        chat["message"] = chatTextView.text
        chat["time"] = "\(Date())"
        
        do {
            for c in chats {
                dictModelChat = try encode(c)
                dictModelChatArray.append(dictModelChat)
            }
            dictModelChatArray.append(chat)
            Logs.show(message: " C Model: \(dictModelChat) \n ---- \n Arr \(dictModelChatArray)")
        } catch(let error) {
            Logs.show(message: "Model E: \(error)")
        }
        
        
        if user1.keys.count > 0 {
            user1["chatMessages"] = dictModelChatArray
            Logs.show(message: "Model: \(user1)")
        } else {
            do {
                dictModel = try encode(chatModel)
                dictModel["chatMessages"] = dictModelChatArray
                Logs.show(message: "Model: \(dictModel)")
            } catch(let error) {
                Logs.show(message: "Model E: \(error)")
            }
        }

        db.collection("ChatUsers").document(user1.keys.count > 0 ? user1["chatChannelId"] as! String : chatModel.chatChannelId).setData(user1.keys.count > 0 ? user1 : dictModel)
        chatTextView.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //self.getMessageHistory()

        }
    }
    
    func messagesListner() {
        
        var chanelId = ""
        if user1.keys.count > 0 {
            chanelId = user1["chatChannelId"] as! String
        } else {
            chanelId = chatModel.chatChannelId
        }
        
        db.collection("ChatUsers").document(chanelId).addSnapshotListener({ [weak self] (document, error) in
            if let document = document, document.exists {
                
                Logs.show(message: "CHAT: \(document)")
                let decoder = JSONDecoder()
                let dict = document.data()
                if let data = try?  JSONSerialization.data(withJSONObject: dict!, options: []) {
                    do {
                        let chat = try decoder.decode(ChatModel.self, from: data)
                        self?.chatModel = chat
                        Logs.show(message: "CHAT Model: \(String(describing: self?.chatModel.name))")
                        
                        if chat.chatMessages != nil {
                            self?.chats.removeAll()
                            self?.chats.append(contentsOf: (self?.chatModel.chatMessages)!)
                            Logs.show(message: "CHAT Model + Messages: \(self?.chatModel.name ?? "") -- \(self?.chats.count)")
                            
                            self?.tableView.reloadData()
                        }
                        
                    } catch (let error) {
                        Logs.show(message: "No user: \(error)")
                    }
                }
                
            } else {
                Logs.show(message: "No chat")
            }
        })
    }
    
    func getMessageHistory(){
        
        var chanelId = ""
        if user1.keys.count > 0 {
            chanelId = user1["chatChannelId"] as! String
        } else {
            chanelId = chatModel.chatChannelId
        }
        
        let collectionRef = db.collection("ChatUsers").document(chanelId)
        
        collectionRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                
                Logs.show(message: "CHAT: \(document)")
                let decoder = JSONDecoder()
                let dict = document.data()
                if let data = try?  JSONSerialization.data(withJSONObject: dict!, options: []) {
                        do {
                            let chat = try decoder.decode(ChatModel.self, from: data)
                            self?.chatModel = chat
                            Logs.show(message: "CHAT Model: \(String(describing: self?.chatModel.name))")

                            if chat.chatMessages != nil {
                                self?.chats.removeAll()
                                self?.chats.append(contentsOf: (self?.chatModel.chatMessages)!)
                                Logs.show(message: "CHAT Model + Messages: \(self?.chatModel.name ?? "") -- \(self?.chats.count)")
                                
                                self?.tableView.reloadData()
                            }
                           
                        } catch (let error) {
                            Logs.show(message: "No user: \(error)")
                        }
                    }
                
            } else {
                Logs.show(message: "No chat")
            }
        }
        
    }
    
}


