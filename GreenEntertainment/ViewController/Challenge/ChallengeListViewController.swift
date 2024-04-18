//
//  ChallengeListViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 17/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

enum FilterType {
    case trending
    case following
    case general
    case none
}

var isPlayerMute = false

import UIKit
import AVFoundation
import AVKit
import SimpleAnimation
//import GoogleMobileAds
import InfiniteLayout
import SystemConfiguration
import MediaPlayer
import ActiveLabel
import FTPopOverMenu_Swift

class ChallengeListViewController: UIViewController {
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var doubleTapBackward: UIButton!
    @IBOutlet weak var doubleTapForward: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var slidView: UIView!
    
    @IBOutlet weak var slider: UISlider!
    
    var aVAudioPlayer: AVAudioPlayer?
    
    var commonPlayer: AVPlayer?
    
    var isPlaying = true
    var completion: (() -> Void)?  = nil
    
    var startTime: String?
    var endTime: String?
    var check_if_participated: String?
    var challenge_type: String?
    var downloadTask = URLSessionDownloadTask()
    var isLastIndex = false
    var randomIndex = 0
    var numberAdd = 10
    
    var isFilter: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.stackView.isHidden = !self.isFilter
                self.overlayView.isHidden = !self.isFilter
                self.filterButton.isHidden = self.isFilter
                self.arrowImage.isHidden = self.isFilter
            }
        }
    }
    var filterType : FilterType = .general
    var player = AVPlayer()
    var videoFinshed = false
    var backButtonTapped = false
    var currentPage = 0
    var challengesArr = [RewardsModel]()
    var offset = 0
    var isFromHome = false
    var videoId = ""
    var timer = Timer()
    //var interstitial: GADInterstitialAd!
    var challenge_id = "0"
    var downloadIndex = 1
    var loopCount = 0
    var isViewAppeared = false
    
    var current_index = 0
    var last_index = 0
    
    private var refreshControl = UIRefreshControl()
    let audioSession = AVAudioSession.sharedInstance()
    
    var playerVolume = 1.0
    var isSlide = false
    var is_prime_time = ""
    
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        randomIndex = Int.random(in: 0..<3)
        self.currentPage = 0
        if !isFromHome {
            getVideoList()
            
            //            self.interstitial = createAndLoadInterstitial()
            //            self.interstitial.delegate = self
            //            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["a4ded2e093b3adf456c4725456857f71" ]
            //            let request = GADRequest()
            //            self.interstitial.load(request)
        }
        customSetup()
        
        
        // Do any additional setup after loading the view.
    }
    
