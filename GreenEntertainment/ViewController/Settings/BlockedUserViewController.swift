//
//  BlockedUserViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 09/04/21.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class BlockedUserViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var userList = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.getBlockedList()
        AppFunctions.showSnackBar(str: "You have no Blocked users yet.")
        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func unblockUser(_ sender: UIButton){
        let obj = userList[sender.tag]
        self.unblockUser(user: obj, index: sender.tag)
    }
}


extension BlockedUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        let obj = userList[indexPath.row]
        cell.nameLabel.text = obj.username
        if let url = URL(string: obj.image ?? "") {
            cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(unblockUser(_ :)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension BlockedUserViewController {
    
    func unblockUser(user: User, index: Int){
        var param  = [String: Any]()
        param["flag"] = "0"
        param["other_user_id"] = Int(user.user_id ?? "0")
        WebServices.blockUnblockUser(params: param) { (response) in
            if response?.statusCode == 200 {
                self.userList.remove(at: index)
                if self.userList.count == 0 {
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
   
    
    func getBlockedList() {
        WebServices.getBlockedUsers(params: [:]) { (response) in
            if let arr = response?.array {
                self.userList = arr
                if self.userList.count == 0 {
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
}
