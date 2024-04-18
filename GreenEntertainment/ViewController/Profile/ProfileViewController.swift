//
//  ProfileViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import MKToolTip
import FirebaseAuth
import Firebase
import FirebaseDatabase
import CodableFirebase
import AVFoundation
import AVKit

import RxSwift

import Video
import VideoUI
import UIMultiPicker

enum VideoType {
    case gallery
    case myPost
    case myTrophy
    case videoShoot
    case winningVideo
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var walletBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var instaButton: UIButton!
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
    @IBOutlet weak var messageCountLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var navLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var settingCountLabel: UILabel!
    @IBOutlet weak var walletCountLabel: UILabel!
    
    @IBOutlet weak var giftBtn: UIButton!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    
    @IBAction func giftBtnPressed(_ sender: Any) {
    }
    @IBAction func doneBtnPressed(_ sender: Any) {
        pickerView.isHidden = true
        if selectedChalangesAray.count == 0 {
            AppFunctions.showSnackBar(str: "No Challenge Selected")
            return
        }
        participateChllenge(vidId: videoList[selectedIndex].id)
    }
    
    
    // @IBOutlet weak var badgeTableView: UITableView!
    
    var chalanges = [ChallengesModel]()
    var selectedChalangesAray = [Int]()
    var selectedChalangesArayIds = [String]()
    var chalangesArray = [String]()
    var challangeType = ""
    var selectedIndex = 0
    
    var userId = ""
    var chanelId = ""
    var chatModel = ChatModel()
    var isNew = false
    
    var addedToChallange = false
    
    var followingUserList = [FollowUsers()]
    var followerUserList = [FollowUsers()]
    var badge_thumbnail = [BadgeModel()]
    
    var cellHeight = 0
    var videoType: VideoType = .gallery
    var user = User()
    var isFromSwipe = false
    let imagePickerController = UIImagePickerController()
    var videoCount = 0
    var dynamic_error_message = ""
    
    var firstRowBadge = [Badge]()
    var secondRowBadge = [Badge]()
    var thirdRowBadge = [Badge]()
    
    var fb : String?, insta : String?, tt : String?, x : String?
    
    //var videoList = [[String: Any]]()

    
    var userProfile = [String : Any]()
    var videoList = [VideosModel]()
    var dispose_Bag = DisposeBag()
    //var badge_thumbnail = ["3_daily_wins","10_videos_made","10_voting_wins","20_videos_uploaded"]
    
