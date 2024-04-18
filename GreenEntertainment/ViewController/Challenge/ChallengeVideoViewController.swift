//
//  ChallengeVideoViewController.swift
//  GreenEntertainment
//
//  Created by Sunil Joshi on 16/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AVKit
import MediaPlayer
import ActiveLabel

import RxSwift


class ChallengeVideoViewController: UIViewController{
    @IBOutlet weak var lblVideoExist: UILabel!
    @IBOutlet weak var viewVideoExist: UIView!
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var videPlayerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgViewPreview: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var totalTimeDurationLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var doubleTapForward: UIButton!
    @IBOutlet weak var doubleTapBackward: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navLabel: UILabel!
    @IBOutlet weak var postBottomView: UIView!
    @IBOutlet weak var centerPlayButton: UIButton!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var voteLeftLabel: UILabel!
    @IBOutlet weak var viewLeftLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sliderView: MPVolumeView!
    
    @IBOutlet weak var voteView: UIView!
    @IBOutlet weak var unvoteLabel: UILabel!
    @IBOutlet weak var unvoteButton: UIButton!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var muteLabel: UILabel!
    
    var homeObj = HomeModel()
    var capturedImage = UIImage()
    //    var delegate: EditProfileViewController!
    var player = AVPlayer()
    var videoFinshed = false
    var viewTouched = false
    var backButtonTapped = false
    var firstTime = true
    var isfromPost = false
    var videoType: VideoType = .myPost
    var isPhotoPreview = false
    var isOtherUser = false
    var videoURL: URL?
    var file: AttachmentInfo?
    var videoObj = RewardsModel()
    var aVAudioPlayer: AVAudioPlayer?
    var isShareVideo = false
    var isFromTagVideo = false
    
    var videoList = [VideosModel]()
    var dispose_Bag = DisposeBag()

    
    var isFirstVideo = true
    var videoId = ""
    var shareMessage = ""
    var challenge_id = "0"
    var user_id = "0"
    var blocked_status: String?
    var check_if_you_block : String?
    public typealias CompletionBlock = (_ success: Bool, _ data: Data, _ error: Error?) -> Void
    
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderView.showsVolumeSlider = false
        sliderView.isHidden = true
        if(isfromPost){
            self.topView.isHidden = true
            self.galleryButton.isHidden = false
        }
        
        getVideoList()
        
