//
//  MyPostViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 11/07/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SimpleAnimation
import ActiveLabel
import FTPopOverMenu_Swift


class MyPostViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navLabel: UILabel!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var animationView: UIView!
    
    var aVAudioPlayer: AVAudioPlayer?
    
    var isPlaying = true
    var videoArr = [RewardsModel]()
    
    var videoFBArr = [[String : Any]]()

    
    var player = AVPlayer()
    var videoFinshed = false
    var backButtonTapped = false
    var currentPage = 0
    var videoType: VideoType = .myPost
    var isMyProfile = false
    var videoId = ""
    var isFromLeaderboard = false
    var challenge_id = "0"
    var videoCount = 0
    var dynamic_error_message = ""
    var userName = ""
    
    // MARK:- UIViewController LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialSetup()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
                
    }
    
    // MARK:- Target Methods
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            let location = gesture.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: location)
            let obj = self.videoArr[indexPath?.row ?? 0]
            if obj.challenge.is_prime_time == "1"{
                if obj.is_voted_prime == 0 {
                    self.primeVoteVideo(obj: obj, index: indexPath?.row ?? 0 ,isFromSwipe: true)
                }else {
                    AlertController.alert(message: "You have already voted.")
                }
              //  voteVideo(obj: obj,index: indexPath?.row ?? 0,isFromSwipe: true)
            }else {
                if obj.is_voted == 1{
                    AlertController.alert(message: "You have already voted.")
                }else {
                    voteVideo(obj: obj,index: indexPath?.row ?? 0,isFromSwipe: true)
                    self.playVoteSound()
                }
            }
            
        }else {
            
            AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.navigationBar.isHidden = true
                        APPDELEGATE.window?.rootViewController = navigationController
                        APPDELEGATE.navigationController = navigationController
                    }
                }
            }
        }
    }
    
    @objc func multipleTapForward(_ sender: UIButton, event: UIEvent) {
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!PostsCollectionViewCell
        isPlaying = false
        
        let touch: UITouch = event.allTouches!.first!
        let obj = videoArr[sender.tag]
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
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!PostsCollectionViewCell
        isPlaying = false
        
        if(videoFinshed){
            videoFinshed = false
        }
        let obj = videoArr[sender.tag]
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
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!PostsCollectionViewCell
        isPlaying = false
        let obj = videoArr[sender.tag]
        if(!videoFinshed){
            self.forwardVideo(by: 5.0,obj:obj,cell:cell)
        }
        if(cell.player.timeControlStatus == .playing){
            cell.player.play()
        }else{
            cell.player.pause()
        }
    }
    
    @objc func tapBackward(_ sender: UIButton) {
        let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0))as!PostsCollectionViewCell
        isPlaying = false
        
        if(videoFinshed){
            videoFinshed = false
        }
        let obj = videoArr[sender.tag]
        self.rewindVideo(by: 5.0,obj:obj,cell:cell)
        backButtonTapped = true
        if(cell.player.timeControlStatus == .playing){
            obj.player?.play()
            backButtonTapped = false
        }else{
            obj.player?.pause()
        }
    }
    
    
    // MARK:- UIButton Action Methods
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}

extension MyPostViewController {
    
    func initialSetup(){
        self.animationImage.isHidden = true
        self.animationView.isHidden = true
        
        switch videoType {
        case .gallery:
            if isMyProfile {
                navLabel.text = videoArr.count > 1 ? "Gallery" : "Gallery"
            }else {
                if isFromLeaderboard {
                    navLabel.text = "Squabble Showcase"
                }else {
                    navLabel.text = videoArr.count > 1 ? "Gallery" : "Gallery"
                }
            }
            
        default:
            navLabel.text = "Trophy Room"
        }
        
        /*for (index,item) in videoArr.enumerated() {
            if item.video_id == videoId {
                
                if self.videoArr[index].player == nil {
                    if let url = URL(string: self.videoArr[index].video_path ?? "") {
                        self.videoArr[index].player = AVPlayer(url: url)
                        self.videoArr[index].isPlayed = true
                        self.videoArr[index].player?.seek(to: .zero)
                        if (self.videoArr[index].player?.rate ?? 1) == 0 {
                            self.videoArr[index].player?.play()
                        }
                        self.videoArr[index].removeObserver()
                        self.videoArr[index].addObserver()
                    }
                }
                self.videoArr[index].player?.play()
                DispatchQueue.main.async {
                    self.collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: .centeredVertically, animated: false)
                    self.collectionView.reloadData()
                }
            }
        }*/
        
    }
    
