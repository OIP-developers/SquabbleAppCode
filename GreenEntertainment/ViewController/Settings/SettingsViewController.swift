//
//  SettingsViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = ["Notification","My Rewards","Badges","Blocked User","Privacy","Share App","Suggestions","Report a problem","Tutorial","About Us","Terms & Conditions","Change Password","Sign Out"]
    var user = User()
    var notification = NotificationSetting()
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getNotificationSetting()
        
    }
    
    //MARK:- Helper Method
    func shareApp(text: String, image: UIImage) {
        let shareAll = [text , image] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
        ]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK:- Target Method
    @objc func notificationButtonAction(_ sender: UIButton){
        //updateNotificationSetting()
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! SettingsTableViewCell
        if sender.imageView?.image == UIImage(named: "icn_notification_on") {
            UIApplication.shared.unregisterForRemoteNotifications()
            cell.rightButton.setImage(UIImage(named:  "icn_notification_off"), for: .normal)
        } else {
            UIApplication.shared.registerForRemoteNotifications()
            cell.rightButton.setImage(UIImage(named:  "icn_notification_on"), for: .normal)
        }

    }
    
    //MARK:- UIButton Method
    @IBAction func backButtonAction(_  sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}

extension SettingsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        if indexPath.row == 0 {
            cell.rightButton.setImage(UIImage(named:  "icn_notification_on"), for: .normal)
            cell.rightButton.tag = indexPath.row
            cell.rightButton.isUserInteractionEnabled = true
            cell.rightButton.addTarget(self, action: #selector(notificationButtonAction(_ :)), for: .touchUpInside)
        }else {
            cell.rightButton.setImage(UIImage(named:"icn_arrow_forwrd"), for: .normal)
        }
        cell.titleLabel.text = titleArray[indexPath.row]
        if indexPath.row == 2 {
            //  cell.countLabel.isHidden = notification.show_flag == "1"
            cell.countLabel.isHidden = notification.badge_count == 0
            cell.countLabel.text = "\(notification.badge_count ?? 0)"
        }else if indexPath.row == 1 {
            cell.countLabel.isHidden = notification.reward_not_claimed == 0
            cell.countLabel.text = "\(notification.reward_not_claimed ?? 0)"
        }  else {
            cell.countLabel.isHidden = true
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 9 ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            updateNotificationSetting()
            break
        case 1:
            
            if let vc = UIStoryboard.main.get(MyRewardsViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2:
            if let vc = UIStoryboard.profile.get(BadgeListViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 3: if let vc = UIStoryboard.profile.get(BlockedUserViewController.self){
            navigationController?.pushViewController(vc, animated: true)
        }
        break
        case 4:
            if let vc = UIStoryboard.main.get(PrivacyViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        //        case 4:
        //            if let vc = UIStoryboard.profile.get(BlockedUserViewController.self){
        //                navigationController?.pushViewController(vc, animated: true)
        //            }
        //            break
        case 5:
            shareApp(text: "Hey,\n\n\(AuthManager.shared.loggedInUser?.username ?? "") invites you to join Squabble.\n\nAndroid app link:\nhttps://play.google.com/store/apps/details?id=com.green.squabble\n\niOS Link:\nhttps://apps.apple.com/us/app/squabble-win/id1561097344", image: UIImage())
            break
        case 6:
            if let vc = UIStoryboard.main.get(ContactUsViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
        case 7:
            if let vc = UIStoryboard.main.get(UserSuggestionsViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
            
            break
        case 8:
            if let vc = UIStoryboard.auth.get(WalkthroughViewController.self){
                vc.isFromSetting = true
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 9:
            if let vc = UIStoryboard.auth.get(StaticContentViewController.self){
                vc.screentype = .aboutus
                vc.isFromSetting = true
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 10:
            if let vc = UIStoryboard.auth.get(StaticContentViewController.self){
                vc.screentype = .termsAndCondition
                vc.isFromSetting = true
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 11:
            if let vc = UIStoryboard.auth.get(ChangePasswordViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        default:
            DispatchQueue.main.async {
                if let vc = UIStoryboard.profile.get(LogoutPopupViewController.self) {
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .crossDissolve
                    vc.signoutCompletion = { status in
                        if status {
                            self.callLogout()
                        }
                    }
                    self.navigationController?.present(vc, animated: false, completion: nil)
                }
            }
            break
        }
    }
    
}

extension SettingsViewController {
    func callLogout(){
        UserDefaults.standard.set(false, forKey: "loggedInUser")
        UserDefaults.standard.synchronize()
        let user = AuthManager.shared.loggedInUser
        AuthManager.shared.loggedInUser = user
        AuthManager.shared.loggedInUser  = nil
        if let vc = UIStoryboard.auth.get(LoginViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    func getNotificationSetting(){
        WebServices.getNotificationSetting { (response) in
            if let obj = response?.object{
                self.notification = obj
                self.tableView.reloadData()
            }
        }
    }
    
    func updateNotificationSetting(){
        var param = [String: Any]()
        param["receive_notification"] = notification.status ? "I" : "A"
        WebServices.updateNotificationSetting(params: param) { (response) in
            if response?.statusCode == 200 {
                if let obj = response?.object {
                    self.notification = obj
                    self.getNotificationSetting()
                }
            }
        }
    }
}