        doubleTapForward.addTarget(self, action: #selector(multipleTapForward(_:event:)), for: UIControl.Event.touchDownRepeat)
        doubleTapBackward.addTarget(self, action: #selector(multipleTapBackward(_:event:)), for: UIControl.Event.touchDownRepeat)
        
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(handleViewPress))
        outerView.addGestureRecognizer(tapGestureView)
        
        if !isPhotoPreview {
            player.isMuted = isPlayerMute
            muteButton.isSelected = isPlayerMute
            muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
            //            if isFromTagVideo{
            //                self.getVideoDetail()
            //            }
            
            if isShareVideo || isFromTagVideo {
                self.getVideoDetail()
            }else {
                if videoType == .winningVideo {
                    if blocked_status == "1" {
                        AlertController.alert(title: "", message: "User not found.", buttons: ["OK"]) { (alert, index) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        //AlertController.alert(message: "User not found.")
                        self.imgViewPreview.isHidden = true
                    } else if check_if_you_block == "1" {
                        self.imgViewPreview.isHidden = true
                        AlertController.alert(title: "", message: "You blocked this account. To watch video unblock the user from settings.", buttons: ["OK"]) { (alert, index) in
                            self.navigationController?.popViewController(animated: true)
                        }
                      //  AlertController.alert(title: "", message: "You blocked this account. To view profile unblock the user from settings.")
                    }else {
                        //self.imgViewPreview.isHidden = false
                        setUpVideoPlayerViewController()
                    }
                }else {
                    setUpVideoPlayerViewController()
                }
                
                if(videoObj.video_thumbnail != nil){
                    if let url = URL(string: videoObj.video_thumbnail ?? "") {
                        self.imgViewPreview.kf.setImage(with: url, placeholder: UIImage(named: ""))
                    }
                }else{
                    let url = videoURL
                    let thumbnailImage = getThumbnailImage(forUrl: url!)
                    imgViewPreview.image = thumbnailImage
                }
            }
            outerView.isHidden = true
            
            self.bottomView.isHidden = true
            self.centerPlayButton.isHidden = false
            self.customiseView()
        }
        else {
        }
        self.activityIndicator.isHidden = true
        
        if videoType == .winningVideo {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeForUser(_ :)))
            swipeGesture.direction = .left
            let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeForUser(_ :)))
            swipeGesture1.direction = .up
            
            self.view.isUserInteractionEnabled =  true
            self.view.addGestureRecognizer(swipeGesture)
            self.view.addGestureRecognizer(swipeGesture1)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        firstTime = true
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.pause()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        // self.removeFromParent()
        player.pause()
        //self.player.replaceCurrentItem(with: nil)
    }
    
    //MARK:- Helper Method
    func customiseView(){
        
        let voteDouble = Double(videoObj.votes_count ?? "0") ?? 0.0
        let voteStr = voteDouble > 1 ? "\(voteFormatPoints(num: voteDouble)) Votes" : "\(voteFormatPoints(num: voteDouble)) Vote"
        voteLabel.attributedText = voteStr.getAttributedString( voteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        
        challengeLabel.text = videoObj.challenge.title
        
        let viwsDouble = Double(videoObj.views_count ?? "0") ?? 0.0
        let likeStr = viwsDouble > 1 ? "\(voteFormatPoints(num: viwsDouble)) Views" : "\(voteFormatPoints(num: viwsDouble)) View"
        likeLabel.attributedText = likeStr.getAttributedString(viwsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        if isShareVideo {
            captionLabel.text = videoObj.video_text?.base64Decoded() //shareMessage.base64Decoded()
        }else {
            captionLabel.text = videoObj.video_text?.base64Decoded()
        }
        
        if isFromTagVideo {
            captionLabel.text = videoObj.video_text?.base64Decoded()
        }
        
        captionLabel.isUserInteractionEnabled = true
        captionLabel.customize { label in
            label.hashtagColor = .white
            label.mentionColor = .red
        }
        
        captionLabel.enabledTypes = [.mention, .hashtag]
        captionLabel.textColor = .white
        captionLabel.handleHashtagTap { hashtag in
            // print("Success. You just tapped the \(hashtag) hashtag")
        }
        
        captionLabel.handleMentionTap { (username) in
            self.getUserTapped(username: username, obj: self.videoObj)
            //print("Success. You just tapped the \(username) username")
        }
        
        
        let ongoingVoteDouble = Double(videoObj.votes_count ?? "0") ?? 0.0
        let ongoingVoteStr = ongoingVoteDouble > 1 ? "\(voteFormatPoints(num: ongoingVoteDouble)) Votes" : "\(voteFormatPoints(num: ongoingVoteDouble)) Vote"
        voteLeftLabel.attributedText = ongoingVoteStr.getAttributedString( voteDouble > 1 ? "Votes" : "Vote", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        
        challengeLabel.text = videoObj.challenge.title
        
        let ongoingViwsDouble = Double(videoObj.views_count ?? "0") ?? 0.0
        let ongoinglikeStr = ongoingViwsDouble > 1 ? "\(voteFormatPoints(num: ongoingViwsDouble)) Views" : "\(voteFormatPoints(num: ongoingViwsDouble)) View"
        viewLeftLabel.attributedText = ongoinglikeStr.getAttributedString(viwsDouble > 1 ? "Views" : "View", color: .white, font: Fonts.Rubik.regular.font(.small))
        
        switch videoType {
        case .gallery:
            self.topView.isHidden = false
            self.crossButton.isHidden = true
            self.navLabel.text = ""
            self.tickButton.isHidden = true
            self.postBottomView.isHidden = true
            // self.bottomView.isHidden = false
            self.bottomView.isHidden = true
            
            backButton.isHidden = false
            galleryButton.isHidden = true
            galleryLabel.isHidden = true
            player.play()
            outerView.isHidden = false
            leftView.isHidden = true
            if isShareVideo {
                // animationView.isHidden = false
                // animationImage.isHidden = false
                self.voteView.isHidden = false
                self.audioView.isHidden = false
                
                self.view.isUserInteractionEnabled = true
                let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
                swipeGesture.direction = .right
                self.view.addGestureRecognizer(swipeGesture)
            }
            
            if isFromTagVideo {
                self.voteView.isHidden = false
                self.audioView.isHidden = false
                
                self.view.isUserInteractionEnabled = true
                let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
                swipeGesture.direction = .right
                self.view.addGestureRecognizer(swipeGesture)
            }
            break
        case .myPost:
            self.topView.isHidden = false
            self.crossButton.isHidden = true
            self.navLabel.text = isOtherUser ? "Posts" : "My Posts"
            self.tickButton.isHidden = true
            self.postBottomView.isHidden = false
            self.bottomView.isHidden = true
            backButton.isHidden = false
            galleryButton.isHidden = true
            galleryLabel.isHidden = true
            player.play()
            outerView.isHidden = false
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
            swipeGesture.direction = .right
            self.view.addGestureRecognizer(swipeGesture)
            leftView.isHidden = true
            break
        case .myTrophy:
            self.topView.isHidden = false
            self.crossButton.isHidden = true
            self.navLabel.text = "Trophy Room"
            self.tickButton.isHidden = true
            self.postBottomView.isHidden = false
            self.bottomView.isHidden = true
            backButton.isHidden = false
            galleryButton.isHidden = true
            galleryLabel.isHidden = true
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
            swipeGesture.direction = .right
            self.view.addGestureRecognizer(swipeGesture)
            leftView.isHidden = false
            break
        case .videoShoot:
            break
        case .winningVideo:
            self.crossButton.isHidden = true
            self.navLabel.text = ""
            self.tickButton.isHidden = true
            self.postBottomView.isHidden = true
            // self.bottomView.isHidden = false
            self.bottomView.isHidden = true
            
            backButton.isHidden = false
            galleryButton.isHidden = true
            galleryLabel.isHidden = true
            player.play()
            outerView.isHidden = false
            leftView.isHidden = true
        }
    }
    func openUserProfileScreen(){
        
        if user_id == AuthManager.shared.loggedInUser?.user_id {
            UserDefaults.standard.set(true, forKey: "movetoProfile")
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                vc.isFromSwipe = true
                vc.user.user_id = self.user_id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func openVideoViewerScreen(){
        if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
            //vc.fromInitialTab = true
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.navigationController = navigationController
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    @objc func handleSwipeForUser(_ gesture: UISwipeGestureRecognizer) {
        
        // print("index::::\(indexPath?.row ?? 0)")
        
        switch gesture.direction {
        case .left:
            self.openUserProfileScreen()
            break
        case .up:
            //
            self.openVideoViewerScreen()
        default:
            break
        }
    }
    
    func initialMethod(){
        
    }
    
    func getVideoList() {
        Logs.show(message: "Saved Vids :::: ")
        
        APIService
            .singelton
            .getAllVideos()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            Logs.show(message: "Saved Vids : \(val)")
                            self.videoList = val
                            
                            //self.navigateToVideoPlayerVC()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "No Videos available")
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
    
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func rewindVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        var newTime = CMTimeGetSeconds(currentTime) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }
    
    func forwardVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        let duration = player.currentItem?.duration
        var newTime = CMTimeGetSeconds(currentTime) + seconds
        if newTime >= CMTimeGetSeconds(duration!) {
            newTime = CMTimeGetSeconds(duration!)
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }
    
    func setUpVideoPlayerViewController() {
        let videoURl = (videoObj.aws_video_path != nil ? (URL(string:videoObj.aws_video_path ?? "")) : videoURL)!
        //  if let videoURL = videoObj.video_path{
        
        //   let url = URL(string:videoURL)!
        let avPlayer = AVPlayer(url: videoURl)
        let avPlayerViewController = AVPlayerViewController()
        player = avPlayer
        var isFirstTime = true
        
        //new
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player.currentTime())
                self.remainingTimeLabel.text = "\(self.stringFromTimeInterval(interval: time))"
                self.updateVideoPlayerSlider()
            }
        }
        
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.player.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                
                if let isPlaybackLikelyToKeepUp = self?.player.currentItem?.isPlaybackLikelyToKeepUp {
                    //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
                    //  print("isPlaybackLikelyToKeepUp::--\(isPlaybackLikelyToKeepUp)")
                    //self?.activityIndicator.isHidden = isPlaybackLikelyToKeepUp
                    // self?.activityIndicator.startAnimating()
                    self?.imgViewPreview.isHidden = isPlaybackLikelyToKeepUp
                    
                }
                if let currentTime = avPlayerViewController.player?.currentItem?.currentTime().seconds {
                    if currentTime > 2 {
                        if isFirstTime {
                            self?.viewCount(obj: self?.videoObj ?? RewardsModel())
                            isFirstTime = false
                        }
                    }
                    
                }
            }
        }
        
        
        if videoType == .winningVideo {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue:
                                                    OperationQueue.main) { [weak self] notification in //1
                guard let strongSelf = self else { return } //2
                print(" ======== = = == = = == video ended called = == =  == = =  ")
                self?.videoObj.video_path = self?.videoObj.intro_video_path ?? ""
                if let url = self?.videoObj.video_path , !url.isEmpty {
                    if self?.isFirstVideo ?? false {
                        strongSelf.setUpVideoPlayerViewController()
                        delay(delay: 1) {
                            strongSelf.player.play()
                        }
                        self?.isFirstVideo = false
                    }
                }
            }
        }else {
            
        }
        
        let totalDuration : CMTime = player.currentItem!.asset.duration
        let totalSeconds : Float64 = CMTimeGetSeconds(totalDuration)
        totalTimeDurationLabel.text = self.stringFromTimeInterval(interval: totalSeconds)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        avPlayerViewController.player = avPlayer
        self.addChild(avPlayerViewController)
        avPlayerViewController.view.frame = CGRect(x: videPlayerView.frame.origin.x, y: 0, width: videPlayerView.frame.size.width, height: videPlayerView.frame.size.height)
        //  avPlayerViewController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
        avPlayerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
        
        avPlayerViewController.showsPlaybackControls = false
        videPlayerView.addSubview(avPlayerViewController.view)
        avPlayerViewController.didMove(toParent: self)
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
    
    func animatieVote(){
        self.animationView.isHidden = false
        self.animationImage.isHidden = false
        playVoteSound()
        
        do {
            let gif = try UIImage(gifName: "ChallengeAnim.gif")
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
    
    func getUserTapped(username: String, obj: RewardsModel){
        let user = obj.tagged_user.filter({$0.username == username}).first ?? TaggedUser()
        if user.user_id != nil {
            self.taggedUserProfile(obj: user)
        }
    }
    
    func taggedUserProfile(obj: TaggedUser){
        self.player.pause()
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if obj.user_id == AuthManager.shared.loggedInUser?.user_id {
                self.player.pause()
                UserDefaults.standard.set(true, forKey: "movetoProfile")
                self.navigationController?.popToRootViewController(animated: true)
            }else {
                self.player.pause()
                if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                    vc.isFromSwipe = true
                    vc.user.user_id = obj.user_id
                    // vc.user.image = obj.user_image
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
    
    
    //MARK:- Target Method
    @objc func multipleTapForward(_ sender: UIButton, event: UIEvent) {
        //        setUpVideoPlayerViewController()
        outerView.isHidden = false
        
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            if(!videoFinshed){
                self.forwardVideo(by: 5.0)
            }
            if(player.timeControlStatus == .playing){
                player.play()
                //   playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
            }else{
                player.pause()
            }
            
        }
    }
    
    @objc func multipleTapBackward(_ sender: UIButton, event: UIEvent) {
        outerView.isHidden = false
        if(videoFinshed){
            videoFinshed = false
        }
        self.rewindVideo(by: 5.0)
        backButtonTapped = true
        if(player.timeControlStatus == .playing){
            player.play()
            backButtonTapped = false
        }else{
            player.pause()
        }
        
    }
    
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        player.seek(to: CMTime.zero)
        player.play()
        videoFinshed = true
    }
    
    @objc func handleViewPress(sender: UITapGestureRecognizer) {
        if videoType == .myPost || videoType == .myTrophy{
            
        }else{
            if (!viewTouched){
                viewTouched = true
                self.bottomView.isHidden = true
            }else{
                viewTouched = false
                self.bottomView.isHidden = true
                
            }
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            
            if isShareVideo || isFromTagVideo {
                if self.videoObj.challenge.is_prime_time == "1"{
                    
                    if self.videoObj.challenge.is_prime_time == "1" {
                        if videoObj.is_voted_prime == 1 {
                            self.primeVoteVideo(obj: videoObj, isFromSwipe: true)
                        }else {
                           // self.playVoteSound()
                          //  self.primeVoteVideo(obj: videoObj, isFromSwipe: true)
                            AlertController.alert(message: "You have already voted.")
                        }
                    }else {
                        self.playVoteSound()
                        self.voteVideo(obj: self.videoObj, isFromSwipe: true)
                    }
                  //  voteVideo(obj: self.videoObj, isFromSwipe: true)
                }else {
                    if videoObj.is_voted == 1{
                        AlertController.alert(message: "You have already voted.")
                    }else {
                        voteVideo(obj: self.videoObj, isFromSwipe: true)
                        self.playVoteSound()
                    }
                }
                
            } else {
                if videoObj.is_voted == 1{
                    AlertController.alert(message: "You have already voted.")
                }else {
                    voteVideo(obj: self.videoObj, isFromSwipe: true)
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
    
    
    //MARK:- UIButton Action Method
    @IBAction func centerPlayButtonAction(_ sender: UIButton) {
        outerView.isHidden = false
        firstTime = false
        
        if(player.timeControlStatus == .playing){
            player.pause()
            backwardButton.isHidden = false
            forwardButton.isHidden = false
            doubleTapForward.setImage(UIImage.init(named: "icn_forward"), for: .normal)
            doubleTapBackward.setImage(UIImage.init(named: "icn_backward"), for: .normal)
            self.centerPlayButton.setImage(UIImage(named:"icn_play"), for: .normal)
        }else{
            player.play()
            backwardButton.isHidden = true
            forwardButton.isHidden = true
            doubleTapForward.setImage(UIImage.init(named: ""), for: .normal)
            doubleTapBackward.setImage(UIImage.init(named: ""), for: .normal)
            self.centerPlayButton.setImage(UIImage(named:""), for: .normal)
        }
        
    }
    @IBAction func playPauseButtonAction(_ sender: UIButton) {
        outerView.isHidden = false
        firstTime = false
        self.centerPlayButton.isHidden = true
        if(videoFinshed && !backButtonTapped){
            videoFinshed = false
            player.play()
        }
        if player.timeControlStatus == .playing  {
            player.pause()
            playPauseButton.setImage(UIImage.init(named: "icn_play"), for: .normal)
            forwardButton.setImage(UIImage.init(named: "icn_forward"), for: .normal)
            backwardButton.setImage(UIImage.init(named: "icn_backward"), for: .normal)
        }else {
            backButtonTapped = false
            if(player.currentItem == nil){
                setUpVideoPlayerViewController()
            }else{
                player.play()
            }
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        outerView.isHidden = false
        
        
        if(!videoFinshed){
            self.forwardVideo(by: 5.0)
        }
        if(player.timeControlStatus == .playing){
            player.play()
        }else{
            player.pause()
        }
    }
    @IBAction func backwardButtonAction(_ sender: UIButton) {
        outerView.isHidden = false
        
        if(videoFinshed){
            videoFinshed = false
        }
        self.rewindVideo(by: 5.0)
        backButtonTapped = true
        if(player.timeControlStatus == .playing){
            player.play()
            backButtonTapped = false
        }else{
            player.pause()
        }
    }
    
    
    @IBAction func saveToGalleryBtnAction(_ sender: UIButton) {
        saveVideo(savetoGallery: 1)
    }
    
    @IBAction func muteBtnAction(_ sender: UIButton) {
        
        isPlayerMute = !isPlayerMute
        player.isMuted = isPlayerMute
        muteButton.isSelected = isPlayerMute
        muteLabel.text = isPlayerMute ? "Unmute" : "Mute"
        
    }
    
    
    @IBAction func btnRetakeAction(_ sender: Any) {
        if isPhotoPreview {
            dismiss(animated: false, completion: nil)
        }
        else {
            AlertController.alert(title: "Alert", message: "Are you sure you want to retake video?", buttons: ["Yes","No"]) { (action, index) in
                if(index == 0){
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if isPhotoPreview {
        }
        else {
            saveVideo(savetoGallery: 0)
        }
    }
    
    func saveVideo(savetoGallery:Int){
        guard let _ = NSData(contentsOf: videoURL!)else { return }
        
        compressVideo(inputURL: videoURL!, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: self.compressedURL)else { return }
                self.callApiForSaveVideo(data:compressedData, isSaveToGallery: savetoGallery)
            case .failed:
                break
            case .cancelled:
                break
            @unknown default:
                break
            }
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnShareAction(_ sender: Any) {
        if let vc = UIStoryboard.challenge.get(ChallengeShareViewController.self){
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.videoId = self.videoObj.video_id
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnVoteAction(_ sender: Any) {
        if self.videoObj.challenge.is_prime_time == "1" {
            self.primeVoteVideo(obj: videoObj)
        }else {
            self.voteVideo(obj: self.videoObj)
        }
       // voteVideo(obj: self.videoObj)
    }
    // For slider :-
    //MARK:- UISlider Target Method
    @IBAction func handlePlayheadSliderTouchBegin(_ sender: UISlider) {
        outerView.isHidden = false
        player.pause()
    }
    
    @IBAction func handlePlayheadSliderValueChanged(_ sender: UISlider) {
        
        let duration : CMTime = player.currentItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration) * Double(sender.value)
        remainingTimeLabel.text = self.stringFromTimeInterval(interval: seconds)
    }
    
    @IBAction func handlePlayheadSliderTouchEnd(_ sender: UISlider) {
        
        let duration : CMTime = player.currentItem!.asset.duration
        let newCurrentTime: TimeInterval = Double(sender.value) * CMTimeGetSeconds(duration)
        let seekToTime: CMTime = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        player.seek(to: seekToTime)
        if(player.timeControlStatus == .playing){
            player.play()
        }else{
            player.pause()
        }
    }
    
    
    
    //new end
    
    func updateVideoPlayerSlider() {
        let currentTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        let mins = currentTimeInSeconds / 60
        let secs = currentTimeInSeconds.truncatingRemainder(dividingBy: 60)
        let timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return
        }
        if let currentItem = player.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                // Do sth
                return;
            }
            let currentTime = currentItem.currentTime()
            slider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType =  AVFileType.mp4 //AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
}


extension ChallengeVideoViewController{
    
    func callApiForSaveVideo(data:NSData,isSaveToGallery:Int){
        var params = [String: Any]()
        params["is_save_to_gallery"] = isSaveToGallery
        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
        var videoData = self.file ?? AttachmentInfo()
        videoData.apiKey = Constants.kVideo_File
        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
            
            if(isSaveToGallery == 0){
                if let obj = resposne?.object  {
                    if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
                        vc.videoID = obj.video_id
                        vc.videoURL = self.videoURL
                        vc.file = self.file
                        vc.data = data
                        vc.homeObj = self.homeObj
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else{
                if let vc = UIStoryboard.challenge.get(GalleryViewController.self) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
    }
    
    func getVideoDetail() {
        var params = [String: Any]()
        params["video_id"] = self.videoId
        
        WebServices.getVideoDetail(params: params, successCompletion: { (response) in
            if let  obj = response?.object {
                self.videoObj = obj
                if self.videoObj.is_deleted == 1{
                    self.viewVideoExist.isHidden = false
                    self.lblVideoExist.isHidden = false

                }else{
                self.lblVideoExist.isHidden = true
                self.viewVideoExist.isHidden = true
                self.imgViewPreview.isHidden = false
                self.setUpVideoPlayerViewController()
                if(self.videoObj.video_thumbnail != nil){
                    if let url = URL(string: self.videoObj.video_thumbnail ?? "") {
                        self.imgViewPreview.kf.setImage(with: url, placeholder: UIImage(named: ""))
                    }
                }
                self.customiseView()
                self.captionLabel.isHidden = false
                self.challenge_id = (self.videoObj.challenge.challenge_id ?? "").count > 0 ? self.videoObj.challenge.challenge_id ?? "" : "0"
                self.unvoteButton.isSelected =  obj.is_voted == 1
                self.unvoteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                self.player.play()
                }
            }
        })
    }
    
    func viewCount(obj: RewardsModel){
        var param = [String:Any]()
        param["video_id"] = videoId
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
    
    
    func voteVideo(obj: RewardsModel, isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = videoId
        param["challenge_id"] = challenge_id
        if isFromSwipe {
            if self.videoObj.challenge.is_prime_time == "1"{
                param["flag"] = 1
            }else {
                param["flag"] = obj.is_voted == 0 ? 1 : 0
            }
        }else {
            param["flag"] = obj.is_voted == 0 ? 1 : 0
        }
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                if isFromSwipe {
                    if self.videoObj.challenge.is_prime_time == "1"{
                        self.videoObj.is_voted =  1
                        self.unvoteButton.isSelected =  true
                        self.unvoteLabel.text =  "Unvote"
                    }else {
                        self.videoObj.is_voted = obj.is_voted == 0 ? 1 : 0
                        self.unvoteButton.isSelected =  obj.is_voted == 1
                        self.unvoteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                    }
                }else {
                    self.videoObj.is_voted = obj.is_voted == 0 ? 1 : 0
                    self.unvoteButton.isSelected =  obj.is_voted == 1
                    self.unvoteLabel.text = obj.is_voted == 1 ? "Unvote" : "Vote"
                }
            }
        else if response?.statusCode == 0 {
            if response?.message == "You have already given vote for this video!" {
                
            }else {
                AlertController.alert(message: "\(response?.message ?? "")")
            }
        }
    }
}
    
    func primeVoteVideo(obj: RewardsModel,isFromSwipe: Bool = false){
        
        var param = [String:Any]()
        param["video_id"] = obj.video_id
        
        if obj.is_voted_prime == 0 {
            param["flag"] = 1
        } else {
            param["flag"] = 0
        }
        
        if isFromSwipe {
          //  self.playVoteSound()
            param["flag"] = 1
        }
     
        param["challenge_id"] = obj.is_posted == "0" ?  challenge_id : obj.challenge.challenge_id
        
        
        WebServices.vote(params: param) { (response) in
            if response?.statusCode == 200 {
                    if obj.is_voted_prime == 0 {
                        obj.is_voted_prime = 1
                        self.unvoteButton.isSelected =  true
                        self.unvoteLabel.text = "Unvote"
                    } else {
                        self.unvoteButton.isSelected =  false
                        self.unvoteLabel.text = "Vote"
                        obj.is_voted_prime = 0
                    }
                    
                    if isFromSwipe {
                        obj.is_voted_prime = 1
                        self.unvoteButton.isSelected =  true
                        self.unvoteLabel.text = "Unvote"

                    }
                
                
            }else if response?.statusCode == 0 {
                if response?.message == "You have already given vote for this video!" {
                    
                }else {
                    AlertController.alert(message: "\(response?.message ?? "")")
                }
            }
        }
    }
    
}
