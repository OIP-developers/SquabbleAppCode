//
//  FollowBaseViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 14/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import CarbonKit

class FollowBaseViewController: UIViewController {
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var navLabel: UILabel!
    
    var carbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    var followType: FollowType = .followers
    var user = User()
    var followingUserList = [FollowUsers()]
    var followerUserList = [FollowUsers()]
    var isMyProfile = true
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        carbonKitSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserProfile()
    }
    
    //MARK:- Helper Method
    
    func customSetup(){
        navLabel.text = user.username ?? ""
        if user.user_followers ?? 0 > 1 {
            followerLabel.text = "\(voteFormatPoints(num: Double(user.user_followers ?? 0))) Followers"
        }else {
            followerLabel.text = "\(voteFormatPoints(num: Double(user.user_followers ?? 0))) Follower"
        }
        
        if user.user_followings ?? 0 > 1 {
            followingLabel.text = "\(voteFormatPoints(num: Double(user.user_followings ?? 0))) Following"
        }else {
            followingLabel.text = "\(voteFormatPoints(num: Double(user.user_followings ?? 0))) Following"
        }
        
    }
    
    func carbonKitSetup(){
        let items = ["Follwing","Follower"]
        self.carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
        self.carbonTabSwipeNavigation.setTabBarHeight(0)
        self.carbonTabSwipeNavigation.setIndicatorHeight(0)
        self.carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: self.containerView)
        self.updateTabUIOnSelection(index: followType == .followers ? 0 : 1)
    }
    
    func deselectTab() {
        followerView.backgroundColor = .clear
        followingView.backgroundColor = .clear
        followerLabel.textColor = KAppGrayColor
        followingLabel.textColor = KAppGrayColor
    }
    
    func updateTabUIOnSelection(index: Int) {
        deselectTab()
        switch index {
        case 0:
            followerView.backgroundColor = .white
            followerLabel.textColor = .white
            carbonTabSwipeNavigation.setCurrentTabIndex(0, withAnimation: true)
            break
            
        default:
            followingView.backgroundColor = .white
            followingLabel.textColor = .white
            carbonTabSwipeNavigation.setCurrentTabIndex(1, withAnimation: true)
            break
        }
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    @IBAction func inviteButtonAction(_ sender: UIButton){
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if let vc = UIStoryboard.profile.get(FindFriendsViewController.self){
                self.navigationController?.pushViewController(vc, animated: true)
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
    @IBAction func followerButtonAction(_ sender: UIButton){
        self.updateTabUIOnSelection(index: 0)
    }
    @IBAction func followingButtonAction(_ sender: UIButton){
        self.updateTabUIOnSelection(index: 1)
    }
}

// MARK: - Delegates
extension FollowBaseViewController  : CarbonTabSwipeNavigationDelegate  {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        switch index {
        case 0:
            if let vc  = UIStoryboard.profile.get(FollowViewController.self){
                vc.followType  = "following"
                vc.userId = user.user_id
                vc.userList = followingUserList
                vc.isMyProfile = self.isMyProfile
                vc.followCompletion = { status in
                    if status {
                        //self.getUserProfile()
                    }
                    return nil
                }
                return vc
            }
            
        default:
            if let vc  = UIStoryboard.profile.get(FollowViewController.self){
                vc.followType  = "follower"
                vc.userId = user.user_id
                vc.userList = followerUserList
                vc.isMyProfile = self.isMyProfile
                vc.followCompletion = { status in
                    if status {
                        //self.getUserProfile()
                    }
                    return nil
                }
                return vc
            }
        }
        return UIViewController()
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didFinishTransitionTo index: UInt) {
        updateTabUIOnSelection(index: Int(index))
    }
    
}

extension FollowBaseViewController {
    func getUserProfile(){
        var param = [String: Any]()
        param["other_user_id"] = user.user_id
        WebServices.getUserProfile(params: param) { (response) in
            if let obj = response?.object {
                self.user = obj
                self.customSetup()
            }
        }
    }
}