    //private var videoList: [Video] = HardcodeDataProvider.getVideos() //= HardcodeDataProvider.getVideos()
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customiseView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = false
        getChalngesList()
        
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UserDefaults.standard.set(false, forKey: "movetoProfile")
        self.firstRowBadge.removeAll()
        self.secondRowBadge.removeAll()
        self.thirdRowBadge.removeAll()
        //getUserProfile()
        self.activityView.isHidden = true
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
        getCountApi()
        if goneToUser {
                        
            self.tabBarController?.tabBar.isHidden = true
            walletBtn.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
            messageBtn.setImage(UIImage(systemName: "ellipsis.message.fill"), for: .normal)
            settingBtn.setImage(UIImage(systemName: "person.slash.fill"), for: .normal)
            getUserProfile()
            getMessageHistory()
            
        } else if goneToVideo {
            self.tabBarController?.tabBar.isHidden = true
            walletBtn.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
            
            getVideoList()
        }
        //if Auth.auth().issi
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            if !goneToUser && !goneToVideo {
                self.getUserProfileNew()
                self.getMyProfile()
                self.getUserVideoList()
            }
        } else {
            if let vc = UIStoryboard.auth.get(LoginViewController.self) {
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.isHidden = true
                APPDELEGATE.navigationController = navigationController
                APPDELEGATE.window?.rootViewController = navigationController
            }
        }

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
                            
                            let video = val.filter({$0.id == videoToGo})
                            
                            navigateToVideoPlayerVC(video: video.first!)
                            
                        } else {
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
    
    func getUserVideoList() {
        Logs.show(message: "Saved Vids :::: ")
                
        APIService
            .singelton
            .getMyVideos()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            Logs.show(message: "Saved Vids : \(val)")
                            self.videoList.removeAll()
                            self.videoList = val
                            self.tableView.reloadData()
                            //self.navigateToVideoPlayerVC()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "No Videos available")
                            self.videoList.removeAll()
                            self.tableView.reloadData()
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
    
    
    func navigateToVideoPlayerVC(videoList: [VideosModel], ip: IndexPath) {
        ProgressHud.hideActivityLoader()
        
        /*var newVidList = [VideosModel]()
        
        for (index, element) in videoList.enumerated() {
            if index == vidIndex {
                newVidList.append(element)
            }
        }
        Logs.show(message: "\(newVidList)")*/
        let remoteVideoLoader = HardcodeVideoLoader(videos: videoList)
        let avVideoLoader = HLSVideoLoader(identifier: "cacheHLSVideoIdentifier", store: (self.store))
        
        
        let videoViewController = VideoUIComposer.videoComposedWith(videoloader: remoteVideoLoader, avVideoLoader: avVideoLoader, fromVC: "Profile", vidList: videoList, ip: ip) // CHECK HERE
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(videoViewController, animated: false)
    }
    
    func navigateToVideoPlayerVC(video: VideosModel) {
        ProgressHud.hideActivityLoader()
        
        var newVidList = [VideosModel]()
         
        newVidList.append(video)

        let remoteVideoLoader = HardcodeVideoLoader(videos: newVidList)
        let avVideoLoader = HLSVideoLoader(identifier: "cacheHLSVideoIdentifier", store: (self.store))
        
        
        let videoViewController = VideoUIComposer.videoComposedWith(videoloader: remoteVideoLoader, avVideoLoader: avVideoLoader, fromVC: "Feed", vidList: newVidList, ip: IndexPath(row: 0, section: 0)) // CHECK HERE
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(videoViewController, animated: false)
    }

    func getUserProfile() {
        
        APIService
            .singelton
            .getUserProfile(id: userToGo)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            
                            chanelId = val.id
                            
                            if val.profile_picture != nil {
                                if let url = URL(string: val.profile_picture ) {
                                    self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
                                    self.view.setNeedsLayout()
                                }
                            }
                            
                            if val.isFollow {
                                editBtn.setTitle("Unfollow", for: .normal)
                            } else {
                                editBtn.setTitle("Follow", for: .normal)
                            }
                            
                            if val.isBlocked {
                                settingBtn.tintColor = .white
                            }
                            
                            if let fb = val.facebook {
                                self.fb = fb
                            }
                            
                            if let insta = val.tiktok {
                                self.insta = insta
                            }
                            
                            if let tt = val.tiktok {
                                self.tt = tt
                            }
                            
                            if let x = val.x {
                                self.x = x
                            }
                            
                            if val.videos != nil {
                                if val.videos.count > 0 {
                                    Logs.show(message: "Saved Vids : \(val)")
                                    self.videoList.removeAll()
                                    self.videoList = val.videos
                                    self.tableView.reloadData()
                                    //self.navigateToVideoPlayerVC()
                                } else {
                                    //self.noVideoView.isHidden = false
                                    AppFunctions.showSnackBar(str: "No Videos available")
                                    self.videoList.removeAll()
                                    self.tableView.reloadData()
                                    ProgressHud.hideActivityLoader()
                                    
                                }
                            } else {
                                self.videoList.removeAll()
                                self.tableView.reloadData()
                                ProgressHud.hideActivityLoader()
                            }
                            
                            
                            if val.badge != nil {
                                self.badge_thumbnail = val.badge
                            }
                            
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
        
        if isFromSwipe {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_ :)))
            swipeGesture.direction = .right
            self.view.addGestureRecognizer(swipeGesture)
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func initialSetup(){
        followerLabel.text = "\(voteFormatPoints(num: Double(user.user_followers ?? 0)))"
        followingLabel.text = "\(voteFormatPoints(num: Double(user.user_followings ?? 0)))"
        //followerCountLabel.text = (user.user_followers ?? 0) > 1 ? "Followers" : "Follower"

        if let url = URL(string: user.image ?? "") {
            self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
        getUsername()
        topConstraint.constant = user.claimed_badges_list.count > 0 ? 10 : 25
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    func setHeaderHeight(){
        if user.claimed_badges_list.count == 0 {
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 220)
        }
        else if user.claimed_badges_list.count > 0 && user.claimed_badges_list.count < 8 {
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 260)
        }else if  user.claimed_badges_list.count > 7 && user.claimed_badges_list.count < 15{
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 320)
        }else {
            self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: 380)
        }
        self.view.layoutIfNeeded()
    }
    
    func getUserProfileNew(){
        let userDB = Database.database().reference()
        userDB.child("Users").child(Auth.auth().currentUser?.uid ?? "").getData { err, snap in
            if err != nil {
                Logs.show(message: "ERRR: \(err?.localizedDescription ?? "")")
            }
            Logs.show(message: "SNAP: \(String(describing: snap)))")
            if let userProf = snap?.value {
                self.userProfile = userProf as! [String: Any]
                if let fb = self.userProfile["social_fb"] {
                    self.fb = fb as? String
                }
                if let insta = self.userProfile["social_insta"] {
                    self.insta = insta as? String
                }
                if let tt = self.userProfile["social_tiktk"] {
                    self.tt = tt as? String
                }
                if let x = self.userProfile["social_x"] {
                    self.x = x as? String
                }
                if let profilePic_Url = self.userProfile["profilePic_Url"] {
                    let profilePicUrl = profilePic_Url as! String
                    if let url = URL(string: profilePicUrl ) {
                        self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
                        self.view.setNeedsLayout()
                    }
                }
            }
        }
        
        

        
        
        /*\.observeSingleEvent(of: .value, with: { snapshot in
            if let datasnap = snapshot.value as? Dictionary<String, Any> {
                //let user = User(userid: userId, userData: datasnap)

            }
        })*/
    }
    
    func getMyProfile() {
        
        APIService
            .singelton
            .getMyProfile()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            self.userId = val.id
                            if val.follower != nil {
                                self.followerUserList = val.follower
                            }
                            if val.following != nil {
                                self.followingUserList = val.following
                            }
                            if val.badge != nil {
                                self.badge_thumbnail = val.badge
                            }
                        
                            
                            if let fb = val.facebook {
                                self.fb = fb
                            }
                            
                            if let insta = val.tiktok {
                                self.insta = insta
                            }
                            
                            if let tt = val.tiktok {
                                self.tt = tt
                            }
                            
                            if let x = val.x {
                                self.x = x
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
    
    func getUsername(){
           DispatchQueue.global(qos: .background).async {
               do {
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
        DispatchQueue.main.async {
            self.activityView.isHidden = false
            self.indicator.isHidden = false
            self.indicator.startAnimating()
            if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
                //vc.videoType =  obj.is_posted == "1" ? .myPost : .gallery
                vc.videoObj = obj
                vc.videoURL = URL(string: obj.video_path ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
                self.activityView.isHidden = true
                self.indicator.isHidden = true
                self.indicator.stopAnimating()

            }
        }
      
    }
    
    func removeVideo(id: String, index: Int){
        AlertController.alert(title: "", message: "Are you sure you want to remove the video?",
                              buttons: ["Yes","No"]) { (alert, index) in
                                if index == 0 {
                                    self.callApiForRemoveVideo(id: id, index: index)
                                }
        }
    }
    
    func openPost(){
        if let vc = UIStoryboard.challenge.get(MyPostViewController.self) {
            vc.isMyProfile = true
            vc.videoType =   .gallery
//            vc.videoArr = arr
//            vc.videoId = obj.video_id ?? ""
//            vc.videoCount = videoCount
//            vc.dynamic_error_message = dynamic_error_message
//            vc.userName = "\(self.user.first_name ?? "") \(self.user.last_name ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func openChallengePost(obj: RewardsModel){
        if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
            vc.videoID = Int(obj.video_id ?? "0")
             vc.videoObj = obj
            vc.videoType = .gallery
            vc.videoURL = URL(string: obj.aws_video_path ?? "")
            vc.videoCount = videoCount
            vc.isFromProfile = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openTrophy(arr: [RewardsModel], obj: RewardsModel){
        if let vc = UIStoryboard.challenge.get(MyPostViewController.self) {
            vc.isMyProfile = true
            //vc.videoType =   .myTrophy
            vc.videoArr = arr
            vc.videoId = obj.video_id ?? ""
            vc.videoCount = videoCount
            vc.dynamic_error_message = dynamic_error_message
            vc.userName = "\(self.user.first_name ?? "") \(self.user.last_name ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func openVideoActionForTrophy(obj: RewardsModel){
        DispatchQueue.main.async {
            self.activityView.isHidden = false
            self.indicator.isHidden = false
            self.indicator.startAnimating()
            if let vc = UIStoryboard.challenge.get(ChallengeVideoViewController.self) {
                //vc.videoType =   .myTrophy
                vc.videoObj = obj
                vc.videoURL = URL(string: obj.video_path ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
                self.activityView.isHidden = true
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
            }
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        
        switch gesture.direction {
        case .right:
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    func setupSocialMediaButton(){
        self.tiktokButton.isEnabled = !(user.tiktokUserName?.isEmpty ?? true )
        self.fbButton.isEnabled = !(user.fbUserName?.isEmpty ?? true )
        self.instaButton.isEnabled = !(user.instaUserName?.isEmpty ?? true )
        self.twitterButton.isEnabled = !(user.twitterUserName?.isEmpty ?? true )

    }
    
    @objc func openProfileImage() {

    }
    
    func clearBadge(){
        self.firstRowBadge.removeAll()
        self.secondRowBadge.removeAll()
        self.thirdRowBadge.removeAll()
    }
    
    func setupMultiPickerView() {
        multiPickerView.options = chalangesArray
        
        multiPickerView.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        
        multiPickerView.color = .gray
        multiPickerView.tintColor = .white
        multiPickerView.font = .systemFont(ofSize: 18, weight: .semibold)
        
        multiPickerView.highlight(0, animated: false)
    }
    @objc func selected(_ sender: UIMultiPicker) {
        
        Logs.show(message: "Selected Index: \(sender.selectedIndexes)")
        
        selectedChalangesAray = sender.selectedIndexes
        Logs.show(message: "Selected CHALLENGES: \(selectedChalangesAray)")
        
    }
    
    func getMessageHistory(){
        
        let db = Firestore.firestore()

        let userIds = [userToGo, AppFunctions.getUserID()].compactMap { $0 }
        let sortedIds = userIds.sorted()
        chanelId = sortedIds.joined(separator: " - ")
        
        let collectionRef = db.collection("ChatUsers").document(chanelId)
        
        collectionRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                
                Logs.show(message: "CHAT: \(document)")
                let decoder = JSONDecoder()
                let dict = document.data()
                if let data = try?  JSONSerialization.data(withJSONObject: dict!, options: []) {
                    do {
                        let chat = try decoder.decode(ChatModel.self, from: data)
                        self?.chatModel = chat
                    } catch (let error) {
                        Logs.show(message: "No user: \(error)")
                    }
                }
                
            } else {
                Logs.show(message: "No chat")
                self?.isNew = true
            }
        }
        
    }
    
    func AddMessageUserList() {
        
        var user1 = [String:Any]()
        if Auth.auth().currentUser != nil {
            user1["sender_id"] = AppFunctions.getUserID()
            user1["receiver_id"] = userToGo
            user1["name"] = "ttt"
            user1["blockStatus"] = false
            user1["chatChannelId"] = userToGo + " - " + AppFunctions.getUserID()
            user1["profilePic"] = //videoList[AppFunctions.getRow()].user.profile_picture == nil ?
            "https://firebasestorage.googleapis.com:443/v0/b/squabble-42140.appspot.com/o/Images_Folder%2FprofImage_1664877616.jpg?alt=media&token=06573605-861a-4d75-a304-313d833a9b8f"
            //: videoList[AppFunctions.getRow()].user.profile_picture
            
            //db.collection("ChatUsers").document(videoList[AppFunctions.getRow()].user.id).setData(user1)
            
            let storyboard = UIStoryboard(name: "Message", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                let transition = CATransition()
                transition.duration = 0.5
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                transition.type = CATransitionType.fade
                self.navigationController?.view.layer.add(transition, forKey: nil)
                vc.user1 = user1
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK: UIButton Method
    @IBAction func walletButtonAction(_  sender: UIButton){
        if goneToUser {
            goneToUser = false
            goneToVideo = false
            userToGo = ""
            videoToGo = ""
            navigationController?.popViewController(animated: true)
        } else {
            if let vc = UIStoryboard.wallet.get(WalletViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    @IBAction func messageButtonAction(_  sender: UIButton){
        
        if goneToUser {
            if isNew {
                AddMessageUserList()
            } else {
                let storyboard = UIStoryboard(name: "Message", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.subtype = CATransitionSubtype.fromRight
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                    transition.type = CATransitionType.fade
                    self.navigationController?.view.layer.add(transition, forKey: nil)
                    vc.chatModel = chatModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            if let vc = UIStoryboard.message.get(MessageListViewController.self){
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @IBAction func tiktokButtonAction(_  sender: UIButton){
      //  https://www.tiktok.com/@(username)
        if let tiktok_url = tt , !tiktok_url.isEmpty{
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
        
        
        //    let appURL = URL(string: "fb://profile/\(Username)")!
        
        if let fb_url = fb , !fb_url.isEmpty{
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
                if let fburl = fb {
                    application.open(URL(string: fburl.isEmpty  ? "https://www.facebook.com"  : "https://www.facebook.com/\(fburl)")!)
                }
            }
        }else {
            AlertController.alert(message: "Facebook account not linked.")
        }
       
    }
    
    @IBAction func twitterButtonAction(_  sender: UIButton){
        
        if let twitter_url = x, !twitter_url.isEmpty {
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

        if let instagram_url = insta, !instagram_url.isEmpty {
            
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
        //videoType = .myPost
        tableView.reloadData()
    }
    
    @IBAction func trophyButtonAction(_  sender: UIButton){
        trophyView.isHidden = false
        postView.isHidden = true
        galleryView.isHidden = true
        trophyLabel.textColor = .white
        postLabel.textColor = KAppGrayColor
        galleryLabel.textColor = KAppGrayColor
        //videoType = .myTrophy
        tableView.reloadData()
    }
    
    @IBAction func editButtonAction(_  sender: UIButton){
        if goneToUser {
            AlertController.alert(title: "", message: "Follow this user?",
                                  buttons: ["Yes","Cancel"]) { (alert, index) in
                    self.followUnfollowUser()
                
            }
        } else {
            if let vc = UIStoryboard.profile.get(EditProfileViewController.self){
                vc.isFromEdit = true
                vc.user = self.user
                vc.userId = self.userId
                vc.userProfile = self.userProfile
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @IBAction func addButtonAction(_  sender: UIButton){
         showActionSheet()
       }
    
    @IBAction func settingsButtonAction(_  sender: UIButton){
        if goneToUser {
            AlertController.alert(title: "", message: "Are you sure you want to Block this user",
                                  buttons: ["Yes","No"]) { (alert, index) in
                    self.callApiForBlockUser()
                
            }
        } else {
            if let vc = UIStoryboard.main.get(SettingsViewController.self){
                navigationController?.pushViewController(vc, animated: true)
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
            vc.followingUserList = self.followingUserList
            vc.followingUserList = self.followingUserList
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ProfileViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == badgeTableView {
//           /*\ if user.claimed_badges_list.count < 7 {
//               return 1
//            }else if user.claimed_badges_list.count > 8 &&  user.claimed_badges_list.count < 14 {
//                return 2
//            }else {
//                  return 3
//            }*/
//            return badge_thumbnail.count
//        }else {
//            return 1
//        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView == badgeTableView {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileBadgeTableViewCell") as! ProfileBadgeTableViewCell
//            //cell.collectionView.delegate = self
//            //cell.collectionView.dataSource = self
//            //cell.collectionView.tag = indexPath.row
//            //cell.collectionView.reloadData()
//            return cell
//        }else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryTableViewCell") as! GalleryTableViewCell

        if trophyView.isHidden {
            cell.cellSetup2(arr: videoList, type: .gallery)
            cell.cellClicked = {
                index in
                DispatchQueue.main.async {
                    //self.openPost()
                    self.navigateToVideoPlayerVC(videoList: self.videoList, ip: index)
                }
            }
            if !self.videoList.isEmpty {
                cell.hideAddBtn(val: videoList)
            }
            
            cell.removeClicked =  { index in
                
                self.removeVideo(id: self.videoList[index.row].id, index: index.row)
            }
            
            cell.addClicked =  { index in
                Logs.show(message: "Add clicked")
                self.selectedIndex = index.row
                self.pickerView.isHidden = false
                self.selectedChalangesAray.removeAll()
                self.selectedChalangesArayIds.removeAll()
                self.multiPickerView.selectedIndexes = []
                self.multiPickerView.tag = index.row
            }
        } else {
            cell.cellSetup2(arr: [VideosModel](), type: .myTrophy)

        }
        
        
       /* switch videoType {
        case .myPost:
            cell.cellSetup(arr: self.user.app_gallery_posts, type: videoType, isFromProfile: true)
            cell.removeClicked =  { index in

                self.removeVideo(obj: self.user.app_gallery_posts[index.row], indexx: index.row)
            }
            cell.selectedRow = -1
            cell.cellClicked = {
                index in
                DispatchQueue.main.async {
                    self.openPost(arr: self.user.app_gallery_posts, obj: self.user.app_gallery_posts[index.row] )
                }
            }

            cell.addClicked = { index in
                self.openChallengePost(obj: self.user.app_gallery_posts[index])
            }
            break
        case .myTrophy:
            cell.cellSetupForTrophy(arr: self.user.user_trophy_videos, type: videoType)

            cell.cellClicked = {
                index in
                DispatchQueue.main.async {
                    self.openTrophy(arr: self.user.user_trophy_videos, obj:  self.user.user_trophy_videos[index.row] )
                }
            }
            break
        default:
            break
        }*/

        cellHeight   =  Int(cell.collectionView.frame.width / 2 + 60)
        return cell
        //}
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        if tableView == badgeTableView {
//            return 60
//        }else {

//
        return self.videoList.count == 0 ? Window_Height - 440 : CGFloat(cellHeight  * (self.videoList.count % 2 == 0 ? self.videoList.count / 2 : (self.videoList.count / 2) + 1 ))
    //}
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        \\if collectionView.tag == 0 {
//            return firstRowBadge.count
//        }else if collectionView.tag == 1 {
//             return secondRowBadge.count
//        }else {
//             return thirdRowBadge.count
//        }
        return badge_thumbnail.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileBadgeCollectionViewCell", for: indexPath) as! ProfileBadgeCollectionViewCell
        //cell.badgeImageView.image = UIImage(named: badge_thumbnail[indexPath.row])
        if let url = URL(string: badge_thumbnail[indexPath.row].thumbnail ?? "") {
            cell.badgeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        /*\if collectionView.tag == 0 {
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
        }*/
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 45, height: 45)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 50 * badge_thumbnail.count
        let totalSpacingWidth = 1 * (badge_thumbnail.count - 1)
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        
        /*\\if collectionView.tag == 0 {
                let totalCellWidth = 50 * firstRowBadge.count
                let totalSpacingWidth = 1 * (firstRowBadge.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
                let rightInset = leftInset
                
                return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
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
        }*/
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*\\if collectionView.tag == 0 {
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
        }*/
    }
}

//MARK: APIs

extension ProfileViewController {
    
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
        //self.badgeTableView.reloadData()
        delay(delay: 0.1) {
          //self.badgeTableView.reloadData()
        }
    }
//    func getUserProfile(){
//        var param = [String: Any]()
//        param["other_user_id"] = AuthManager.shared.loggedInUser?.user_id
//        WebServices.getUserProfile(params: param) { (response) in
//            if let obj = response?.object {
//                self.user = obj
//                self.clearBadge()
//                self.initialSetup()
//                self.getBadgeListData()
//                self.setHeaderHeight()
//                self.setupSocialMediaButton()
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    //self.badgeTableView.reloadData()
//
//                }
//                self.collectionView.reloadData()
//            }
//        }
//    }
    
    
    func getCountApi(){
        self.messageCountLabel.isHidden = true
        //self.messageCountLabel.text = "\(obj.unread_chat_count ?? 0)"
        
        self.settingCountLabel.isHidden = true
        //self.settingCountLabel.text = "\(obj.unread_setting_count ?? 0)"
        
        self.walletCountLabel.isHidden = true
        //self.walletCountLabel.text = "\(obj.unread_wallet_count ?? 0)"
        //self.dynamic_error_message = obj.dynamic_error_message ?? ""
    }
    
    func callApiForRemoveVideo(id: String, index: Int) {
        APIService
            .singelton
            .removeVideoFromProfile(vidId: id)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            Logs.show(message: "Saved Vids : \(val)")
                            AppFunctions.showSnackBar(str: "Video Deleted")
                            self.getUserVideoList()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in deleting video")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func callApiForBlockUser() {
        APIService
            .singelton
            .blockUser(userId: userToGo)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            Logs.show(message: "Saved Vids : \(val)")
                            AppFunctions.showSnackBar(str: "User Blocked")
                            self.getUserProfile()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in Blocking")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func followUnfollowUser() {
        APIService
            .singelton
            .followUnFollowUser(userId: userToGo)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val != "" {
                            Logs.show(message: "OBJ \(val)")
                            self.getUserProfile()
                            //AppFunctions.showSnackBar(str: "User added to followers")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func getChalngesList() {
        Logs.show(message: "Saved Vids :::: ")
        
        APIService
            .singelton
            .getChalenges()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            self.chalanges = val
                            self.chalangesArray = val.compactMap({ "\($0.name ?? "") -- \($0.type ?? "")"  })
                            self.setupMultiPickerView()
                            self.collectionView.reloadData()
                        } else {
                            AppFunctions.showSnackBar(str: "No Challenges available")
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
    
    func participateChllenge(vidId: String) {
        
        //ProgressHud.showActivityLoader()
        
        for selectedIndexOfCHArray in selectedChalangesAray {
            selectedChalangesArayIds.append(chalanges[selectedIndexOfCHArray].id)
        }
        
        let pram : [String : Any] = ["challenges": selectedChalangesArayIds]
        
        Logs.show(message: "SKILLS PRAM: \(pram) , \(vidId)")
        
        APIService
            .singelton
            .participateInChallenge(Pram: pram, vidId: vidId)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            AppFunctions.showSnackBar(str: "Video Added in challenge...")
                            self.addedToChallange = true
                            self.tabBarController?.selectedIndex = 0
                            ProgressHud.hideActivityLoader()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in Subscriptions")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
    
}

extension ProfileViewController {
    func showActionSheet() {
        
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor = .red
        
        let appGalleryAction = UIAlertAction(title: "Gallery", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            self.openGallery()
        })
        
        let libraryAction = UIAlertAction(title: "Library", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            self.openLibrary()
        })
        
        let shootAction = UIAlertAction(title: "Shoot", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            self.openShoot()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(appGalleryAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(shootAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func openShoot(){
        if let vc = UIStoryboard.challenge.get(ChallengeShootViewController.self){
            navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
    func openGallery(){
        if let vc = UIStoryboard.challenge.get(GalleryViewController.self){
            vc.isFromTabBar = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = ["public.movie"]
            imagePickerController.videoMaximumDuration = 60
            imagePickerController.isEditing = false
            imagePickerController.allowsEditing = false
            imagePickerController.videoQuality = .typeHigh
            if #available(iOS 11.0, *) {
                imagePickerController.videoExportPreset = AVAssetExportPresetPassthrough
            }
            present(imagePickerController, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        let videoURL = info[.mediaURL] as? NSURL
        print("Image Info:::\(info)")
        print("videoURL:::\(videoURL?.absoluteString ?? "")")
        if let url = videoURL {
            let asset = AVURLAsset.init(url: url as URL) // AVURLAsset.init(url: outputFileURL as URL) in swift 3
            // get the time in seconds
            let durationInSeconds = asset.duration.seconds
            
            if Int(durationInSeconds) < 5 {
                 Alerts.shared.show(alert: .warning, message: ValidationMessage.MinimumVideoLimit.rawValue, type: .warning)
            }
            
            else if Int(durationInSeconds) > 60 {
                Alerts.shared.show(alert: .warning, message: "Video file is too large.", type: .warning)
                return
            }else  {
                
                if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
                    vc.videoURL = url as URL
                    vc.thumbnailImage = self.getThumbnailImage(forUrl: url as URL)!
                    vc.isFromLibrary = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
       
            }
            
            
        }
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
             let asset: AVAsset = AVAsset(url: url)
             let imageGenerator = AVAssetImageGenerator(asset: asset)
             imageGenerator.appliesPreferredTrackTransform = true
             do {
                 let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
              return UIImage(cgImage: thumbnailImage).fixOrientation
             } catch let error {
                 print(error)
             }
             
             return nil
         }
    
}
