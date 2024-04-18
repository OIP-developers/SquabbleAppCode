//
//  ChallengeShareViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 17/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ChallengeShareViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var touchedView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: IQTextView!
    
    
    var users = [User]()
    var videoObj = RewardsModel()
    var videoId: String?
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserList()
        doneView.isHidden = true
        heightConstraint.constant = Window_Height / 2 + 150
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissView))
        self.touchedView.addGestureRecognizer(tap)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        // Do any additional setup after loading the view.
    }
    
    func sendStatus(item: User){
        delay(delay: 0.4) {
            self.doneView.isHidden = false
        }
        
        if item.selectedStatus == 1 {
            self.shareVideo(user: item)
        }
    }
    
    //MARK:- Target Method
    @objc func sendButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        let  obj = users[sender.tag]
        let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as? FollowTableViewCell
        
        if  obj.setting == "2" || obj.is_following == 1 {
            if obj.selectedStatus == 1 {
                obj.selectedStatus = 0
                cell?.timer.invalidate()
            }else {
                obj.selectedStatus = 1
                cell?.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                    let arr = self.users.filter{$0.selectedStatus == 1}
                    if arr.count > 0 {
                        self.sendStatus(item: obj)
                    }else {
                        self.doneView.isHidden = true
                    }
                    cell?.timer.invalidate()
                    
                })
            }
            
            tableView.reloadData()
        }else if obj.request_status == "0" {
            AlertController.alert(message: "\(obj.first_name ?? "") \(ValidationMessage.RequestedFollow.rawValue)")
        }else {
            AlertController.alert(title: ValidationMessage.FollowTitleMessage.rawValue, message: ValidationMessage.ShareMessage.rawValue)
        }
        
    }
    
    //MARK:- Target Method
    @objc func textFieldDidChange(_ textField: UITextField){
        if textField.text?.trimWhiteSpace.count ?? 0 > 1 {
            searchUsers()
        } else if textField.text == "" {
            getUserList()
        }
    }
    
    //MARK:- UIButton Method
    @IBAction func doneButtonAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissView(_ gesture: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChallengeShareViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        let obj = users[indexPath.row]
        cell.cellSetupForShare(obj: obj)
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(sendButtonAction(_ :)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension ChallengeShareViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            getUserList()
        }else {
            searchUsers()
        }
    }
}



extension ChallengeShareViewController {
    
    func getUserList() {
        
        var param = [String: Any]()
        param["type_id"] = "1"
        param["user_id"] = AuthManager.shared.loggedInUser?.user_id
        WebServices.getFollowerFollowing(params: param) { (response) in
            if let arr = response?.array {
                self.users = arr
                if self.users.count == 0 {
                    noDataFound(message: "No User Found", tableView: self.tableView,tag: 101)
                    self.tableView.backgroundView?.isHidden = false
                }else {
                    if self.tableView.backgroundView?.tag == 101 {
                        self.tableView.backgroundView?.isHidden = true
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func shareVideo(user: User){
        var param = [String: Any]()
        var arr  = [String]()
        arr.append(user.user_id ?? "")
        param["receiver_user_id"] = arr
        param["video_id"] = videoId
        param["share_message"] = messageTextView.text?.trimWhiteSpace.base64Encoded()
        user.selectedStatus = 2
        
        self.tableView.reloadData()
        WebServices.shareVideo(params: param) { (response) in
            if response?.statusCode ==  200 {
                for item in self.users {
                    if item.user_id == user.user_id {
                        item.selectedStatus = 2
                    }
                }
                self.tableView.reloadData()
            }else {
                user.selectedStatus = 0
            }
            self.tableView.reloadData()
        }
    }
    
    func searchUsers() {
        var param = [String: Any]()
        param["search_keyword"]  = searchTextField.text?.trimWhiteSpace
        
        WebServices.searchFollowUser(params: param) { (response) in
            if let arr = response?.array {
                self.users.removeAll()
                self.users = arr
                if arr.count == 0 {
                    noDataFound(message: "No User Found", tableView: self.tableView,tag: 101)
                    self.tableView.backgroundView?.isHidden = false
                }else {
                    if self.tableView.backgroundView?.tag == 101 {
                        self.tableView.backgroundView?.isHidden = true
                    }
                }
                self.users = self.users.sorted(by: { (obj1, obj2) -> Bool in
                    (obj1.username ?? "").lowercased() < (obj2.username ?? "").lowercased()
                })
                self.tableView.reloadData()
            }
        }
    }
}


extension ChallengeShareViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.textInputMode?.primaryLanguage == "emoji") || !((textView.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textView.text! as NSString
        str = str.replacingCharacters(in: range, with: text) as NSString
        
        if str.length > 100{
            return false
        }
        
        return true
    }
}
