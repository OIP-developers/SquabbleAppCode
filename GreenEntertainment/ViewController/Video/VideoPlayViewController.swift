//
//  VideoPlayViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 10/09/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import FTPopOverMenu_Swift
import ActiveLabel


class VideoPlayViewController: UIViewController {
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    var aVAudioPlayer: AVAudioPlayer?
    
    var isPlaying = true
    var completion: (() -> Void)?  = nil
    
    var player = AVPlayer()
    var videoFinshed = false
    var backButtonTapped = false
    var challengesArr = [RewardsModel]()
    var videoId = ""
    var timer = Timer()
    var challenge_id = "0"
    var isFromVote = false
    var safeHeight : CGFloat?
    
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        safeHeight = UIApplication.shared.delegate?.window??.safeAreaInsets.top
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        customSetup()
        collectionView.contentInsetAdjustmentBehavior = .never /// to fill up safeare space
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //  self.removeFromParent()
        
        for item in challengesArr {
            item.player?.pause()
            item.player?.replaceCurrentItem(with: nil)
            item.player = nil
            item.removeObserver()
        }
        
        // challengesArr.removeAll()
    }
    
    //MARK:- Helper Method
    
    func removeAllObject(){
        NotificationCenter.default.removeObserver(self)
        for item in challengesArr {
            item.player?.pause()
            item.player?.replaceCurrentItem(with: nil)
            item.player = nil
            item.removeObserver()
        }
        //  challengesArr.removeAll()
        
    }
    
    deinit {
        removeAllObject()
    }
    
    //MARK:- Helper Method
    func customSetup(){
        self.animationImage.isHidden = true
        self.animationView.isHidden = true
        if self.challengesArr.count != 0 {
            if self.challengesArr[0].player == nil {
                if let url = URL(string: self.challengesArr[0].video_path ?? "") {
                    self.challengesArr[0].player = AVPlayer(url: url)
                    self.challengesArr[0].isPlayed = true
                    if (self.challengesArr[0].player?.rate ?? 1) == 0 {
                        self.challengesArr[0].player?.play()
                    }
                    self.challengesArr[0].removeObserver()
                    self.challengesArr[0].addObserver()
                }
            }
            self.challengesArr[0].player?.play()
        }
        self.collectionView.reloadData()
    }
    
    
    //video player methods
    @objc func playPauseButtonAction(_ sender: UIButton) {
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!ChallengeListCollectionViewCell
        let obj = challengesArr[sender.tag]
        if(videoFinshed && !backButtonTapped){
            videoFinshed = false
            //            isPlay = true
            //  setUpVideoPlayerViewController(cell: cell)
        }else if cell.player.timeControlStatus == .playing  {
            //                  isPlay = false
            obj.isPlayed = true
            // print("sdsd",obj.isPlayed)
            isPlaying = false
            obj.player?.pause()
            cell.tapBackwardButton.isHidden = false
            cell.tapForwardButton.isHidden = false
            
            cell.playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
            cell.tapForwardButton.setImage(UIImage.init(named: "icn_forward"), for: .normal)
            cell.tapBackwardButton.setImage(UIImage.init(named: "icn_backward"), for: .normal)
            
        }else {
            //            isPlay = true
            backButtonTapped = false
            // cell.isPlayed = true
            // obj.isPlayed = false
            isPlaying = false
            obj.player?.play()
            cell.tapBackwardButton.isHidden = true
            cell.tapForwardButton.isHidden = true
            cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
        }
    }
    
    
    func rewindVideo(by seconds: Float64,obj:RewardsModel,cell:ChallengeListCollectionViewCell) {
        let currentTime = cell.player.currentTime()
        var newTime = CMTimeGetSeconds(currentTime) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        cell.player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        
    }
    
    func forwardVideo(by seconds: Float64,obj:RewardsModel,cell:ChallengeListCollectionViewCell) {
        let currentTime = cell.player.currentTime()
        let duration = cell.player.currentItem?.duration
        var newTime = CMTimeGetSeconds(currentTime) + seconds
        if newTime >= CMTimeGetSeconds(duration!) {
            newTime = CMTimeGetSeconds(duration!)
        }
        cell.player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }
    
    @objc func multipleTapForward(_ sender: UIButton, event: UIEvent) {
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!ChallengeListCollectionViewCell
        isPlaying = false
        
        let touch: UITouch = event.allTouches!.first!
        let obj = challengesArr[sender.tag]
        if (touch.tapCount == 2) {
            if(!videoFinshed){
                self.forwardVideo(by: 5.0,obj:obj,cell:cell)
            }
            if(cell.player.timeControlStatus == .playing){
                cell.player.play()
            }else{
                cell.player.pause()
            }
            
        }
    }
    
    @objc func multipleTapBackward(_ sender: UIButton, event: UIEvent) {
        //        setUpVideoPlayerViewController()
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!ChallengeListCollectionViewCell
        isPlaying = false
        
        if(videoFinshed){
            videoFinshed = false
            // setUpVideoPlayerViewController(cell:cell)
        }
        let obj = challengesArr[sender.tag]
        self.rewindVideo(by: 5.0,obj:obj,cell:cell)
        backButtonTapped = true
        if(cell.player.timeControlStatus == .playing){
            obj.player?.play()
            backButtonTapped = false
        }else{
            obj.player?.pause()
        }
    }
    
    @objc func tapForward(_ sender: UIButton) {
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!ChallengeListCollectionViewCell
        isPlaying = false
        
        //  let touch: UITouch = event.allTouches!.first!
        let obj = challengesArr[sender.tag]
        //  if (touch.tapCount == 2) {
        if(!videoFinshed){
            self.forwardVideo(by: 5.0,obj:obj,cell:cell)
        }
        if(cell.player.timeControlStatus == .playing){
            cell.player.play()
        }else{
            cell.player.pause()
        }
        
        // }
    }
    
    @objc func tapBackward(_ sender: UIButton) {
        //        setUpVideoPlayerViewController()
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!ChallengeListCollectionViewCell
        isPlaying = false
        
        if(videoFinshed){
            videoFinshed = false
            // setUpVideoPlayerViewController(cell:cell)
        }
        let obj = challengesArr[sender.tag]
        self.rewindVideo(by: 5.0,obj:obj,cell:cell)
        backButtonTapped = true
        if(cell.player.timeControlStatus == .playing){
            obj.player?.play()
            backButtonTapped = false
        }else{
            obj.player?.pause()
        }
    }
    
    func manageMuteUnmute(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        isPlayerMute = !isPlayerMute
        cell.player.isMuted = isPlayerMute
        cell.muteButton.isSelected = isPlayerMute
        cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
    }
    
    func manageVoteStatus(obj: RewardsModel, isFromSwipe: Bool){
        if isFromSwipe {
            if obj.challenge.is_prime_time == "1"{
                obj.is_voted = 1
            }else {
                obj.is_voted = obj.is_voted == 0 ? 1 : 0
            }
            
        }else {
            obj.is_voted = obj.is_voted == 0 ? 1 : 0
        }
    }
    
    @objc func menuButtonAction(_ sender:UIButton) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
            let obj = challengesArr[sender.tag % challengesArr.count]
            let configuration = FTConfiguration()
            configuration.textAlignment = .center
            configuration.menuWidth = 80
            
            FTPopOverMenu.showForSender(sender: sender, with: ["Report"], menuImageArray: [""],config: configuration, done: { (selectedIndex) in
                cell.player.pause()
                delay(delay: 0.1) {
                    RPicker.selectOptionWithCancel(title: "Why are you reporting?", cancelText: "Cancel", doneText: "Done", dataArray: ["It's spam","It's inappropriate"], selectedIndex: 0, didSelectValue: { (selectedValue, selectedIndex) in
                        
                        delay(delay: 1)  {
                            self.reportVideo(obj: obj, cell: cell, reportMessage: selectedValue)
                        }
                    }) { (str) in
                        cell.player.play()
                        self.cellPlayerIconManage(cell: cell)
                        
                    }
                }
            }) {
                
            }
        }
    }
    
    //MARK:- Open Controller Method
    func openDonateScreen(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        
        // let auth = AuthManager.shared.loggedInUser
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            self.timer.invalidate()
            if let vc = UIStoryboard.wallet.get(DonateMoneyViewController.self){
                vc.userId = obj.user_id
                vc.userName = obj.user_name
                vc.userImage = obj.user_image
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
    
    func openMessageScreen(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            self.timer.invalidate()
            if let vc = UIStoryboard.message.get(ChatViewController.self){
                //vc.user.user_id = obj.user_id
                //vc.user.first_name = obj.user_name
                //vc.user.image = obj.user_image
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
    
    func openFeedScreen(cell:ChallengeListCollectionViewCell){
        self.timer.invalidate()
        self.completion?()
        cell.player.pause()
        self.removeAllObject()
        tabBarController?.selectedIndex = 0
        //   self.navigationController?.popToRootViewController(animated: false)
        //   self.navigationController!.viewControllers.removeAll()
        
        
        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    func openUserProfileScreen(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        
        if obj.is_sponsered != "1"{
            if obj.user_id == AuthManager.shared.loggedInUser?.user_id {
                //                UserDefaults.standard.set(true, forKey: "movetoProfile")
                //                self.navigationController?.popToRootViewController(animated: true)
            } else {
                cell.player.pause()
                self.timer.invalidate()
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.isFromSwipe = true
                    vc.user.user_id = obj.user_id
                    vc.user.image = obj.user_image
                    vc.isFromVideoSearch = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func openProfileScreen(cell:ChallengeListCollectionViewCell){
        cell.player.pause()
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            self.timer.invalidate()
            UserDefaults.standard.set(true, forKey: "movetoProfile")
            self.navigationController?.popToRootViewController(animated: true)
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
    
    func openShootScreen(cell: ChallengeListCollectionViewCell,obj: RewardsModel){
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            cell.player.pause()
            self.timer.invalidate()
            if let vc = UIStoryboard.challenge.get(ChallengeShootViewController.self){
                vc.challengeId = self.challenge_id //obj.challenge.challenge_id
                vc.isFromList = true
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
    
    func openShareScreen(cell: ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            
            self.timer.invalidate()
            self.showActionSheet(cell: cell, obj: obj)
            
            //            if let vc = UIStoryboard.challenge.get(ChallengeShareViewController.self){
            //                vc.modalPresentationStyle = .custom
            //                vc.modalTransitionStyle = .crossDissolve
            //                vc.videoObj = obj
            //                vc.videoId = obj.video_id
            //                self.navigationController?.present(vc, animated: true, completion: nil)
            //            }
            
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
    
    func getUserTapped(username: String, obj: RewardsModel,cell: ChallengeListCollectionViewCell, index: Int){
        let user = obj.tagged_user.filter({$0.username == username}).first ?? TaggedUser()
        if user.user_id != nil {
            if user.blocked_status == 1 {
                AlertController.alert(message: "User not found")
            }else if user.check_if_you_block == 1 {
                AlertController.alert(title: "", message: "You blocked this account. To donate unblock the user from settings.")
            }else {
                self.taggedUserProfile(cell: cell, obj: user, index: index)
            }
        }
    }
    
    func taggedUserProfile(cell:ChallengeListCollectionViewCell, obj: TaggedUser,index: Int){
        cell.player.pause()
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if obj.user_id == AuthManager.shared.loggedInUser?.user_id {
                cell.player.pause()
                self.timer.invalidate()
                self.removeAllObject()
                UserDefaults.standard.set(true, forKey: "movetoProfile")
                self.navigationController?.popToRootViewController(animated: true)
            }else {
                cell.player.pause()
                self.timer.invalidate()
                self.removeAllObject()
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.isFromSwipe = true
                    vc.user.user_id = obj.user_id
                    vc.isFromVideoSearch = true
                    // vc.user.image = obj.user_image
                    vc.index = index
                    self.navigationController?.pushViewController(vc, animated: true)
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
    
    func cellPlayerIconManage(cell: ChallengeListCollectionViewCell){
        cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
        cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
        cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
    }
    //MARK:- Target Method
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        
        let location = gesture.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        // print("index::::\(indexPath?.row ?? 0)")
        let cell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0))as!ChallengeListCollectionViewCell
        let obj = self.challengesArr[indexPath?.row ?? 0]
        switch gesture.direction {
        case .left:
            self.openUserProfileScreen(cell: cell, obj: obj )
        case .right:
            if obj.is_sponsered != "1" {
                if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                    //   if AuthManager.shared.loggedInUser?.user_id != obj.user_id {
                    
                    if obj.challenge.is_prime_time == "1"{
                        if obj.is_voted_prime == 0 {
                            self.playVoteSound()
                            self.primeVoteVideo(obj: obj, index: indexPath?.row ?? 0 ,isFromSwipe: true)
                        }else {
                            AlertController.alert(message: "You have already voted.")
                            
                        }
                        //                        if obj.is_voted_two_times == 0 {
                        //                            self.primeVoteVideo(obj: obj, index: indexPath?.row ?? 0, isFromSwipe: true)
                        //                        } else if obj.is_voted_two_times == 1 {
                        //
                        //                        }
                        //
                        //                        else {
                        //                            AlertController.alert(message: "You have already voted.")
                        //                        }
                        //  self.voteVideo(obj: obj, isFromSwipe: true)
                    }else {
                        if obj.is_voted == 1{
                            AlertController.alert(message: "You have already voted.")
                        }else {
                            self.playVoteSound()
                            self.voteVideo(obj: obj, isFromSwipe: true)
                            
                        }
                    }
                    
                    // }
                    
                } else {
                    AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                        if index == 0 {
                            if let vc = UIStoryboard.auth.get(LoginViewController.self){
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
    
    
    //MARK:- UIButton Method
    @IBAction func homeButtonAction(_ sender: UIButton){
        tabBarController?.selectedIndex = 0
        //   self.navigationController?.popToRootViewController(animated: false)
        //   self.navigationController!.viewControllers.removeAll()
        
        
        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    func playVoteSound(){
        
        let path = Bundle.main.path(forResource: "Sword_swipes.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            aVAudioPlayer = try AVAudioPlayer(contentsOf: url)
            aVAudioPlayer?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    
    @objc func plusButtonAction(_ sender:UIButton){
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!ChallengeListCollectionViewCell
        cell.rightStackView.isHidden = false
        cell.bottomStackView.isHidden = false
        cell.profileButton.isHidden = false
        cell.plusButton.isHidden = true
        cell.profileImageView.isHidden  = false
        cell.captionLabel.isHidden  = false
        cell.plusButton.setImage(UIImage(named: ""), for: .normal)
        //        UIView.animate(withDuration: 3) {
        cell.plusButton.popIn(fromScale: 0.9, duration: 5, delay: 0.1) { (status) in
            cell.plusButton.setImage(UIImage(named: "icn_add"), for: .normal)
            cell.plusButton.isHidden = false
            cell.rightStackView.isHidden = true
            cell.bottomStackView.isHidden = true
            cell.profileButton.isHidden = true
            cell.profileImageView.isHidden  = true
            cell.captionLabel.isHidden  = true
            //   }
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}


extension VideoPlayViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return challengesArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeListCollectionViewCell", for: indexPath) as! ChallengeListCollectionViewCell
        if let url = URL(string: challengesArr[indexPath.row].video_thumbnail_new ?? "") {
            cell.thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        
        
        
        if challengesArr[indexPath.row].player == nil {
            if let url = URL(string: challengesArr[indexPath.row].video_path ?? "") {
                challengesArr[indexPath.row].player = AVPlayer(url: url)
                //  challengesArr[indexPath.row].player?.play()
            }
        }
        self.cellPlayerIconManage(cell: cell)
        
        
        var topSafeArea : CGFloat = 0
        if #available(iOS 11.0, *) {
            topSafeArea = APPDELEGATE.window?.rootViewController!.view.safeAreaInsets.top ?? 0
        } else {
            topSafeArea = APPDELEGATE.window?.rootViewController!.topLayoutGuide.length ?? 0
        }
        cell.menuTopButtonConstraint.constant =  topSafeArea == 0.0 ? -15 : 25
        
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
            }
        }
        
        cell.voteButton.isSelected =  challengesArr[indexPath.row].is_voted == 1
        cell.voteLabel.text = challengesArr[indexPath.row].is_voted == 1 ? "Unvote" : "Vote"
        cell.captionLabel.isHidden = false
        cell.captionLabel.text = challengesArr[indexPath.row].video_text?.base64Decoded()
        cell.captionLabel.isUserInteractionEnabled = true
        cell.captionLabel.customize { label in
            label.hashtagColor = .white
            label.mentionColor = .red
        }
        
        cell.captionLabel.enabledTypes = [.mention, .hashtag]
        cell.captionLabel.textColor = .white
        cell.captionLabel.handleHashtagTap { hashtag in
            // print("Success. You just tapped the \(hashtag) hashtag")
        }
        
        cell.captionLabel.handleMentionTap { (username) in
            self.getUserTapped(username: username, obj: self.challengesArr[indexPath.row], cell: cell, index: indexPath.row)
            //print("Success. You just tapped the \(username) username")
        }
        
        if self.challengesArr[indexPath.row].challenge.is_prime_time == "1" {
            
            if self.challengesArr[indexPath.row].is_voted_prime == 0 {
                cell.voteButton.isSelected = false
                cell.voteLabel.text = "Vote"
            }else {
                cell.voteButton.isSelected = true
                cell.voteLabel.text = "Unvote"
            }
            
            //                cell.voteButton.isSelected = obj.is_voted_two_times == 2
            //                cell.voteLabel.text = obj.is_voted_two_times == 2 ? "Unvote" : "Vote"
        }
        
        if challengesArr[indexPath.row].is_sponsered == "1"
            || challengesArr[indexPath.row].user_id == AuthManager.shared.loggedInUser?.user_id || AuthManager.shared.loggedInUser?.user_id == nil {
            cell.menuButton.isHidden = true
            cell.donateView.isHidden = true
            cell.messageView.isHidden = true
            cell.followView.isHidden = true
        }else {
            cell.menuButton.isHidden = false
            cell.donateView.isHidden = false
            cell.messageView.isHidden = false
            cell.followView.isHidden = false
        }
        cell.menuButton.tag = indexPath.row
        cell.menuButton.addTarget(self, action: #selector(menuButtonAction(_:)), for: .touchUpInside)
        
        cell.followButton.isSelected = challengesArr[indexPath.row].is_following == 1
        cell.followLabel.text = cell.followButton.isSelected ? "Following" : "Follow"
        cell.challengeNameLabel.isHidden = true
        cell.playPauseButton.addTarget(self, action: #selector(playPauseButtonAction(_:)), for: .touchUpInside)
        cell.forwardButton.addTarget(self, action: #selector(multipleTapForward(_:event:)), for: UIControl.Event.touchDownRepeat)
        cell.backwardButton.addTarget(self, action: #selector(multipleTapBackward(_:event:)), for: UIControl.Event.touchDownRepeat)
        cell.tapForwardButton.addTarget(self, action: #selector(tapForward(_ :)), for: .touchUpInside)
        cell.tapBackwardButton.addTarget(self, action: #selector(tapBackward(_ :)), for: .touchUpInside)
        // self.setUpVideoPlayerViewController(cell:cell)
        cell.backwardButton.tag = indexPath.row
        cell.forwardButton.tag = indexPath.row
        cell.tapBackwardButton.tag = indexPath.row
        cell.tapForwardButton.tag = indexPath.row
        cell.playPauseButton.tag = indexPath.row
        cell.plusButton.tag = indexPath.row
        cell.plusButton.addTarget(self, action: #selector(plusButtonAction(_:)), for: .touchUpInside)
        
        cell.rightStackView.isHidden = true
        cell.bottomStackView.isHidden = true
        cell.profileButton.isHidden = true
        cell.setPlayer(object: challengesArr[indexPath.row])
        cell.player.isMuted = isPlayerMute
        
        cell.muteButton.isSelected = isPlayerMute
        cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
        
        //        if isPlaying{
        //            cell.setPlayer(object: challengesArr[indexPath.row])
        //        }
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
        swipeGesture.direction = .left
        let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
        swipeGesture1.direction = .right
        cell.innerView.tag = indexPath.row
        
        cell.innerView.isUserInteractionEnabled =  true
        cell.innerView.addGestureRecognizer(swipeGesture)
        cell.innerView.addGestureRecognizer(swipeGesture1)
        //  rotateAnimation(imageView: cell.profileButton)
        cell.viewCompletion = {
            if self.challengesArr[indexPath.row].is_sponsered != "1"{
                self.viewCount(obj: self.challengesArr[indexPath.row])
            }
        }
        //   cell.captionLabel.text = challengesArr[indexPath.row].video_text?.base64Decoded()
        cell.messageClickCompletion = {
            self.openMessageScreen(cell:cell, obj: self.challengesArr[indexPath.row])
        }
        
        cell.muteClickCompletion = {
            self.manageMuteUnmute(cell:cell, obj: self.challengesArr[indexPath.row])
        }
        
        cell.followClickCompletion = {
            if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                self.followUnfollowUser(obj: self.challengesArr[indexPath.row])
                
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
        
        cell.voteClickCompletion = { [weak self] in
            if let object = self?.challengesArr[indexPath.row] {
                if object.is_sponsered != "1" {
                    if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                        if object.challenge.is_prime_time == "1" {
                            self?.primeVoteVideo(obj: object, index: indexPath.row)
                        }else {
                            self?.voteVideo(obj: object)
                            // self?.voteVideo(obj: obj, index : indexPath.row)
                        }
                        
                        //  self?.voteVideo(obj: object)
                        
                    } else {
                        AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                            if index == 0 {
                                if let vc = UIStoryboard.auth.get(LoginViewController.self){
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            //self?.openProfileScreen(cell:cell)
        }
        
        cell.shareClickCompletion = { [weak self] in
            if let object = self?.challengesArr[indexPath.row] {
                self?.openShareScreen(cell: cell,obj: object)
            }
        }
        
        cell.donateClickCompletion = { [weak self] in
            if let object = self?.challengesArr[indexPath.row] {
                self?.openDonateScreen(cell: cell, obj: object)
            }
        }
        
        cell.feedClickCompletion = { [weak self] in
            self?.openFeedScreen(cell:cell)
        }
        
        cell.shootClickCompletion = { [weak self] in
            if let object = self?.challengesArr[indexPath.row] {
                self?.openShootScreen(cell:cell,obj: object)
            }
        }
        
        cell.profileClickCompletion = { [weak self] in
            self?.openProfileScreen(cell:cell)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: Window_Width , height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeListCollectionViewCell", for: indexPath) as! ChallengeListCollectionViewCell
        
        if let url = URL(string: challengesArr[indexPath.row].video_thumbnail_new ?? "") {
            cell.thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        cell.captionLabel.isHidden = false
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
            self.hideLabel(index: indexPath.row)
            self.timer.invalidate()
            print("Stop processing")
            
        })
        //  delay(delay: 7) {
        //            if self.challengesArr.count > 0 {
        //                if self.challengesArr[indexPath.row].is_sponsered != "1"{
        //                if self.challengesArr[indexPath.row].player?.currentTime().seconds ?? 0.0 > 5.0 {
        //                    self.viewCount(obj: self.challengesArr[indexPath.row])
        //                }
        //                }
        //            }
        //}
    }
    
    func hideLabel(index: Int){
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? ChallengeListCollectionViewCell
        cell?.captionLabel.isHidden = true
        if self.challengesArr.count > 0 {
            //            if self.challengesArr[index].is_sponsered != "1"{
            //               // if self.challengesArr[index].player?.currentTime().seconds ?? 0.0 > 2.0 {
            //                    self.viewCount(obj: self.challengesArr[index])
            //               // }
            //            }
        }
        
    }
    
}

extension VideoPlayViewController {
    func rotateAnimation(imageView:UIButton,duration: CFTimeInterval = 5.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        imageView.layer.add(rotateAnimation, forKey: nil)
    }
}

extension VideoPlayViewController {
    
    func viewCount(obj: RewardsModel){
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        param["challenge_id"] = challenge_id
        param["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            param["user_id"] = AuthManager.shared.loggedInUser?.user_id
        }
        
        WebServices.increaseViewCount(params: param) { (response) in
            if response?.statusCode == 200 {
                
            }
        }
    }
    
    func reportVideo(obj: RewardsModel, cell: ChallengeListCollectionViewCell, reportMessage: String){
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        param["report_msg"] = reportMessage
        
        WebServices.reportVideo(params: param) { (response) in
            if response?.statusCode == 200 {
                Alerts.shared.show(alert: .success, message: "Reported Successfully!", type: .success)
                delay(delay: 3) {
                    cell.player.play()
                    self.cellPlayerIconManage(cell: cell)
                }
            }else {
                AlertController.alertForReport(title: "", message: "\(response?.message ?? "")")
            }
        }
    }
    
    func voteVideo(obj: RewardsModel, isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        param["challenge_id"] = obj.is_posted == "0" ?  challenge_id : obj.challenge.challenge_id
        
        if isFromSwipe {
            if obj.challenge.is_prime_time == "1"{
                self.playVoteSound()
                param["flag"] = 1
            } else {
                param["flag"] = obj.is_voted == 0 ? 1 : 0
            }
        }else {
            param["flag"] = obj.is_voted == 0 ? 1 : 0
        }
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                self.manageVoteStatus(obj: obj, isFromSwipe: isFromSwipe)
                if let cell = self.collectionView.cellForItem(at: IndexPath.init(item: 0, section: 0)) as? ChallengeListCollectionViewCell {
                    cell.voteButton.isSelected =  obj.is_voted == 1
                    cell.voteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                }
            }else if response?.statusCode == 0 {
                AlertController.alert(message: "\(response?.message ?? "")")
            }
        }
    }
    
    func primeVoteVideo(obj: RewardsModel,index : Int,isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        
        if obj.is_voted_prime == 0 {
            param["flag"] = 1
        } else {
            param["flag"] = 0
        }
        
        if isFromSwipe {
            param["flag"] = 1
        }
        
        param["challenge_id"] = obj.is_posted == "0" ?  challenge_id : obj.challenge.challenge_id
        
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                
                if let cell = self.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? ChallengeListCollectionViewCell {
                    
                    if obj.is_voted_prime == 0 {
                        obj.is_voted_prime = 1
                        cell.voteButton.isSelected =  true
                        cell.voteLabel.text = "Unvote"
                    } else {
                        cell.voteButton.isSelected =  false
                        cell.voteLabel.text = "Vote"
                        obj.is_voted_prime = 0
                    }
                    
                    
                    if isFromSwipe {
                        obj.is_voted_prime = 1
                        cell.voteButton.isSelected =  true
                        cell.voteLabel.text = "Unvote"
                        
                    }
                    cell.rightStackView.isHidden = false
                    cell.bottomStackView.isHidden = false
                    cell.profileButton.isHidden = false
                    cell.plusButton.isHidden = true
                    cell.profileImageView.isHidden  = false
                    cell.captionLabel.isHidden  = false
                    cell.plusButton.setImage(UIImage(named: ""), for: .normal)
                    cell.plusButton.popIn(fromScale: 0.9, duration: 5, delay: 0.1) { (status) in
                        cell.plusButton.setImage(UIImage(named: "icn_add"), for: .normal)
                        cell.plusButton.isHidden = false
                        cell.rightStackView.isHidden = true
                        cell.bottomStackView.isHidden = true
                        cell.profileButton.isHidden = true
                        cell.profileImageView.isHidden  = true
                        cell.captionLabel.isHidden  = true
                    }
                }
                
            }else if response?.statusCode == 0 {
                if response?.message == "You have already given vote for this video!" {
                    
                }else {
                    AlertController.alert(message: "\(response?.message ?? "")")
                }
            }
        }
    }
    
    func followUnfollowUser(obj: RewardsModel){
        var param  = [String: Any]()
        param["follow_status"] = obj.is_following == 1 ? 0 : 1
        param["following_id"] = obj.user_id
        
        WebServices.followUnfollowUser(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.is_following = obj.is_following == 1 ? 0  : 1
                self.collectionView.reloadData()
            }
        }
    }
    
}


extension VideoPlayViewController {
    func showActionSheet(cell: ChallengeListCollectionViewCell, obj: RewardsModel) {
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor = .red
        
        let appGalleryAction = UIAlertAction(title: "Share To External", style: .default, handler:
                                                {
                                                    (alert: UIAlertAction!) -> Void in
                                                    self.openActivityController(cell: cell, obj: obj)
                                                })
        
        let libraryAction = UIAlertAction(title: "Share To Internal", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                self.openShare(cell: cell, obj: obj)
                                            })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                print("Cancelled")
                                            })
        
        optionMenu.addAction(appGalleryAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func openActivityController(cell: ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        AppUtility.createDynamicLinkWith("\(obj.video_id ?? "0")", "", "" ,superViewController: self, username: obj.user_name ?? "")
    }
    
    func openShare(cell: ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        if let vc = UIStoryboard.challenge.get(ChallengeShareViewController.self){
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.videoObj = obj
            vc.videoId = obj.video_id
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
}
