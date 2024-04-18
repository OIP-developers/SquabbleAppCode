//
//  FindFriendsViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class FindFriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    var users = [User]()
    var searchUser = [User]()
    
    var workItemReference: DispatchWorkItem? = nil
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchView.isHidden  = true
        searchTextField.text = ""
    }
    
    //MARK:- Helper Method
    func customSetup(){
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        getUserList()
    }
    
    //MARK:- Target Method
    @objc func textFieldDidChange(_ textField: UITextField){
        searchView.isHidden  = false
        if textField.text?.trimWhiteSpace.count ?? 0 > 1 {
            workItemReference?.cancel()
            searchView.isHidden  = false
            let searchWorkItem = DispatchWorkItem {
                self.searchUsers()
            }
            workItemReference = searchWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: searchWorkItem)
            
            
          //  searchUsers()
        }
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
}

extension FindFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tableView == searchTableView ? searchUser.count : 1 + users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell") as! FollowTableViewCell
            let obj = searchUser[indexPath.row]
            if let url = URL(string: obj.image ?? "") {
                cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            }
            cell.nameLabel.text = obj.username
            
            return cell
        }else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell") as! InviteTableViewCell
                
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell") as! FollowTableViewCell
                let obj = users[indexPath.row - 1]
                if let url = URL(string: obj.image ?? "") {
                    cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
                }
                cell.nameLabel.text = obj.username
                cell.widthConstraint.constant = 0
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView {
            self.view.endEditing(true)
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                vc.user.user_id = searchUser[indexPath.row]
                    .user_id ?? ""
                navigationController?.pushViewController(vc, animated: true)
            }
        }else {
            if indexPath.row == 0 {
                if let vc = UIStoryboard.profile.get(InviteViewController.self){
                    navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.user.user_id = users[indexPath.row - 1]
                        .user_id ?? ""
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
    }
}

extension FindFriendsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            searchView.isHidden  = true
        }else {
            searchView.isHidden  = false
            searchUsers()
        }
    }
}


extension FindFriendsViewController {
    func getUserList(){
        WebServices.getUsersList { (response) in
            if let arr = response?.array {
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
    
    func searchUsers() {
        var param = [String: Any]()
        param["search_keyword"]  = searchTextField.text?.trimWhiteSpace
        
        WebServices.searchUser(params: param) { (response) in
            if let arr = response?.array {
                self.searchUser = arr
                if arr.count == 0 {
                    noDataFound(message: "No User Found", tableView: self.searchTableView,tag: 102)
                    self.searchTableView.backgroundView?.isHidden = false
                }else {
                    if self.searchTableView.backgroundView?.tag == 102 {
                        self.searchTableView.backgroundView?.isHidden = true
                    }
                }
                self.users = self.users.sorted(by: { (obj1, obj2) -> Bool in
                    (obj1.username ?? "").lowercased() < (obj2.username ?? "").lowercased()
                })
                self.searchTableView.reloadData()
            }
        }
    }
}
