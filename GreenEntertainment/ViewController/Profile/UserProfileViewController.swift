//
//  UserProfileViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//


import UIKit
import MKToolTip
import RxSwift

class UserProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tiktokButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var trophyButton: UIButton!
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var trophyLabel: UILabel!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var trophyView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageStatusView: UIView!
    @IBOutlet weak var navLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var badgeTableView: UITableView!
    
    
    var videoType: VideoType = .myPost
    var cellHeight = 0
    var user = User()
    var isFromSwipe = false
    var backCompletion: ((Int) -> Void)? = nil
    var blockCompletion: ((Int) -> Void)? = nil

    var followingUserList = [FollowUsers()]
    var followerUserList = [FollowUsers()]
    var badge_thumbnail = [BadgeModel()]
    
    var videoList = [VideosModel]()
    var dispose_Bag = DisposeBag()
    
    var index = 0
    var user_id = ""
    
    var firstRowBadge = [Badge]()
    var secondRowBadge = [Badge]()
    var thirdRowBadge = [Badge]()
    
    var isFromVideoSearch = false
    var isFromHome = false

    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customiseView()
        getUserProfile()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromSwipe {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
            swipeGesture.direction = .right
            self.view.addGestureRecognizer(swipeGesture)
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        
        switch gesture.direction {
        case .right:
            self.backCompletion?(index)
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
        
    }
    
    
    //MARK:- Helper Method
    func customiseView(){
        trophyView.isHidden = true
        galleryView.isHidden = true
        trophyLabel.textColor = KAppGrayColor
        galleryLabel.textColor = KAppGrayColor
        profileImageView.layer.cornerRadius = 60
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = KAppDarkGrayColor.cgColor
    }
    
    
    func initialSetup(){
        followerLabel.text = "\(voteFormatPoints(num: Double(user.user_followers ?? 0)))"
        followingLabel.text = "\(voteFormatPoints(num: Double(user.user_followings ?? 0)))"
        followerCountLabel.text = (user.user_followers ?? 0) > 1 ? "Followers" : "Follower"
        // followingCountLabel.text = (user.user_followings ?? 0) > 1 ? "Followings" : "Following"
        if let url = URL(string: user.image ?? "") {
            self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
        getUsername()
        if user.is_following == 0, user.request_status == "" {
            self.followButton.isSelected = false
            self.followButton.setTitle("Follow", for: .normal)
        }else if user.setting == "1", user.is_following == 0, user.request_status == "0" {
            self.followButton.setTitle("Requested", for: .normal)
        }else if user.is_following == 1{
            self.followButton.setTitle("Unfollow", for: .normal)
        }else {
            self.followButton.isSelected = false
            self.followButton.setTitle("Follow", for: .normal)
        }
        topConstraint.constant = user.claimed_badges_list.count > 0 ? 10 : 25
        
    }
    
    func setHeaderHeight(){
        if user.claimed_badges_list.count == 0 {
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 280)
        }
        else if user.claimed_badges_list.count > 0 && user.claimed_badges_list.count < 8 {
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 330)
        }else if  user.claimed_badges_list.count > 7 && user.claimed_badges_list.count < 15{
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 380)
        }else {
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 440)
        }
        self.view.layoutIfNeeded()
    }
    
    func getUsername(){
        DispatchQueue.global(qos: .background).async {
            do
            {
                if !"\(self.user.highest_badge ?? "")".isEmpty {
                    let data = try Data.init(contentsOf: URL.init(string:"\(self.user.highest_badge ?? "")")!)
                    DispatchQueue.main.async {
                        if let image: UIImage = UIImage(data: data) {
                            self.navLabel.attributedText = getTextWithBadge(name: self.user.username ?? "", image: image)
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        self.navLabel.text = self.user.username ?? ""
                    }
                }
            }
            catch {
                // error
            }
        }
    }
    
    func openVideoAction(obj: RewardsModel){
        if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
            vc.videoType = videoType
            vc.isOtherUser = true
            vc.videoType =  obj.is_save_to_gallery == "1" ? .myPost : .gallery
            vc.videoObj = obj
            vc.videoURL = URL(string: obj.video_path ?? "")
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func openVideoActionForTrophy(obj: RewardsModel){
        DispatchQueue.main.async {
            if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
                //vc.videoType =   .myTrophy
                vc.videoObj = obj
                vc.videoURL = URL(string: obj.video_path ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    
    func openPost(arr: [RewardsModel], obj: RewardsModel){
        if let vc = UIStoryboard.challenge.get(MyPostViewController.self) {
            vc.isMyProfile = false
            vc.videoType =   .gallery
            vc.videoArr = arr
            vc.videoId = obj.video_id ?? ""
            vc.userName = "\(self.user.first_name ?? "") \(self.user.last_name ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openTrophy(arr: [RewardsModel], obj: RewardsModel){
        if let vc = UIStoryboard.challenge.get(MyPostViewController.self) {
            vc.isMyProfile = false
            //vc.videoType =   .myTrophy
            vc.videoArr = arr
            vc.videoId = obj.video_id ?? ""
            vc.userName = "\(self.user.first_name ?? "") \(self.user.last_name ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupSocialMediaButton(){
        self.tiktokButton.isEnabled = !(user.tiktokUserName?.isEmpty ?? true )
        self.fbButton.isEnabled = !(user.fbUserName?.isEmpty ?? true )
        self.instaButton.isEnabled = !(user.instaUserName?.isEmpty ?? true )
        self.twitterButton.isEnabled = !(user.twitterUserName?.isEmpty ?? true )
        
    }
    
    
    func clearBadge(){
        self.firstRowBadge.removeAll()
        self.secondRowBadge.removeAll()
        self.thirdRowBadge.removeAll()
    }
    //MARK:- UIButton Method
    @IBAction func donateButtonAction(_  sender: UIButton){
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if let vc = UIStoryboard.wallet.get(DonateMoneyViewController.self){
                vc.userId = user.user_id
                vc.userName = "\(user.username ?? "")"
                vc.userImage = user.image
                navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func backButtonAction(_  sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func messageButtonAction(_  sender: UIButton){
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if  user.setting == "2" || user.is_following == 1 {
                if let vc = UIStoryboard.message.get(ChatViewController.self){
                    //vc.user = user
                    navigationController?.pushViewController(vc, animated: true)
                }
            }else if user.request_status == "0" {
                AlertController.alert(message: "\(self.user.first_name ?? "") \(ValidationMessage.RequestedFollow.rawValue)")
            }else {
                AlertController.alert(title: ValidationMessage.FollowTitleMessage.rawValue, message: ValidationMessage.FollowMessage.rawValue)
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
    
    @IBAction func tiktokButtonAction(_  sender: UIButton){
        if let tiktok_url = user.tiktokUserName, !tiktok_url.isEmpty {
            guard let tiktok = URL(string: "https://www.tiktok.com/\(tiktok_url)") else { return }
            let application = UIApplication.shared
            // Check if the Tiktok App is installed
            if application.canOpenURL(tiktok) {
                application.open(tiktok)
            } else {
                //If Tiktok App is not installed, open Safari with Snapchat Link
                application.open(URL(string: "https://www.tiktok.com/\(tiktok_url)")!)
            }
        }else  {
            AlertController.alert(message: "Tiktok account not linked.")
            
        }
    }
    
    @IBAction func fbButtonAction(_  sender: UIButton){
        
        if let fb_url = user.fbUserName , !fb_url.isEmpty{
            let application = UIApplication.shared
            if fb_url.contains(find: "id=") {
                let fb_urlArr = fb_url.components(separatedBy: "=")
                guard let facebook = URL(string: "fb://profile/?id=\(fb_urlArr[1])") else { return }
                
                // Check if the facebook App is installed
                if application.canOpenURL(facebook) {
                    application.open(facebook)
                } else {
                    // If Facebook App is not installed, open Safari with Facebook Link
                    if let fburl = user.fbUserName {
                        application.open(URL(string: fburl.isEmpty  ? "https://www.facebook.com"  : "https://www.facebook.com/\(fb_urlArr[1])")!)
                    }
                }
                
            }else if !fb_url.contains(find: "id=?") {
                
                if fb_url.contains(find: "facebook.com/") {
                    let fb_urlArr = fb_url.components(separatedBy: "com/")
                    guard let facebook = URL(string: "fb://profile/?id=\(fb_urlArr[1])") else { return }
                    
                    // Check if the facebook App is installed
                    if application.canOpenURL(facebook) {
                        application.open(facebook)
                    } else {
                        // If Facebook App is not installed, open Safari with Facebook Link
                        if let fburl = user.fbUserName {
                            application.open(URL(string: fburl.isEmpty  ? "https://www.facebook.com"  : "https://www.facebook.com/\((fb_urlArr[1]))")!)
                        }
                    }
                    
                }else {
                    guard let facebook = URL(string: "fb://profile/?id=\(fb_url)") else { return }
                    
                    // Check if the facebook App is installed
                    if application.canOpenURL(facebook) {
                        application.open(facebook)
                    } else {
                        // If Facebook App is not installed, open Safari with Facebook Link
                        if let fburl = user.fbUserName {
                            application.open(URL(string: fburl.isEmpty  ? "https://www.facebook.com"  : "https://www.facebook.com/\(fburl)")!)
                        }
                    }
                }
                
            }else {
                if let fburl = user.fbUserName {
                    application.open(URL(string: fburl.isEmpty  ? "https://www.facebook.com"  : "https://www.facebook.com/\(fburl)")!)
                }
            }
        }else {
            AlertController.alert(message: "Facebook account not linked.")
        }
        
    }
    
    @IBAction func twitterButtonAction(_  sender: UIButton){
        
        if let twitter_url = user.twitterUserName, !twitter_url.isEmpty {
            if twitter_url.contains(find: "twitter.com/") {
                
                let twitter_urlArr = twitter_url.components(separatedBy: "com/")
                
                guard let instagram = URL(string: "twitter://user?screen_name=\(twitter_urlArr[1])") else { return }
                let application = UIApplication.shared
                // Check if the facebook App is installed
                if application.canOpenURL(instagram) {
                    application.open(instagram)
                } else {
                    // If Facebook App is not installed, open Safari with Facebook Link
                    application.open(URL(string: "https://www.twitter.com/\(twitter_urlArr[1])")!)
                }
            }else {
                
                guard let twitter = URL(string: "twitter://user?screen_name=\(twitter_url)") else { return }
                let application = UIApplication.shared
                // Check if the facebook App is installed
                if application.canOpenURL(twitter) {
                    application.open(twitter)
                } else {
                    // If Facebook App is not installed, open Safari with Facebook Link
                    if let twitter_url = user.twitterUserName {
                        application.open(URL(string: "https://www.twitter.com/\(twitter_url)")!)
                    }
                }
            }
        }else {
            AlertController.alert(message: "Twitter account not linked.")
        }
        
    }
    
    @IBAction func instaButtonAction(_  sender: UIButton){
        
        if let instagram_url = user.instaUserName, !instagram_url.isEmpty {
            
            if instagram_url.contains(find: "instagram.com/") {
                
                let insta_urlArr = instagram_url.components(separatedBy: "com/")
                
                guard let instagram = URL(string: "instagram://user?username=\(insta_urlArr[1])") else { return }
                let application = UIApplication.shared
                // Check if the facebook App is installed
                if application.canOpenURL(instagram) {
                    application.open(instagram)
                } else {
                    // If Facebook App is not installed, open Safari with Facebook Link
                    application.open(URL(string: "http://instagram.com/\(insta_urlArr[1])")!)
                }
            }else {
                guard let instagram = URL(string: "instagram://user?username=\(instagram_url)") else { return }
                let application = UIApplication.shared
                // Check if the facebook App is installed
                if application.canOpenURL(instagram) {
                    application.open(instagram)
                } else {
                    // If Facebook App is not installed, open Safari with Facebook Link
                    application.open(URL(string: "http://instagram.com/\(instagram_url)")!)
                }
            }
        }else {
            AlertController.alert(message: "Instagram account not linked.")
        }
        
    }
    
    @IBAction func galleryButtonAction(_  sender: UIButton){
        trophyView.isHidden = true
        galleryView.isHidden = false
        postView.isHidden = true
        trophyLabel.textColor = KAppGrayColor
        galleryLabel.textColor = .white
        postLabel.textColor = KAppGrayColor
        videoType = .gallery
        tableView.reloadData()
    }
    
    @IBAction func postButtonAction(_  sender: UIButton){
        trophyView.isHidden = true
        postView.isHidden = false
        galleryView.isHidden = true
        trophyLabel.textColor = KAppGrayColor
        postLabel.textColor = .white
        galleryLabel.textColor = KAppGrayColor
        videoType = .myPost
        tableView.reloadData()
    }
    
    @IBAction func trophyButtonAction(_  sender: UIButton){
        trophyView.isHidden = true
        postView.isHidden = true
        galleryView.isHidden = true
        trophyLabel.textColor = .white
        postLabel.textColor = KAppGrayColor
        galleryLabel.textColor = KAppGrayColor
        //videoType = .myTrophy
        tableView.reloadData()
    }
    
    @IBAction func followButtonAction(_  sender: UIButton){
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if user.setting == "1" , user.is_following == 0, user.request_status == "0" {
                AlertController.alert(title: "Warning", message: "Are you sure you want to cancel follow request?", buttons: ["Yes","No"]) { (alert, index) in
                    if index == 0 {
                        self.acceptRejectRequestUser()
                    }
                }
            }
            
            else {
                followUnfollowUser()
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
    
    @IBAction func followerButtonAction(_  sender: UIButton){
        if let vc = UIStoryboard.profile.get(FollowBaseViewController.self){
            vc.followType = .followers
            vc.user = self.user
            vc.followerUserList = self.followerUserList
            vc.followingUserList = self.followerUserList
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func followingButtonAction(_  sender: UIButton){
        if let vc = UIStoryboard.profile.get(FollowBaseViewController.self){
            vc.followType = .following
            vc.user = self.user
            vc.followerUserList = self.followerUserList
            vc.followingUserList = self.followerUserList
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func blockButtonAction(_  sender: UIButton){
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            AlertController.alert(title: "", message: "Are you sure you want to block this user?", buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    self.blockUnblockUser()
                }
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

extension UserProfileViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == badgeTableView {
            if user.claimed_badges_list.count < 7 {
                return 1
            }else if user.claimed_badges_list.count > 8 &&  user.claimed_badges_list.count < 14 {
                return 2
            }else {
                return 3
            }
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == badgeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileBadgeTableViewCell") as! ProfileBadgeTableViewCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryTableViewCell") as! GalleryTableViewCell
            switch videoType {
            case .myPost:
                cell.cellSetup(arr: self.user.app_gallery_posts, type: videoType)
                cell.cellClicked = {
                    index in
                    DispatchQueue.main.async {
                        self.openPost(arr: self.user.app_gallery_posts, obj: self.user.app_gallery_posts[index.row])
                    }
                }
                break
            /*case .myTrophy:
                cell.cellSetupForTrophy(arr: self.user.user_trophy_videos, type: videoType)
                cell.cellClicked = {
                    index in
                    DispatchQueue.main.async {
                        self.openTrophy(arr: self.user.user_trophy_videos, obj: self.user.user_trophy_videos[index.row])
                    }
                }
                break*/
            default:
                break
            }
            cellHeight   =  Int(cell.collectionView.frame.width  / 2 + 60)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == badgeTableView {
            return 60
        }else {
            switch videoType {
            case .myPost,.gallery:
                return self.user.app_gallery_posts.count == 0 ? Window_Height - 440 : CGFloat(cellHeight  * (self.user.app_gallery_posts.count % 2 == 0 ? self.user.app_gallery_posts.count / 2 : (self.user.app_gallery_posts.count / 2) + 1 ))
            default:
                return self.user.user_trophy_videos.count == 0 ? Window_Height - 440 : CGFloat(cellHeight  * (self.user.user_trophy_videos.count % 2 == 0 ? self.user.user_trophy_videos.count / 2 : (self.user.user_trophy_videos.count / 2) + 1 ))
            }
        }
    }
}


extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return firstRowBadge.count
        }else if collectionView.tag == 1 {
            return secondRowBadge.count
        }else {
            return thirdRowBadge.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileBadgeCollectionViewCell", for: indexPath) as! ProfileBadgeCollectionViewCell
        if collectionView.tag == 0 {
            if let url = URL(string: firstRowBadge[indexPath.row].badge_thumbnail ?? "") {
                cell.badgeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
        }else if collectionView.tag == 1 {
            if let url = URL(string: secondRowBadge[indexPath.row].badge_thumbnail ?? "") {
                cell.badgeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
        }else {
            if let url = URL(string: thirdRowBadge[indexPath.row].badge_thumbnail ?? "") {
                cell.badgeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 45, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 0 {
            //  if firstRowBadge.count < 7 {
            let totalCellWidth = 50 * firstRowBadge.count
            let totalSpacingWidth = 1 * (firstRowBadge.count - 1)
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
            //  }
        }else if collectionView.tag == 1 {
            let totalCellWidth = 50 * secondRowBadge.count
            let totalSpacingWidth = 1 * (secondRowBadge.count - 1)
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
        else {
            let totalCellWidth = 50 * thirdRowBadge.count
            let totalSpacingWidth = 1 * (thirdRowBadge.count - 1)
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0 {
            let cell = collectionView.cellForItem(at: indexPath) as! ProfileBadgeCollectionViewCell
            let preference = ToolTipPreferences()
            preference.drawing.bubble.color = .darkGray
            cell.contentView.showToolTip(identifier: "", message: firstRowBadge[indexPath.row].title ?? "", arrowPosition: .bottom, preferences: preference, delegate: nil)
        }else if collectionView.tag == 1 {
            let cell = collectionView.cellForItem(at: indexPath) as! ProfileBadgeCollectionViewCell
            let preference = ToolTipPreferences()
            preference.drawing.bubble.color = .darkGray
            cell.contentView.showToolTip(identifier: "", message: secondRowBadge[indexPath.row].title ?? "", arrowPosition: .bottom, preferences: preference, delegate: nil)
        }else {
            let cell = collectionView.cellForItem(at: indexPath) as! ProfileBadgeCollectionViewCell
            let preference = ToolTipPreferences()
            preference.drawing.bubble.color = .darkGray
            cell.contentView.showToolTip(identifier: "", message: thirdRowBadge[indexPath.row].title ?? "", arrowPosition: .bottom, preferences: preference, delegate: nil)
        }
    }
    
}


extension UserProfileViewController {
    
    func getBadgeListData(){
        for (index,item) in user.claimed_badges_list.enumerated() {
            if index < 7 {
                self.firstRowBadge.append(item)
            }else if index > 6 && index < 14 {
                self.secondRowBadge.append(item)
            }else {
                self.thirdRowBadge.append(item)
            }
        }
        self.badgeTableView.reloadData()
        delay(delay: 0.1) {
            self.badgeTableView.reloadData()
        }
    }
    
    /*func getUserProfile(){
        var param = [String: Any]()
        param["other_user_id"] = user.user_id
        WebServices.getUserProfile(params: param) { (response) in
            if let obj = response?.object {
                self.user = obj
                self.clearBadge()
                self.initialSetup()
                self.getBadgeListData()
                self.setHeaderHeight()
                self.setupSocialMediaButton()
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }*/
    
    func getUserProfile() {
        
        APIService
            .singelton
            .getUserProfile(id: user_id)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            if val.follower != nil {
                                self.followerUserList = val.follower
                            }
                            if val.following != nil {
                                self.followingUserList = val.following
                            }
                            if val.badge != nil {
                                self.badge_thumbnail = val.badge
                            }
                            
                            self.followerLabel.text = "\(self.followerUserList.count)"
                            self.followingLabel.text = "\(self.followingUserList.count)"
                            
                            if (self.followerUserList.first != nil) {
                                Logs.show(message: "\(self.followerUserList.first?.id ?? "")")
                                if (self.followerUserList.first != nil) {
                                    Logs.show(message: "\(self.followerUserList.first?.email ?? "")")
                                }
                            }
                            
                            if (self.followingUserList.first != nil) {
                                Logs.show(message: "\(self.followingUserList.first?.id ?? "")")
                                if (self.followerUserList.first != nil) {
                                    Logs.show(message: "\(self.followerUserList.first?.email ?? "")")
                                }
                            }
                            
                            
                            
                            
                            self.collectionView.reloadData()
                        } else {
                            ProgressHud.hideActivityLoader()
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
    func followUnfollowUser(){
        var param  = [String: Any]()
        param["follow_status"] = self.user.is_following == 0 ? 1 : 0  //self.user.followingStatus ?? false ? 0 : 1
        param["following_id"] = Int(user.user_id ?? "0")
        
        WebServices.followUnfollowUser(params: param) { (response) in
            if response?.statusCode == 200 {
                self.getUserProfile()
            }
        }
    }
    
    func blockUnblockUser(){
        var param  = [String: Any]()
        param["flag"] = "1"
        param["other_user_id"] = Int(user.user_id ?? "0")
        
        WebServices.blockUnblockUser(params: param) { (response) in
            if response?.statusCode == 200 {
               // self.user.followingStatus = !(self.user.followingStatus ?? false)
                self.blockButton.isSelected = true
                if self.isFromVideoSearch {
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: SearchViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }else {
                    if self.isFromHome {
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: TabbarViewController.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }else {
                        self.blockCompletion?(Int(self.user.user_id ?? "0") ?? 0)
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
                

                
              //  self.initialSetup()
            }
        }
    }
    
    
    func acceptRejectRequestUser(){
        var param  = [String: Any]()
        param["primary_key_follow_id"] = user.primary_key_follow_id
        param["follow_status"] = "3"
        
        WebServices.acceptRejectRequest(params: param) { (response) in
            if response?.statusCode == 200 {
                self.user.request_status = ""
                self.user.is_following = 0
                self.initialSetup()
            }
        }
    }
}
