//
//  FollowViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

enum FollowType {
    case followers
    case following
}

import UIKit

class FollowViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var followType: String = ""
    //var userList = [User]()
    var userList = [FollowUsers()]

    var userId: String?
    var isMyProfile = false
    var followCompletion:((Bool) -> Void?)? = nil
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFollwerFollowingList()
    }
    
}

extension FollowViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        cell.cellSetup(obj: userList[indexPath.row], type: followType, isMyProfile: self.isMyProfile)
        /*cell.followClicked = { status in
            switch self.followType {
            case .followers:
                self.followUser(user: self.userList[indexPath.row], index: indexPath.row)
            default:
                if !self.isMyProfile {
                    if self.userList[indexPath.row].is_following == 1 {
                        AlertController.alert(title: "", message: "Are you sure you want to unfollow?", buttons: ["Yes","No"]) { (alert, index) in
                            if index == 0 {
                                self.followUser(user: self.userList[indexPath.row], index: indexPath.row)
                            }
                        }
                    } else {
                        self.followUser(user: self.userList[indexPath.row], index: indexPath.row)
                        
                    }
                    
                }else {
                    if self.userList[indexPath.row].is_following == 1 {
                        AlertController.alert(title: "", message: "Are you sure you want to unfollow?", buttons: ["Yes","No"]) { (alert, index) in
                            if index == 0 {
                                self.followUser(user: self.userList[indexPath.row], index: indexPath.row)
                            }
                        }
                    }
                }
                
                break
            }
            
        }*/
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*if userList[indexPath.row].user_id == AuthManager.shared.loggedInUser?.user_id {
            UserDefaults.standard.set(true, forKey: "movetoProfile")
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                vc.user.user_id = userList[indexPath.row].user_id
                navigationController?.pushViewController(vc, animated: true)
            }
        }*/
    }
    
}


extension FollowViewController {
    func getFollwerFollowingList() {
        
        var param = [String: Any]()
        //param["type_id"] =  followType == .followers ? "2" : "1"
        //param["user_id"] = isMyProfile ? AuthManager.shared.loggedInUser?.user_id : userId
        WebServices.getFollowerFollowing(params: param) { (response) in
            /*if let arr = response?.array {
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
            }*/
        }
    }
    
    
    func followUnfollowUser(user: User, index: Int){
        var param  = [String: Any]()
        param["follow_status"] =  user.is_following == 1 ? 0  : 1 // user.followingStatus ?? false ? 0 : 1
        param["following_id"] = Int(user.user_id ?? "0")
        
        WebServices.followUnfollowUser(params: param) { (response) in
            if response?.statusCode == 200 {
                self.followCompletion?(true)
                if user.setting == "1" {
                    user.is_following =  0
                    user.request_status = "0"
                }else {
                    user.is_following = user.is_following == 1 ? 0  : 1
                }
                //if self.isMyProfile, user.is_following == 0 , self.followType == .following{
                  //  self.userList.remove(at: index)
                //}
                
                self.tableView.reloadData()
            }
        }
    }
    func acceptRejectRequestUser(user: User){
        var param  = [String: Any]()
        param["primary_key_follow_id"] = user.primary_key_follow_id
        param["follow_status"] = "3"
        
        WebServices.acceptRejectRequest(params: param) { (response) in
            if response?.statusCode == 200 {
                user.request_status = ""
                user.is_following = 0
                self.tableView.reloadData()
            }
        }
    }
}


extension FollowViewController {
    func followUser(user: User, index: Int){
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if user.setting == "1", user.is_following == 0, user.request_status == "0" {
                AlertController.alert(title: "Warning", message: "Are you sure you want to cancel follow request?", buttons: ["Yes","No"]) { (alert, index) in
                    if index == 0 {
                        self.acceptRejectRequestUser(user: user)
                    }
                }
            }
            else {
                self.followUnfollowUser(user: user, index: index)
            }
        }else {
            AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.navigationBar.isHidden = true
                        APPDELEGATE.navigationController = navigationController
                        APPDELEGATE.window?.rootViewController = navigationController
                    }
                }
            }
        }
    }
}