//    func interstitialWillPresentScreen(_ ad: GADInterstitialAd) {
//        print("Ad presented")
//    }
//    
//    func interstitialDidDismissScreen(_ ad: GADInterstitialAd) {
//        // Send another GADRequest here
//        print("Ad dismissed")
//        
//    }
//    
//    func interstitialDidReceiveAd(_ ad: GADInterstitialAd) {
//        print("Ad Receive")
//        
//        
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isViewAppeared = true
        self.collectionView.reloadData()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self)
        isViewAppeared = false
        for item in challengesArr {
            item.player?.pause()
            item.removeObserver()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        for item in challengesArr {
            item.player?.pause()
            item.removeObserver()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // if !isFromHome {
            self.handlePlayer()
       // }
    }
    
    func removeAllObject(){
        NotificationCenter.default.removeObserver(self)
        for item in challengesArr {
            item.player?.pause()
            item.removeObserver()
        }
    }
    
    deinit {
        for item in challengesArr {
            item.player?.pause()
            item.removeObserver()
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider){
        playerVolume = Double(sender.value)
        self.isSlide = true
        self.slidView.isHidden = false
        if challengesArr.count == 0 {
            return
        }
        self.challengesArr[current_index].player?.volume = Float(playerVolume)
    }
    
    @IBAction func sliderValueFinished(_ sender: UISlider) {
        delay(delay: 5) {
            self.slidView.isHidden = true
        }
    }
    
    
    //MARK:- Helper Method
    func customSetup(){
        self.animationImage.isHidden = true
        self.animationView.isHidden = true
        isFilter  = false
        setupFilter(filter: .general)
        
        slidView.isHidden = true
        self.slider.value = audioSession.outputVolume
        self.playerVolume = Double(audioSession.outputVolume)
        slider.addTarget(self, action: #selector(sliderValueChanged(_ :)), for: .valueChanged)
        
        if isFromHome {
            stackView.isHidden = true
            filterButton.isHidden = true
            arrowImage.isHidden = true
            backButton.isHidden = false
            
            if challengesArr.count > 0 {
                for (index,item) in challengesArr.enumerated() {
                    if item.video_id == videoId {
                        if self.challengesArr[index].player == nil {
                            if let url = URL(string: self.challengesArr[index].aws_video_path ?? "") {
                                self.challengesArr[index].player = AVPlayer(url: url)
                                self.challengesArr[index].isPlayed = true
                                if (self.challengesArr[index].player?.rate ?? 1) == 0 {
                                    self.challengesArr[index].player?.play()
                                }
                                self.current_index = index
                                self.challengesArr[index].removeObserver()
                                self.challengesArr[index].addObserver()
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: .centeredVertically, animated: false)
                        }
                        self.collectionView.reloadData()
                        
                        delay(delay: 0.5) {
                            self.challengesArr[index].player?.play()
                            self.challengesArr[index].addObserver()
                        }
                    }
                }
                
            }
        }else {
            pullToRefersh()
        }
    }
    
    func pullToRefersh() {
        refreshControl = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        self.timer.invalidate()
        removeAllObject()
        challengesArr.removeAll()
        self.offset = 0
        self.collectionView.reloadData()
        self.getVideoList(loader: true)
        refreshControl.endRefreshing()
    }
    
    
    /*\func createAndLoadInterstitial() -> GADInterstitialAd {
        let interstitial = GADInterstitialAd((adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(DFPRequest())
        return interstitial
    }*/
    
    
    //video player methods
    @objc func playPauseButtonAction(_ sender: UIButton) {
        self.slidView.isHidden = true
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
            let obj = challengesArr[sender.tag % challengesArr.count]
            if cell.player.timeControlStatus == .playing  {
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
                obj.player?.play()
                cell.tapBackwardButton.isHidden = true
                cell.tapForwardButton.isHidden = true
                cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
                cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
                cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
            }
            
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
        
        if let duration = duration {
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            cell.player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
            
        }
        
    }
    
    @objc func multipleTapForward(_ sender: UIButton, event: UIEvent) {
        self.slidView.isHidden = true
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
            isPlaying = false
            
            let touch: UITouch = event.allTouches!.first!
            let obj = challengesArr[sender.tag % challengesArr.count]
            if (touch.tapCount == 2) {
                if(!videoFinshed) {
                    self.forwardVideo(by: 5.0,obj:obj,cell:cell)
                }
                if(cell.player.timeControlStatus == .playing){
                    cell.player.play()
                }else{
                    cell.player.pause()
                }
            }
        }
    }
    
    @objc func tapForward(_ sender: UIButton) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
            isPlaying = false
            
            let obj = challengesArr[sender.tag % challengesArr.count]
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
        self.slidView.isHidden = true
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
            isPlaying = false
            
            if(videoFinshed){
                videoFinshed = false
            }
            let obj = challengesArr[sender.tag % challengesArr.count]
            self.rewindVideo(by: 5.0,obj:obj,cell:cell)
            backButtonTapped = true
            if(cell.player.timeControlStatus == .playing){
                obj.player?.play()
                backButtonTapped = false
            }else{
                obj.player?.pause()
            }
        }
        
    }
    
    @objc func tapBackward(_ sender: UIButton) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
            isPlaying = false
            
            if(videoFinshed){
                videoFinshed = false
            }
            let obj = challengesArr[sender.tag % challengesArr.count]
            self.rewindVideo(by: 5.0,obj:obj,cell:cell)
            backButtonTapped = true
            if(cell.player.timeControlStatus == .playing){
                obj.player?.play()
                backButtonTapped = false
            }else{
                obj.player?.pause()
            }
        }
        
    }
    
    //end video player
    
    func setupFilter(filter: FilterType){
        filterType = filter
        switch filter {
        case .trending:
            filterButton.setTitle("Trending", for: .normal)
        case .following:
            filterButton.setTitle("Following", for: .normal)
        case .general:
            filterButton.setTitle("General", for: .normal)
        default:
            //  filterButton.setTitle("", for: .normal)
            break
        }
    }
    
    
    
    //MARK:- Open Controller Method
    func openDonateScreen(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        self.slidView.isHidden = true
        cell.player.pause()
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            self.timer.invalidate()
            self.removeAllObject()
            
            if let vc = UIStoryboard.wallet.get(DonateMoneyViewController.self){
                vc.userId = obj.user_id
                vc.userName = obj.username
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
    
    func manageMuteUnmute(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        isPlayerMute = !isPlayerMute
        cell.player.isMuted = isPlayerMute
        cell.muteButton.isSelected = isPlayerMute
        cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
        
    }
    
    func openMessageScreen(cell:ChallengeListCollectionViewCell, obj: RewardsModel){
        self.slidView.isHidden = true
        cell.player.pause()
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            
            if  obj.setting == "2" || obj.is_following == 1 {
                self.timer.invalidate()
                self.removeAllObject()
                
                if let vc = UIStoryboard.message.get(ChatViewController.self){
                    //vc.user.user_id = obj.user_id
                    //vc.user.username = obj.username
                    //vc.user.image = obj.user_image
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else if obj.request_status == "0" {
                AlertController.alert(message: "\(obj.user_name ?? "") \(ValidationMessage.RequestedFollow.rawValue)")
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
    
    func openFeedScreen(cell:ChallengeListCollectionViewCell){
        self.slidView.isHidden = true
        self.timer.invalidate()
        self.completion?()
        cell.player.pause()
        self.removeAllObject()
        tabBarController?.selectedIndex = 0
        
        
        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    func openUserProfileScreen(cell:ChallengeListCollectionViewCell, obj: RewardsModel,index: Int){
        self.slidView.isHidden = true
        if obj.is_sponsered != "1"{
            if obj.user_id == AuthManager.shared.loggedInUser?.user_id {
            }else {
                cell.player.pause()
                self.timer.invalidate()
                self.removeAllObject()
                
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.isFromSwipe = true
                    vc.user.user_id = obj.user_id
                    vc.user.image = obj.user_image
                    vc.index = index
                    vc.isFromHome = self.isFromHome
                    vc.blockCompletion = { userId in
                        self.removeAllObject()
                        if !self.isFromHome {
                            self.getVideoList()
                        }else {
                            if self.challengesArr.count > 0 {
                                for (index,item) in self.challengesArr.enumerated() {
                                    if item.user_id == "\(userId)" {
                                        self.challengesArr.remove(at: index)
                                        if self.challengesArr.count > 0 {
                                            if index == 0 {
                                                self.current_index = 0
                                            }else {
                                                self.current_index = index - 1
                                            }
                                            
                                            delay(delay: 0.1) {
                                                self.collectionView.reloadData()
                                            }
                                        }else {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                                
                            }else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
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
                    vc.index = index
                    vc.isFromHome = self.isFromHome
                    vc.blockCompletion = { userId in
                        self.removeAllObject()
                        if !self.isFromHome {
                            self.getVideoList()
                        }else {
                            if self.challengesArr.count > 0 {
                                for (index,item) in self.challengesArr.enumerated() {
                                    if item.user_id == "\(userId)" {
                                        self.challengesArr.remove(at: index)
                                        if self.challengesArr.count > 0 {
                                            if index == 0 {
                                                self.current_index = 0
                                            }else {
                                                self.current_index = index - 1
                                            }
                                            
                                            delay(delay: 0.1) {
                                                self.collectionView.reloadData()
                                            }
                                        }else {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                                
                            }else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
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
    
    func openProfileScreen(cell:ChallengeListCollectionViewCell){
        cell.player.pause()
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            self.timer.invalidate()
            self.removeAllObject()
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
            if isFromHome {
                
                
                let dateSt = "\(Date().toMillis() ?? 0)"
                if Int(self.startTime ?? "0") ?? 0 > Int(dateSt) ?? 0 {
                    AlertController.alert(title: "Alert", message: "You can't participate in this challenge as it has yet not started.")
                }else if Int(self.endTime ?? "0") ?? 0 < Int(dateSt) ?? 0 {
                    AlertController.alert(title: "Alert", message: "You can't participate in this challenge because it has been completed.")
                }else  if check_if_participated == "1" {
                    AlertController.alert(title: "Alert", message: "You have already participated in this challenge.")
                }else {
                    self.timer.invalidate()
                    if let vc = UIStoryboard.challenge.get(ChallengeShootViewController.self){
                        vc.challengeId = self.challenge_id
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else {
                self.timer.invalidate()
                if let vc = UIStoryboard.challenge.get(ChallengeShootViewController.self){
                    vc.challengeId = self.challenge_id //obj.challenge.challenge_id
                    vc.isFromList = true
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
    //Ratnesh
    func openShareScreen(cell: ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        self.slidView.isHidden = true
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            
            self.timer.invalidate()
           
            //AppUtility.createDynamicLinkWithFirebase("\(obj.video_id ?? "0")", "", "\(obj.video_thumbnail ?? "")" ,superViewController: self, username: obj.user_name ?? "")
            AppUtility.createDynamicLinkWith("\(obj.video_id ?? "0")", "", "\(obj.video_thumbnail ?? "")" ,superViewController: self, username: obj.user_name ?? "")
            
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
        let obj = self.challengesArr[(indexPath?.row ?? 0) % challengesArr.count]
        switch gesture.direction {
        case .left:
            self.openUserProfileScreen(cell: cell, obj: obj, index: ((indexPath?.row ?? 0) % (challengesArr.count)) )
        case .right:
            if obj.is_sponsered != "1" {
                if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                    if self.is_prime_time == "1"{
                        if obj.is_voted_prime == 0 {
                            self.primeVoteVideo(obj: obj, index: ((indexPath?.row ?? 0) % (challengesArr.count)),isFromSwipe: true)
                        }else {
                            AlertController.alert(message: "You have already voted.")
                        }
                      //  self.voteVideo(obj: obj, index: ((indexPath?.row ?? 0) % (challengesArr.count)) ,isFromSwipe: true)
                    }else {
                        if obj.is_voted == 1{
                            AlertController.alert(message: "You have already voted.")
                        }else {
                            self.voteVideo(obj: obj, index: ((indexPath?.row ?? 0) % (challengesArr.count)) ,isFromSwipe: true)
                        }
                    }
                    
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
    
    
    @objc func muteTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        let cell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0))as!ChallengeListCollectionViewCell
        
        cell.player.isMuted = !cell.player.isMuted
        cell.muteButton.isSelected = cell.player.isMuted
        cell.muteLabel.text = !cell.player.isMuted ? "Unmute" : "Mute"
    }
    
    @objc func muteLongTap(_ gesture: UILongPressGestureRecognizer) {
        
        let location = gesture.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        self.slidView.isHidden  = false
        delay(delay: 3) {
        }
    }
    
    
    
    //MARK:- UIButton Method
    @IBAction func homeButtonAction(_ sender: UIButton){
        tabBarController?.selectedIndex = 0
        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    @IBAction func filterButtonAction(_ sender: UIButton){
        isFilter = true
    }
    
    @IBAction func trendButtonAction(_ sender: UIButton){
        self.slidView.isHidden = true
        self.timer.invalidate()
        isFilter = false
        offset = 0
        current_index = 0
        filterType = .trending
        setupFilter(filter: .trending)
        removeAllObject()
        challengesArr.removeAll()
        self.collectionView.reloadData()
        getVideoList()
    }
    @IBAction func followingButtonAction(_ sender: UIButton){
        self.slidView.isHidden = true
        self.timer.invalidate()
        isFilter = false
        offset = 0
        filterType = .following
        current_index = 0
        setupFilter(filter: .following)
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            removeAllObject()
            challengesArr.removeAll()
            getVideoList()
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
    @IBAction func generalButtonAction(_ sender: UIButton){
        self.slidView.isHidden = true
        self.timer.invalidate()
        isFilter = false
        offset = 0
        current_index = 0
        filterType = .general
        setupFilter(filter: .general)
        removeAllObject()
        challengesArr.removeAll()
        self.collectionView.reloadData()
        getVideoList()
    }
    @IBAction func crossButtonAction(_ sender: UIButton){
        self.slidView.isHidden = true
        isFilter = false
        setupFilter(filter: .none)
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
                        self.cellPlayerIconManage(cell: cell)
                        cell.player.play()
                    }
                }
            }) {
                
            }
        }
    }
    
    @objc func plusButtonAction(_ sender:UIButton){
        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? ChallengeListCollectionViewCell {
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
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}


extension ChallengeListViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return  challengesArr.count == 0 ? 0 : 10000 //challengesArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeListCollectionViewCell", for: indexPath) as! ChallengeListCollectionViewCell
        
        if challengesArr.count > 0 {
            let obj = challengesArr[indexPath.row % challengesArr.count]
            
            let muteTapGesture = UITapGestureRecognizer(target: self, action: #selector(muteTap(_ :)))
            let muteLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(muteLongTap(_ :)))
            muteLongGesture.minimumPressDuration = 1
            cell.audioView.addGestureRecognizer(muteTapGesture)
            cell.audioView.isUserInteractionEnabled = true
            self.cellPlayerIconManage(cell: cell)
            cell.tapBackwardButton.isHidden = true
            cell.tapForwardButton.isHidden = true
            if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                if let url = URL(string: AuthManager.shared.loggedInUser?.image ?? "") {
                    cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
                }
            }
            
            if let url = URL(string: obj.video_thumbnail_new ?? "") {
                cell.thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
            }
            
            cell.captionLabel.isHidden = false
            if self.is_prime_time == "1" {
                
                if obj.is_voted_prime == 0 {
                    cell.voteButton.isSelected = false
                    cell.voteLabel.text = "Vote"
                }else {
                    cell.voteButton.isSelected = true
                    cell.voteLabel.text = "Unvote"
                }
                
//                if obj.is_voted_two_times == 0 {
//                    cell.voteButton.isSelected = false
//                    cell.voteLabel.text = "Vote"
//                } else if obj.is_voted_two_times == 1 {
//                    cell.voteButton.isSelected = false
//                    cell.voteLabel.text = "Vote"
//                }else {
//                    cell.voteButton.isSelected = true
//                    cell.voteLabel.text = "Unvote"
//                }
                
                
                
//                cell.voteButton.isSelected = obj.is_voted_two_times == 2
//                cell.voteLabel.text = obj.is_voted_two_times == 2 ? "Unvote" : "Vote"
            }else {
                cell.voteButton.isSelected = obj.is_voted == 1
                cell.voteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
            }
//            cell.voteButton.isSelected = obj.is_voted == 1
//            cell.voteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
            
            if obj.is_sponsered == "1"
                || obj.user_id == AuthManager.shared.loggedInUser?.user_id || AuthManager.shared.loggedInUser?.user_id == nil {
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
            
            cell.followButton.isSelected = obj.is_following == 1
            if obj.is_following == 0, obj.request_status == "" {
                cell.followButton.isSelected = false
                cell.followLabel.text = "Follow"
            }else if obj.setting == "1" , obj.is_following == 0, obj.request_status == "0" {
                cell.followLabel.text = "Requested"
            }else if obj.is_following == 1{
                cell.followButton.isSelected = true
                cell.followLabel.text = "Unfollow"
            }else {
                cell.followLabel.text = "Follow"
                cell.followButton.isSelected = false
            }
            
            cell.challengeNameLabel.isHidden = true
            cell.playPauseButton.addTarget(self, action: #selector(playPauseButtonAction(_:)), for: .touchUpInside)
            cell.forwardButton.addTarget(self, action: #selector(multipleTapForward(_:event:)), for: UIControl.Event.touchDownRepeat)
            cell.backwardButton.addTarget(self, action: #selector(multipleTapBackward(_:event:)), for: UIControl.Event.touchDownRepeat)
            
            
            cell.tapForwardButton.addTarget(self, action: #selector(tapForward(_ :)), for: .touchUpInside)
            cell.tapBackwardButton.addTarget(self, action: #selector(tapBackward(_ :)), for: .touchUpInside)
            
            cell.backwardButton.tag = indexPath.row
            cell.tapForwardButton.tag = indexPath.row
            cell.tapBackwardButton.tag = indexPath.row
            cell.menuButton.tag = indexPath.row
            cell.muteButton.tag = indexPath.row
            cell.forwardButton.tag = indexPath.row
            cell.playPauseButton.tag = indexPath.row
            cell.plusButton.tag = indexPath.row
            cell.menuButton.addTarget(self, action: #selector(menuButtonAction(_:)), for: .touchUpInside)
            cell.plusButton.addTarget(self, action: #selector(plusButtonAction(_:)), for: .touchUpInside)
            
            cell.rightStackView.isHidden = true
            cell.bottomStackView.isHidden = true
            cell.profileButton.isHidden = true
            
            cell.setPlayer(object: obj)
            cell.player.isMuted = isPlayerMute
            
            cell.muteButton.isSelected = isPlayerMute
            cell.muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
            
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
            swipeGesture.direction = .left
            let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
            swipeGesture1.direction = .right
            cell.innerView.tag = indexPath.row % challengesArr.count
            
            cell.innerView.isUserInteractionEnabled =  true
            cell.innerView.addGestureRecognizer(swipeGesture)
            cell.innerView.addGestureRecognizer(swipeGesture1)
            
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
            
            obj.player?.volume = Float(playerVolume)
            cell.messageClickCompletion = {
                self.openMessageScreen(cell:cell, obj: obj)
            }
            
            cell.muteClickCompletion = {
                self.manageMuteUnmute(cell:cell, obj: obj)
            }
            
            cell.followClickCompletion = {
                if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                    
                    if obj.setting == "1" , obj.is_following == 0, obj.request_status == "0" {
                        AlertController.alert(title: "Warning", message: "Are you sure you want to cancel follow request?", buttons: ["Yes","No"]) { (alert, index) in
                            if index == 0 {
                                self.acceptRejectRequestUser(obj: obj)
                            }
                        }
                    }
                    
                    else {
                        self.followUnfollowUser(obj: obj)
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
            
            cell.shareClickCompletion = { [weak self] in
                cell.player.pause()
                if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                    self?.showActionSheet(cell: cell,obj: obj)
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
            
            cell.donateClickCompletion = { [weak self] in
                self?.openDonateScreen(cell: cell, obj: obj)
            }
            
            cell.feedClickCompletion = { [weak self] in
                self?.openFeedScreen(cell:cell)
            }
            
            cell.shootClickCompletion = { [weak self] in
                cell.player.pause()
                if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                    self?.showActionSheet(cell: cell,obj: obj)
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
                if obj.is_sponsered != "1" {
                    if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
                        if self?.is_prime_time == "1" {
                            self?.primeVoteVideo(obj: obj, index: indexPath.row)
                        }else {
                            self?.voteVideo(obj: obj, index : indexPath.row)
                        }
                        
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
            
            cell.profileClickCompletion = { [weak self] in
                self?.openProfileScreen(cell:cell)
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: Window_Width , height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ChallengeListCollectionViewCell {
            cell.captionLabel.isHidden = false
            cell.isVideoPlay = true
            cell.thumbnailImageView.isHidden = false
        }
        
        if challengesArr.count > 0 {
            let obj = challengesArr[indexPath.row % challengesArr.count]
            
            self.viewCount(obj: obj)
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                self.hideLabel(index: indexPath.row )
                self.timer.invalidate()
            })
        }
        
    }
    
    func hideLabel(index: Int){
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? ChallengeListCollectionViewCell
        cell?.captionLabel.isHidden = true
        if self.challengesArr.count > 0 {
            
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if  challengesArr.count <= 0  { return }
        let pageWidth = scrollView.frame.size.height
        var last_index = Int(floor((scrollView.contentOffset.y - pageWidth * 0.5) / pageWidth) + 1)
        print("last_index: \(last_index)")
        last_index = last_index % challengesArr.count
        self.last_index = last_index
        
        if challengesArr.isEmpty {return}
        
        self.challengesArr[last_index].player?.pause()
        self.challengesArr[last_index].removeObserver()
        self.challengesArr[last_index].isPlayed = false
        self.challengesArr[last_index].player?.pause()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if  challengesArr.count <= 0  { return }
        
        let pageWidth = scrollView.frame.size.height
        var current_index = Int(floor((scrollView.contentOffset.y - pageWidth * 0.5) / pageWidth) + 1)
        current_index = current_index % challengesArr.count
        
        self.current_index = current_index
        
        
        self.handlePlayer()
    }
    
    
    func handlePlayer() {
        if let cell = collectionView.cellForItem(at: IndexPath(row: last_index, section: 0)) as? ChallengeListCollectionViewCell {
            cell.isVideoPlay = true
            cell.thumbnailImageView.isHidden = false
            cell.playPauseButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapForwardButton.setImage(UIImage.init(named: ""), for: .normal)
            cell.tapBackwardButton.setImage(UIImage.init(named: ""), for: .normal)
        }
        
        for (index,item) in challengesArr.enumerated() {
            item.removeObserver()
            item.isPlayed = false
            item.player?.pause()
            
        }
        
        if challengesArr.isEmpty {return}
        self.challengesArr[current_index].removeObserver()
        self.challengesArr[current_index].addObserver()
        self.challengesArr[current_index].isPlayed = true
        if !self.isSlide {
            self.challengesArr[current_index].player?.seek(to: .zero)
        }
        self.challengesArr[current_index].player?.play()
        self.challengesArr[current_index].player?.volume = Float(self.playerVolume)
        
        if !isFromHome {
            if self.current_index % 5 == 0 && current_index > 0 {
                self.offset = offset + 10
                if !isLastIndex {
                    self.getVideoList(loader: false)
                }
            }
        }
    }
    
}

extension ChallengeListViewController {
    func rotateAnimation(imageView:UIButton,duration: CFTimeInterval = 5.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        imageView.layer.add(rotateAnimation, forKey: nil)
    }
}

extension ChallengeListViewController {
    
    //MARK:- Switching the Page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.height
        var currentPage = Int(floor((scrollView.contentOffset.y - pageWidth * 0.5) / pageWidth) + 1)
        if currentPage < 0 || challengesArr.count <= 0  { return }
        currentPage = currentPage % challengesArr.count
        
        if self.currentPage == currentPage {
            return
        }
        
        if  let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? ChallengeListCollectionViewCell {
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
        
    }
    
    func reportVideo(obj: RewardsModel, cell: ChallengeListCollectionViewCell, reportMessage: String){
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
    
    func voteVideo(obj: RewardsModel,index : Int, isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        
        if isFromSwipe {
            self.playVoteSound()
            if self.is_prime_time == "1"{
                param["flag"] = 1
            } else {
                param["flag"] = obj.is_voted == 0 ? 1 : 0
            }
        }else {
            param["flag"] = obj.is_voted == 0 ? 1 : 0
        }
        
        param["challenge_id"] = challenge_id
        
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                
                if let cell = self.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? ChallengeListCollectionViewCell {
                    if isFromSwipe {
                        if self.is_prime_time == "1"{
                            obj.is_voted = 1
                            cell.voteButton.isSelected =  true
                            cell.voteLabel.text = "Unvote"
                        }else {
                            obj.is_voted = obj.is_voted == 0 ? 1 : 0
                            cell.voteButton.isSelected =  obj.is_voted == 1
                            cell.voteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                        }
                    }else {
                        obj.is_voted = obj.is_voted == 0 ? 1 : 0
                        cell.voteButton.isSelected =  obj.is_voted == 1
                        cell.voteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                    }
                    
                    if isFromSwipe {
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
        

     
        param["challenge_id"] = challenge_id
        
        
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
    
    func getVideoList(loader: Bool = true){
        var param = [String: Any]()
        param["limit"] = "10"
        param["offset"] = "\(offset)"
        param["video_filter"] = filterType == .general ?  "6" :  filterType == .trending ? "5"
            : "7"
        
        param["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        param["device_type"] = "2"
        param["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        WebServices.getChallengeVideoList(params: param, loadMore: loader) { (response) in
            if let arr = response?.array {
                if self.offset == 0 {
                    self.challengesArr = arr
                    if self.challengesArr.count > 0 {
                        DispatchQueue.main.async {
                            self.currentPage = 0
                            self.collectionView.reloadData()
                            self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .top, animated: false)
                            
                        }
                    }
                    
                    self.collectionView.reloadData()
                } else {
                    if arr.count == 0 {
                        self.isLastIndex = true
                    }else {
                        self.isLastIndex = false
                        self.challengesArr.append(contentsOf: arr)
                    }
                }
                
                if self.offset == 0 && !self.challengesArr.isEmpty && self.isViewAppeared{
                    if self.challengesArr.first?.player == nil {
                        if let url = URL(string: self.challengesArr.first?.aws_video_path ?? "") {
                            self.challengesArr.first?.player = AVPlayer(url: url)
                            self.challengesArr.first?.isPlayed = true
                            if (self.challengesArr.first?.player?.rate ?? 1) == 0 {
                            }
                            self.challengesArr.first?.removeObserver()
                            self.challengesArr.first?.addObserver()
                        }
                    }
                    delay(delay: 1) {
                        if self.isViewAppeared {
                            self.currentPage = 0
                            self.challengesArr.first?.addObserver()
                            self.challengesArr.first?.player?.play()
                        }
                    }
                } else {
                    
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.noDataView.isHidden =  self.challengesArr.count != 0
            }
        }
        
    }
    
    func getInitialVideoList(loader: Bool = false){
        var param = [String: Any]()
        param["limit"] = "10"
        param["offset"] = "\(offset)"
        param["video_filter"] = filterType == .general ?  "6" :  filterType == .trending ? "5"
            : "7"
        
        param["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        param["device_type"] = "2"
        param["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        WebServices.getChallengeVideoList(params: param, loadMore: loader) { (response) in
            if let arr = response?.array {
                print("add hua")
                self.challengesArr.append(contentsOf: arr)
                self.collectionView.reloadData()
            }
        }
    }
    
    func followUnfollowUser(obj: RewardsModel){
        var param  = [String: Any]()
        param["follow_status"] = obj.is_following == 1 ? 0 : 1
        param["following_id"] = obj.user_id
        
        WebServices.followUnfollowUser(params: param) { (response) in
            if response?.statusCode == 200 {
                if obj.setting == "1" {
                    obj.is_following =  0
                    obj.request_status = "0"
                }else {
                    obj.is_following = obj.is_following == 1 ? 0  : 1
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func acceptRejectRequestUser(obj: RewardsModel){
        var param  = [String: Any]()
        param["primary_key_follow_id"] = obj.primary_key_follow_id
        param["follow_status"] = "3"
        
        WebServices.acceptRejectRequest(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.is_following = 0
                obj.request_status = ""
                self.collectionView.reloadData()
            }
        }
    }
    func removeDuplicateElements(videos: [RewardsModel]) -> [RewardsModel] {
        var uniqueDateArr = [RewardsModel]()
        for item in challengesArr {
            if !uniqueDateArr.contains(where: {$0.video_id == item.video_id }) {
                uniqueDateArr.append(item)
            }
        }
        return uniqueDateArr
    }
    
}


extension ChallengeListViewController {
    func showActionSheet(cell: ChallengeListCollectionViewCell, obj: RewardsModel) {
        
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor = .red
        
        let appGalleryAction = UIAlertAction(title: "Share To External", style: .default, handler:
                                                {
                                                    (alert: UIAlertAction!) -> Void in
                                                    if Reachabilityy.isConnectedToNetwork() {
                                                        self.openActivityController(cell: cell, obj: obj)
                                                    }else{
                                                        AlertController.alert(message: "No internet Connection.")
                                                    }
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
        self.timer.invalidate()
        //AppUtility.createDynamicLinkWithFirebase("\(obj.video_id ?? "0")", "", "\(obj.video_thumbnail ?? "")" ,superViewController: self, username: obj.user_name ?? "")
        print("check========",("\(obj.video_id ?? "0")", "", "\(obj.video_thumbnail ?? "")" ,superViewController: self, username: obj.user_name ?? ""))
        AppUtility.createDynamicLinkWith("\(obj.video_id ?? "0")", "", "\(obj.video_thumbnail ?? "")" ,superViewController: self, username: obj.user_name ?? "")
    }
    
    func openShare(cell: ChallengeListCollectionViewCell, obj: RewardsModel){
        cell.player.pause()
        self.timer.invalidate()
        if let vc = UIStoryboard.challenge.get(ChallengeShareViewController.self){
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.videoObj = obj
            vc.videoId = obj.video_id
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}



extension ChallengeListViewController {
    @objc func tappedUserLabel(_ sender: UITapGestureRecognizer){
        let index = sender.view?.tag ?? 0
        let obj = challengesArr[index % challengesArr.count]
        let text = obj.video_text?.base64Decoded()
        
        var user_names = [String]() // extract only @prefix items
        
        let splittedTextArray = text?.split(separator: " ")
        
        
        for index in 0 ..< splittedTextArray!.count {
            if splittedTextArray?[index].contains("@") ?? false {
                user_names.append(String(splittedTextArray?[index] ?? ""))
            }
        }
        
        let userRange = (text! as NSString).range(of: text ?? "")
        
        if sender.didTapAttributedTextInLabel(label: sender.view as! UILabel, inRange: userRange) {
            pushToUserProfile(USER_ID: "1")
        }
        
    }
    
    func pushToUserProfile(USER_ID user_id: String) {
        
        if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
            vc.user.user_id = user_id
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}



public class Reachabilityy {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}