    func voteUnvote(obj: RewardsModel, index: Int){
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if  !self.isMyProfile || self.videoType == .myTrophy {
                if obj.challenge.is_prime_time == "1" {
                    self.primeVoteVideo(obj: obj, index: index)
                }else {
                    self.voteVideo(obj: obj, index : index)
                }
              //  voteVideo(obj: obj,index: index)
            }
        }else {
            
            AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.navigationBar.isHidden = true
                        APPDELEGATE.window?.rootViewController = navigationController
                        APPDELEGATE.navigationController = navigationController
                    }
                }
            }
        }
    }
    
    func animatieVote(){
        self.animationView.isHidden = false
        self.animationImage.isHidden = false
        playVoteSound()
        
        do {
            let gif = try UIImage(gifName: "vote_animation.gif")
            self.animationImage.startAnimatingGif()
            self.animationImage.setGifImage(gif, loopCount: 1)
            
        }catch {
            print(error)
        }
        
        delay(delay: 1.0) {
            self.animationImage.isHidden = true
            self.animationView.isHidden = true
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
    
    func playPauseButtonAction(index: Int) {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0))as!PostsCollectionViewCell
        let obj = videoArr[index]
        if(videoFinshed && !backButtonTapped){
            videoFinshed = false
        }else if cell.player.timeControlStatus == .playing  {
            obj.isPlayed = true
            isPlaying = false
            obj.player?.pause()
            cell.tapBackwardButton.isHidden = false
            cell.tapForwardButton.isHidden = false
            cell.playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
            cell.tapForwardButton.setImage(UIImage.init(named: "icn_forward"), for: .normal)
            cell.tapBackwardButton.setImage(UIImage.init(named: "icn_backward"), for: .normal)
        }else {
            backButtonTapped = false
            isPlaying = false
            cell.tapBackwardButton.isHidden = true
            cell.tapForwardButton.isHidden = true
            obj.player?.play()
            cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
        }
    }
    
    func rewindVideo(by seconds: Float64,obj:RewardsModel,cell:PostsCollectionViewCell) {
        let currentTime = cell.player.currentTime()
        var newTime = CMTimeGetSeconds(currentTime) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        cell.player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        
    }
    
    func forwardVideo(by seconds: Float64,obj:RewardsModel,cell:PostsCollectionViewCell) {
        let currentTime = cell.player.currentTime()
        let duration = cell.player.currentItem?.duration
        var newTime = CMTimeGetSeconds(currentTime) + seconds
        if newTime >= CMTimeGetSeconds(duration!) {
            newTime = CMTimeGetSeconds(duration!)
        }
        cell.player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }
    
    func openShareScreen(obj: RewardsModel,cell: PostsCollectionViewCell){
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            self.showActionSheet(cell: cell, obj: obj)
        }else {
            AlertController.alert(title: "", message: ValidationMessage.LoginAlert.rawValue, buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.navigationBar.isHidden = true
                        APPDELEGATE.window?.rootViewController = navigationController
                        APPDELEGATE.navigationController = navigationController
                    }
                }
            }
            
        }
        
    }
    
    func openChallengePost(obj: RewardsModel){
        
        if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
            vc.videoID = Int(obj.video_id ?? "0")
            vc.videoObj = obj
            vc.videoType = .gallery
            vc.videoURL = URL(string: obj.aws_video_path ?? "")
            vc.isFromProfile = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func openEditPost(obj: RewardsModel, cell: PostsCollectionViewCell,index: Int){
        
        if obj.challenge.check_if_completed == 1 {
            AlertController.alert(message: "You can not edit completed challenge video.")
        }else {
            
            if let vc = UIStoryboard.challenge.get(EditVideoViewController.self) {
                vc.challengeId = obj.challenge_id
                vc.homeObj.challenge_id = obj.challenge.challenge_id
                vc.homeObj.title = obj.challenge.title
                vc.videoID = Int(obj.video_id ?? "0")
                vc.thumbnail = cell.thumbnailImageView.image!
                vc.isFromEdit = true
                vc.videoObj = obj
                vc.editCompletion = { str , videoID, taggedUser in
                    obj.video_text = str
                    obj.tagged_user = taggedUser
                    self.videoId = videoID
                    self.initialSetup()
                }
                vc.videoURL = URL.init(string: obj.video_thumbnail ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func manageMuteUnmute(cell:PostsCollectionViewCell, obj: RewardsModel){
        
        isPlayerMute = !isPlayerMute
        cell.player.isMuted = isPlayerMute
        cell.muteButton.isSelected = isPlayerMute
        cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
    }
    
    func getUserTapped(username: String, obj: RewardsModel,cell: PostsCollectionViewCell, index: Int){
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
    
    func taggedUserProfile(cell:PostsCollectionViewCell, obj: TaggedUser,index: Int){
        cell.player.pause()
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if obj.user_id == AuthManager.shared.loggedInUser?.user_id {
                cell.player.pause()
                UserDefaults.standard.set(true, forKey: "movetoProfile")
                self.navigationController?.popToRootViewController(animated: true)
            }else {
                cell.player.pause()
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.isFromSwipe = true
                    vc.user.user_id = obj.user_id
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
    func cellPlayerIconManage(cell: PostsCollectionViewCell){
        cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
        cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
        cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
    }
    
    @objc func menuButtonAction(_ sender:UIButton) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? PostsCollectionViewCell {
            let obj = videoArr[sender.tag]
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
                        self.cellPlayerIconManage(cell: cell)
                        cell.player.play()
                    }
                }
            }) {
                
            }
        }
    }
    
    func setLeaderboardCell(cell: PostsCollectionViewCell){
        cell.rightView.isHidden = false
        cell.leftView.isHidden = true
        cell.shareBottomConstraint.constant = 51
        cell.voteView.isHidden = true
        cell.voteViewHeight.constant = 0
        cell.voteButton.isHidden = true
        cell.voteLabelHeight.constant = 0
        cell.voteButtonHeight.constant = 0
        cell.voteBottomHeight.constant = 25
        
    }
}

extension MyPostViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostsCollectionViewCell", for: indexPath) as! PostsCollectionViewCell
        let obj = videoArr[indexPath.row]
        if videoArr[indexPath.row].player == nil {
            if let url = URL(string: videoArr[indexPath.row].aws_video_path ?? "") {
                videoArr[indexPath.row].player = AVPlayer(url: url)
                videoArr[indexPath.row].player?.play()
            }
        }
        
        
        cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
        cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
        cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
        
        cell.tapBackwardButton.isHidden = true
        cell.tapForwardButton.isHidden = true
        
        if let url = URL(string: videoArr[indexPath.row].video_thumbnail_new ?? "") {
            cell.thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        cell.setPlayer(object: videoArr[indexPath.row])
        
        cell.editStackView.isHidden = !isMyProfile
        cell.cellSetup(obj: videoArr[indexPath.row], type: videoType)
        
        if  self.videoType == .myTrophy || !self.isMyProfile {
            cell.voteView.isHidden = false
            cell.editView.isHidden = true
            cell.deleteView.isHidden = true
            
            if obj.challenge.is_prime_time == "1" {
                if obj.is_voted_prime == 0 {
                    cell.voteButton.isSelected = false
                    cell.unvoteLabel.text = "Vote"
                }else {
                    cell.voteButton.isSelected = true
                    cell.unvoteLabel.text = "Unvote"
                }
            }else {
                cell.unvoteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                cell.voteButton.isSelected = obj.is_voted == 1
            }
            cell.voteViewHeight.constant = 64
            cell.voteButton.isHidden = false
            cell.voteLabelHeight.constant = 17
            cell.voteButtonHeight.constant = 45
            cell.voteBottomHeight.constant = 2
        }else {
            if obj.is_posted == "0" {
                cell.voteView.isHidden = false
                cell.unvoteLabel.text = "Add To Challenge"
                cell.voteButton.isSelected = false
                cell.voteButton.setImage(UIImage(named: "add challenge"), for: .normal)
                cell.voteViewHeight.constant = 64
                cell.voteButton.isHidden = false
                cell.voteLabelHeight.constant = 17
                cell.voteButtonHeight.constant = 45
                cell.voteBottomHeight.constant = 2
            }else {
                cell.voteView.isHidden = true
                cell.voteViewHeight.constant = 0
                cell.voteButton.isHidden = true
                cell.voteLabelHeight.constant = 0
                cell.voteButtonHeight.constant = 0
                cell.voteBottomHeight.constant = -20
            }
            
            cell.editView.isHidden = false
            cell.deleteView.isHidden = false
        }
        
        if  self.videoType == .myTrophy && self.isMyProfile {
            cell.deleteView.isHidden = false
        }
        
        if self.isFromLeaderboard {
            self.setLeaderboardCell(cell: cell)
        }
        
        cell.menuButton.addTarget(self, action: #selector(menuButtonAction(_:)), for: .touchUpInside)
        cell.menuButton.tag = indexPath.row
        
        if self.isFromLeaderboard || self.isMyProfile {
            cell.menuButton.isHidden = true
        }else {
            cell.menuButton.isHidden = false
        }
        
        
        if self.isMyProfile, obj.is_posted == "0", videoType != .myTrophy {
            cell.leftView.isHidden = false
            
            let winnerVoteDouble = Double(obj.votes_count ?? "0") ?? 0.0
            let winnerVoteStr = winnerVoteDouble > 1 ? "\(voteFormatPoints(num: winnerVoteDouble)) Votes" : "\(voteFormatPoints(num: winnerVoteDouble)) Vote"
            cell.leftVoteLabel.attributedText = winnerVoteStr.getAttributedString( winnerVoteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
            
            let winnerViewsDouble = Double(obj.views_count ?? "0") ?? 0.0
            let winnerlikeStr = winnerViewsDouble > 1 ? "\(voteFormatPoints(num: winnerViewsDouble)) Views" : "\(voteFormatPoints(num: winnerViewsDouble)) View"
            cell.leftViewsLabel.attributedText = winnerlikeStr.getAttributedString(winnerViewsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        }
        
        cell.captionLabel.text = obj.video_text?.base64Decoded()
        cell.captionLabel.isUserInteractionEnabled = true
        cell.captionLabel.customize { label in
            label.hashtagColor = .white
            label.mentionColor = .red
        }
        
        cell.captionLabel.enabledTypes = [.mention, .hashtag]
        cell.captionLabel.textColor = .white
        cell.captionLabel.handleHashtagTap { hashtag in
        }
        
        cell.captionLabel.handleMentionTap { (username) in
            self.getUserTapped(username: username, obj: obj, cell: cell, index: indexPath.row)
        }
        
        cell.forwardButton.addTarget(self, action: #selector(multipleTapForward(_:event:)), for: UIControl.Event.touchDownRepeat)
        cell.backwardButton.addTarget(self, action: #selector(multipleTapBackward(_:event:)), for: UIControl.Event.touchDownRepeat)
        
        cell.tapForwardButton.addTarget(self, action: #selector(tapForward(_ :)), for: UIControl.Event.touchUpInside)
        cell.tapBackwardButton.addTarget(self, action: #selector(tapBackward(_ :)), for: UIControl.Event.touchUpInside)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
        swipeGesture.direction = .right
        if  !self.isMyProfile || self.videoType == .myTrophy {
            cell.innerView.addGestureRecognizer(swipeGesture)
        }
        cell.innerView.tag = indexPath.row
        
        cell.innerView.isUserInteractionEnabled = true
        cell.backwardButton.tag = indexPath.row
        cell.forwardButton.tag = indexPath.row
        cell.tapBackwardButton.tag = indexPath.row
        cell.tapForwardButton.tag = indexPath.row
        
        cell.player.isMuted = isPlayerMute
        
        cell.muteButton.isSelected = isPlayerMute
        cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
        
        cell.playClickCompletion = {
            self.playPauseButtonAction(index: indexPath.row)
        }
        
        cell.shareClickCompletion = {
            self.openShareScreen(obj: self.videoArr[indexPath.row], cell: cell)
        }
        
        cell.deleteClickCompletion = {
            cell.player.pause()
            AlertController.alert(title: "", message: "Are you sure you want to delete?", buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    if  self.videoType == .myTrophy && self.isMyProfile {
                        print("aaaa")
                        self.callApiForDeleteTrophyVideo(obj: self.videoArr[indexPath.row], index: indexPath.row)
                    }else {
                        self.callApiForDeleteVideo(obj: self.videoArr[indexPath.row], index: indexPath.row)
                    }
                }else {
                    cell.player.play()
                }
            }
        }
        
        cell.muteClickCompletion = {
            self.manageMuteUnmute(cell:cell, obj: obj)
        }
        
        cell.editClickCompletion = {
            self.openEditPost(obj: self.videoArr[indexPath.row], cell: cell, index: indexPath.row)
        }
        
        cell.voteClickCompletion = {
            if self.videoType == .myTrophy || !self.isMyProfile {
                self.voteUnvote(obj: self.videoArr[indexPath.row],index: indexPath.row)
            }else {
                
                self.openTermsDialog(obj: self.videoArr[indexPath.row])
              //  self.openChallengePost(obj: self.videoArr[indexPath.row])
            }
        }
        
        DispatchQueue.main.async {
            cell.layoutIfNeeded()
            cell.setNeedsDisplay()
        }
        
//      //  if videoArr[indexPath.row].player == nil {
//            if let url = URL(string: "http://d12z3avrqemmfm.cloudfront.net/orig709.m3u8") {
//                videoArr[indexPath.row].player = AVPlayer(url: url)
//                videoArr[indexPath.row].player?.play()
//            }
//       // }
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: Window_Width , height: Window_Height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delay(delay: 1) {
            if  self.videoType == .myTrophy && !self.isMyProfile{
                self.viewCount(obj: self.videoArr[indexPath.row], index: indexPath.row)
            }
            
        }
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.height
        let currentPage = Int(floor((scrollView.contentOffset.y - pageWidth * 0.5) / pageWidth) + 1)
        
        if  let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? PostsCollectionViewCell {
            cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapBackwardButton.isHidden = true
            cell.tapForwardButton.isHidden = true
            cell.player.isMuted = isPlayerMute
            cell.muteButton.isSelected = isPlayerMute
            cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
        }
        
        self.currentPage = currentPage
        for (index, _) in videoArr.enumerated() {
            
            if index == currentPage {
                isPlaying = true
                
                videoArr[index].isPlayed = true
                if (videoArr[index].player?.rate ?? 1) == 0 {
                    videoArr[index].player?.play()
                }
                videoArr[index].removeObserver()
                videoArr[index].addObserver()
                
                if currentPage == videoArr.count - 2 && videoArr.count > 3 {
                    var array = videoArr
                    let object = array.removeFirst()
                    array.append(object)
                    videoArr = array
                    collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath(row: currentPage - 1, section: 0), at: .centeredVertically, animated: false)
                }
                
            } else {
                isPlaying = false
                videoArr[index].player?.pause()
                videoArr[index].isPlayed = false
                videoArr[index].removeObserver()
                if index < currentPage - 1 && index > currentPage + 1 {
                    videoArr[index].player?.replaceCurrentItem(with: nil)
                    videoArr[index].player = nil
                }
            }
        }
        
    }
}

extension MyPostViewController {
    func voteVideo(obj: RewardsModel,index: Int, isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        if isFromLeaderboard {
            param["challenge_id"] = challenge_id
            param["flag"] = obj.is_voted == 0 ? 1 : 0
        }else {
            if let challengeId = obj.challenge.challenge_id {
                param["challenge_id"] =  challengeId.isEmpty ? challenge_id : obj.challenge.challenge_id
                if challengeId.isEmpty {
                    param["flag"] = obj.challenge.is_voted == 0 ? 1 : 0
                }else {
                    if isFromSwipe {
                        
                        if obj.challenge.is_prime_time == "1"{
                            self.playVoteSound()
                            param["flag"] = 1
                        } else {
                            param["flag"] = obj.challenge.is_voted == 0 ? 1 : 0
                        }
                        
                    }else{
                        param["flag"] = obj.challenge.is_voted == 0 ? 1 : 0
                    }
                }
                
            }else {
                param["challenge_id"] =  challenge_id
                param["flag"] =  obj.is_voted == 0 ? 1 : 0
                
            }
            
        }
        
        
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                if isFromSwipe {
                    if obj.challenge.is_prime_time == "1"{
                        obj.votes_count = "\((Int(obj.votes_count ?? "0") ?? 0 ) + 1)"
                    }else{
                        if obj.is_voted == 0 {
                            obj.votes_count = "\((Int(obj.votes_count ?? "0") ?? 0 ) + 1)"
                        }else {
                            obj.votes_count = "\((Int(obj.votes_count ?? "0") ?? 0 ) - 1)"
                        }
                    }
                } else {
                    if obj.is_voted == 0 {
                        obj.votes_count = "\((Int(obj.votes_count ?? "0") ?? 0 ) + 1)"
                    }else {
                        obj.votes_count = "\((Int(obj.votes_count ?? "0") ?? 0 ) - 1)"
                    }
                }
                
                
                if isFromSwipe {
                    if obj.challenge.is_prime_time == "1"{
                        obj.is_voted = 1
                    }else {
                        obj.is_voted = obj.is_voted == 0 ? 1 : 0
                    }
                }else {
                    obj.is_voted = obj.is_voted == 0 ? 1 : 0
                }
                delay(delay: 0.1) {
                    if let cell = self.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? PostsCollectionViewCell {
                        cell.cellSetup(obj: obj, type: self.videoType)
                        if self.isFromLeaderboard {
                            self.setLeaderboardCell(cell: cell)
                        }
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
    
    func primeVoteVideo(obj: RewardsModel,index : Int,isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        
        if obj.is_voted_prime == 0 {
            param["flag"] = 1
        } else {
            param["flag"] = 0
        }
        
        if isFromSwipe {
            self.playVoteSound()
            param["flag"] = 1
        }
     
        param["challenge_id"] = obj.is_posted == "0" ?  challenge_id : obj.challenge.challenge_id
        
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                
                if let cell = self.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? PostsCollectionViewCell {
                    
                    if obj.is_voted_prime == 0 {
                        obj.is_voted_prime = 1
                        cell.voteButton.isSelected =  true
                        cell.unvoteLabel.text = "Unvote"
                    } else {
                        cell.voteButton.isSelected =  false
                        cell.unvoteLabel.text = "Vote"
                        obj.is_voted_prime = 0
                    }
 
                    
                    if isFromSwipe {
                        obj.is_voted_prime = 1
                        cell.voteButton.isSelected =  true
                        cell.voteLabel.text = "Unvote"

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
    
    func viewCount(obj: RewardsModel, index: Int){
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        param["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        param["challenge_id"] = isFromLeaderboard ? challenge_id : obj.challenge.challenge_id
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            param["user_id"] = AuthManager.shared.loggedInUser?.user_id
        }
        
        WebServices.increaseViewCount(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.views_count = "\((Int(obj.views_count ?? "0") ?? 0) + 1)"
                delay(delay: 0.5) {
                    if let cell = self.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? PostsCollectionViewCell {
                        cell.cellSetup(obj: obj, type: self.videoType)
                    }
                }
            }
        }
    }
    
    func callApiForDeleteVideo(obj: RewardsModel, index: Int) {
        var params = [String: Any]()
        params["video_id"] = obj.video_id
        WebServices.deleteVideo(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    self.videoArr.remove(at: index)
                    self.collectionView.reloadData()
                    if self.videoArr.count == 0 {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
    }
    
    func callApiForDeleteTrophyVideo(obj: RewardsModel, index: Int) {
        var params = [String: Any]()
        params["video_id"] = obj.video_id
        params["challenge_id"] = obj.challenge_id
        WebServices.deleteTrophyVideo(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    self.videoArr.remove(at: index)
                    self.collectionView.reloadData()
                    if self.videoArr.count == 0 {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
    }
    
    func reportVideo(obj: RewardsModel, cell: PostsCollectionViewCell, reportMessage: String){
        self.view.endEditing(true)
        
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
                self.showAlert(msg: "\(response?.message ?? "")")
            }
        }
    }
}

extension MyPostViewController {
    func showActionSheet(cell: PostsCollectionViewCell, obj: RewardsModel) {
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
    
    func openActivityController(cell: PostsCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        AppUtility.createDynamicLinkWith("\(obj.video_id ?? "0")", "", "\(obj.video_thumbnail ?? "")" ,superViewController: self, username: userName)
    }
    
    func openShare(cell: PostsCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        if let vc = UIStoryboard.challenge.get(ChallengeShareViewController.self){
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.videoObj = obj
            vc.videoId = obj.video_id
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func showAlert(msg: String) {
        DispatchQueue.main.async(execute: {
            self.view.endEditing(true)
            let alert = UIAlertController.init(title: "", message: msg, preferredStyle: .alert)
            
            let acceptButton = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            })
            
            alert.addAction(acceptButton)
            
            
            self.present(alert, animated: true, completion: nil)
        })
    }
}

extension MyPostViewController: CustomParticipateSelectionDelegate {
    func agreeTermsAndConditions(status: Bool, obj: RewardsModel) {
        if status {
            self.openChallengePost(obj: obj)
           // self.showActionSheet(obj: obj)
        }
    }
    
    func clickedTermsAndConditions(obj: RewardsModel) {
        if let vc = UIStoryboard.auth.get(StaticContentViewController.self){
            vc.isFromSetting = true
            vc.backFromPostCompletion = { obj in
                if let vc = UIStoryboard.challenge.get(ChallengeParticipatePopupViewController.self){
                    vc.isFromSetting = true
                    vc.delegate = self
                    vc.obj = obj
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .custom
                    self.navigationController?.present(vc, animated: false, completion: nil)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openTermsDialog(obj: RewardsModel){
        
        if AuthManager.shared.loggedInUser?.isAgreeToTermsnC == 1 {
            if AuthManager.shared.loggedInUser?.isShowAgain == 1 {
                self.openChallengePost(obj: obj)

            }else {
                if let vc = UIStoryboard.challenge.get(ChallengeParticipatePopupViewController.self){
                    vc.isFromSetting = true
                    vc.delegate = self
                    vc.obj = obj
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .custom
                    self.navigationController?.present(vc, animated: true, completion: nil)
                }
            }
        }else {
            if let vc = UIStoryboard.challenge.get(ChallengeParticipatePopupViewController.self){
                vc.isFromSetting = true
                vc.delegate = self
                vc.obj = obj
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .custom
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
}
