//
//  NotificationViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    var notifications = [NotificationModel]()
    var followRequests = [NotificationModel]()
    var offset = 0
    var isMoreData = true
    var isFromRefresh = true
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(self.handleRefresh),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.refreshControl = self.refreshControl
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.offset = 0
        getRequestNotificationList()
        getNotificationList()
        getCountApi()
    }
    
    @objc func handleRefresh() {
        notifications.removeAll()
        followRequests.removeAll()
        self.offset = 0
        self.tableView.reloadData()
        self.isFromRefresh = true
        self.getNotificationList()
        self.getRequestNotificationList()
        self.refreshControl.endRefreshing()
    }
    
    func pullToRefersh() {
        refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        notifications.removeAll()
        followRequests.removeAll()
        self.offset = 0
        self.tableView.reloadData()
        self.getNotificationList()
        self.getRequestNotificationList()
        refreshControl.endRefreshing()
    }
    
    //MARK:- UIButton Action Method
    @IBAction func messageButtonAction(_  sender: UIButton){
        if let vc = UIStoryboard.message.get(MessageListViewController.self){
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func viewAllClicked(_ sender: UIButton){
        // Push to request screen
        if let vc = UIStoryboard.main.get(FriendRequestViewController.self){
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension NotificationViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationHeaderTableViewCell") as! NotificationHeaderTableViewCell
        cell.allButton.addTarget(self, action: #selector(viewAllClicked(_:)), for: .touchUpInside)
        
        switch section {
        case 0:
            cell.allButton.isHidden = self.followRequests.count == 0
            cell.headerLabel.text = self.followRequests.count == 0 ? "" : "Follow Requests"
        default:
            cell.allButton.isHidden = true
            cell.headerLabel.text = self.notifications.count == 0 ? "" : "Others"
        }
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.followRequests.count == 0 ? 1 : 30
        }else {
            return self.notifications.count == 0 ? 1 : 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? followRequests.count : self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestTableViewCell") as! FollowRequestTableViewCell
            cell.cellSetup(obj: followRequests[indexPath.row])
            cell.crossCompletion = {
                self.acceptRejectRequestUser(obj: self.followRequests[indexPath.row], accept: false, index: indexPath.row)
            }
            
            cell.acceptCompletion = {
                self.acceptRejectRequestUser(obj: self.followRequests[indexPath.row], accept: true, index: indexPath.row)
            }
            return cell
        }else {
            
            let obj = self.notifications[indexPath.row]
            switch obj.notification_type {
            case Constants.kNEW_CHALLENGE_POSTED,Constants.kMONTHLY_CHALLENGE_VOTING_OPEN,Constants.kWEEKLY_CHALLENGE_VOTING_OPEN, Constants.kSIZZLE_SHOWCASEHOUR_DAILY,Constants.kLIVE_STREAMING_ON,Constants.kLIVE_STREAMING_END,Constants.kSUBMISSION_OPEN,Constants.kDAILY_CHALLENGE_VOTING_OPEN:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationChallengeTableViewCell", for: indexPath) as! NotificationChallengeTableViewCell
                cell.titleLabel.attributedText = obj.body?.getAttributedString(obj.challenge_title ?? "", color: .white, font: Fonts.Rubik.regular.font(.medium))
                cell.timeLabel.text = Utility.getTodayDateIsSimilar(format: "MM/dd/yyyy", otherDate: Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")) ? Utility.getTime(Int(obj.created_at ?? "") ?? 0) : Utility.getDateFromTimeStamp(timeStamp: obj.created_at ?? "", format: "MM/dd/yyyy")
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationFollowTableViewCell", for: indexPath) as! NotificationFollowTableViewCell
                cell.cellSetup(obj: self.notifications[indexPath.row] )
                cell.followButton.tag = indexPath.row
                cell.followButton.addTarget(self, action: #selector(followButtonAction(_ :)), for: .touchUpInside)
                return cell
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
            if indexPath.section == 0{
                self.deleteRequest(obj: self.followRequests[indexPath.row], index: indexPath.row)
            }else {
                self.deleteNotification(obj: self.notifications[indexPath.row])
            }
        }
        deleteAction.image = UIImage.init(named: "icn_cross")
        deleteAction.backgroundColor = RGBA(9, g: 9, b: 9, a: 1.0)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                vc.user.user_id  = self.followRequests[indexPath.row].who_followed_user_id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else {
            let obj = self.notifications[indexPath.row]
           
            switch obj.notification_type {
            case Constants.kVIDEO_SHARE:
                
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.isShareVideo = true
                    vc.videoId = obj.video_id ?? ""
                    vc.shareMessage = obj.share_message ?? ""
                    vc.videoType = .gallery
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case Constants.kUSER_FOLLOW,Constants.kACCEPTED_REQUEST:
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.user.user_id  = obj.who_followed_user_id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case Constants.kVIDEO_VOTE:
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.isShareVideo = true
                    vc.videoId = obj.video_id ?? ""
                    vc.shareMessage = obj.share_message ?? ""
                    vc.challenge_id = obj.challenge_id ?? "0"
                    vc.videoType = .gallery
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case Constants.kVIDEO_TAG:
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.isFromTagVideo = true
                    vc.videoId = obj.video_id ?? ""
                    vc.challenge_id = obj.challenge_id ?? "0"
                    vc.videoType = .gallery
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case Constants.kLIVE_STREAMING_ON:
                    print("")
//                if let vc = UIStoryboard.main.get(LiveWinnerViewController.self){
//                    vc.token  = obj.token ?? ""
//                    vc.encoded_token = obj.encoded_token ?? ""
//                    vc.challengeId = obj.challenge_id ?? ""
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
            case Constants.kLIVE_STREAMING_END:
                AlertController.alert(message: "Live streaming has been finished.")
                
            case Constants.kWINNER_ANNOUNCEMENT,Constants.kWINNER_NOTIFIED:
                if obj.blocked_status == 1 {
                    AlertController.alert(message: "User not found.")
                } else if obj.check_if_you_block == 1 {
                    AlertController.alert(title: "", message: "You blocked this account. To watch video unblock the user from settings.")
                }else {
                
                if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self){
                    vc.videoObj.aws_video_path = obj.video_path
                    vc.videoObj.video_thumbnail = obj.video_thumbnail
                    vc.videoObj.intro_video_path = obj.intro_video_path
                    vc.videoObj.intro_video_thumbnail = obj.intro_video_thumbnail
                    vc.user_id = obj.user_id ?? ""
                    vc.videoType = .winningVideo
                    vc.isShareVideo = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                }
            case Constants.kNEW_CHALLENGE_POSTED:
                let dateSt = "\(Date().toMillis() ?? 0)"
                if Int(obj.end_timestamp ?? "0") ?? 0 > Int(dateSt) ?? 0 {
                    AlertController.alert(message: "Challenge is expired.")
                }else {
                    if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.navigationBar.isHidden = true
                        APPDELEGATE.navigationController = navigationController
                        APPDELEGATE.window?.rootViewController = navigationController
                    }
                }
            case Constants.kMONTHLY_CHALLENGE_VOTING_OPEN, Constants.kSIZZLE_SHOWCASEHOUR_DAILY,Constants.kWEEKLY_CHALLENGE_VOTING_OPEN,Constants.kMANUAL_NOTIFICATION,Constants.kSUBMISSION_OPEN,Constants.kDAILY_CHALLENGE_VOTING_OPEN:
                if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                    let navigationController = UINavigationController(rootViewController: vc)
                    navigationController.navigationBar.isHidden = true
                    APPDELEGATE.navigationController = navigationController
                    APPDELEGATE.window?.rootViewController = navigationController
                }
                
            case Constants.kMONEY_ADDED_TO_WALLET,Constants.kWITHDRAW_MONEY_FROM_WALLET,Constants.kREFUND_TO_WALLET,Constants.kRANDOM_VOTER_PRIZE,Constants.kWITHDRAW_MONEY_REQUEST_APPROVED,Constants.kDONATION_SENT,Constants.kDONATION_RECEIVED, Constants.kGIFT_PURCHASED:
                if let vc = UIStoryboard.wallet.get(WalletViewController.self){
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case Constants.kGOT_NEW_BADGE:
                if let vc = UIStoryboard.profile.get(BadgeShareViewController.self){
                    vc.badgeName  = obj.badge_title
                    vc.imageName = obj.badge_thumbnail
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case Constants.kREWARD_CLAIMED:
                if let vc = UIStoryboard.main.get(MyRewardsViewController.self){
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            default:
                break
            }
        }
    }
    
    @objc func followButtonAction(_ sender: UIButton) {
        let obj = self.notifications[sender.tag]
        self.followUnfollowUser(obj: obj)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height) {
            if isMoreData,!isFromRefresh {
                self.offset = offset + 10
                self.getNotificationList()
            }
        }
    }
}

extension NotificationViewController {
    func getNotificationList(){
        var params = [String: Any]()
        params["limit"] = "20"
        params["offset"] = "\(offset)"
        WebServices.getNotification(params: params) { (response) in
            if let arr = response?.array {
                if self.offset == 0 {
                    self.notifications = arr
                }else {
                    if arr.count == 0 {
                        self.isMoreData = false
                    }
                    self.notifications.append(contentsOf: arr)
                }
                self.isFromRefresh = false
                self.tableView.reloadData()
                if  self.notifications.count == 0 && self.followRequests.count == 0{
                    noDataFound(message: "No Notification Found", tableView: self.tableView,tag: 101)
                    self.tableView.backgroundView?.isHidden = false
                }else {
                    if self.tableView.backgroundView?.tag == 101 {
                        self.tableView.backgroundView?.isHidden = true
                    }
                }
            }
        }
    }
    
    func getRequestNotificationList(){
        var param = [String: Any]()
        param["limit"] = 2
        param["offset"] = 0
        WebServices.getRequestNotificationList(params: param) { (response) in
            if let arr = response?.array {
                self.followRequests = arr
                self.tableView.reloadData()
                
            }
        }
    }
    
    
    
    func deleteNotification(obj: NotificationModel){
        var param = [String: Any]()
        param["notification_id"] = obj.notification_id
        
        WebServices.deleteNotification(params: param) { (response) in
            if response?.statusCode == 200 {
                for (index,item) in self.notifications.enumerated() {
                    if item.notification_id == obj.notification_id {
                        self.notifications.remove(at: index)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    func deleteRequest(obj: NotificationModel,index: Int){
        var param = [String: Any]()
        param["primary_key_follow_id"] = obj.primary_key_follow_id
        
        WebServices.deleteRequest(params: param) { (response) in
            if response?.statusCode == 200 {
                self.followRequests.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }
    
    func clearNotification(){
        
        WebServices.clearNotification(params: [:]) { (response) in
            if response?.statusCode == 200 {
            }
        }
    }
    
    
    
    func followUnfollowUser(obj: NotificationModel){
        var param  = [String: Any]()
        param["follow_status"] = obj.is_following == 0 ? 1  : 0
        param["following_id"] = Int(obj.who_followed_user_id ?? "0")
        
        WebServices.followUnfollowUser(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.is_following = obj.is_following == 0 ? 1 : 0
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
                self.followRequests.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }
    
    
    func getCountApi(){
        WebServices.getCounts { (response) in
            if let obj = response?.object {
                self.messageCountLabel.isHidden = obj.unread_chat_count == 0
                self.messageCountLabel.text = "\(obj.unread_chat_count ?? 0)"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationCount"), object: nil, userInfo: nil)
            }
        }
    }
}

