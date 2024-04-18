//
//  FriendRequestViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 27/10/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class FriendRequestViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var followRequests = [NotificationModel]()
    var offset = 0
    var isMoreData = true
    
    
    //MARK:- UIViewController Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequestNotificationList()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}

extension FriendRequestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestTableViewCell") as! FollowRequestTableViewCell
        cell.cellSetup(obj: followRequests[indexPath.row])
        cell.crossCompletion = {
            self.acceptRejectRequestUser(obj: self.followRequests[indexPath.row], accept: false, index: indexPath.row)
        }
        
        cell.acceptCompletion = {
            self.acceptRejectRequestUser(obj: self.followRequests[indexPath.row], accept: true, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
            vc.user.user_id  = followRequests[indexPath.row].who_followed_user_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView.frame.size.height + scrollView.contentOffset.y) >= scrollView.contentSize.height{
            if isMoreData {
                self.offset = offset + 10
                getRequestNotificationList()
            }
        }
    }
}


extension FriendRequestViewController {
    func getRequestNotificationList(){
        var param = [String: Any]()
        param["limit"] = 10
        param["offset"] = offset
        WebServices.getRequestNotificationList(params: param) { (response) in
            if let arr = response?.array {
                if self.offset == 0 {
                    self.followRequests = arr
                }else {
                    if arr.count == 0 {
                        self.isMoreData = false
                    }
                    self.followRequests.append(contentsOf: arr)
                }
                
                if self.followRequests.count == 0 {
                    noDataFound(message: "No Data Found", tableView: self.tableView,tag: 101)
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
    
    func acceptRejectRequestUser(obj: NotificationModel, accept: Bool,index: Int){
        var param  = [String: Any]()
        param["primary_key_follow_id"] = obj.primary_key_follow_id
        param["follow_status"] = accept ? "1" : "2"
        
        WebServices.acceptRejectRequest(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.is_following = obj.is_following == 0 ? 1 : 0
                self.followRequests.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }
}
