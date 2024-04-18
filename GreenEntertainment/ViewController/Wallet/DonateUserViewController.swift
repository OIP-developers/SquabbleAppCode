//
//  DonateUserViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 05/01/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit

class DonateUserViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var followType: FollowType = .followers
    var userList = [User]()
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
    
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
}

extension DonateUserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        //cell.cellSetup(obj: userList[indexPath.row], type: followType, isMyProfile: self.isMyProfile)
        cell.followButton.isHidden = true
        cell.donateImageView.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = userList[indexPath.row]
        if let vc = UIStoryboard.wallet.get(DonateMoneyViewController.self){
            vc.userId = obj.user_id
            vc.userName = "\(obj.username ?? "")"
            vc.userImage = obj.image
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension DonateUserViewController {
    func getFollwerFollowingList() {
        
        var param = [String: Any]()
        param["type_id"] = "1"
        param["user_id"] = AuthManager.shared.loggedInUser?.user_id
        WebServices.getFollowerFollowing(params: param) { (response) in
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


