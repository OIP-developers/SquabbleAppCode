//
//  LeaderboardViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ScalingCarousel
import Video
import FirebaseAuth

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: ScalingCarouselView!
    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var noLabel: UILabel!
    
    var selectedIndex  =  0
    var items: [Int] = []
    
    var selectedChallengeVideosCount = 0
    
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()
    
    //var challenges = [HomeModel]()
    //var leaderBoardChallenges = [RewardsModel]()
    var challenge_id = ""
    
    var challengesModelArray = [ChallengesModel]()
    var videoList = [VideosModel]()

    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //getChallengeList()
        getWinnings()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        imageCollectionView.deviceRotated()
    }
    
    //MARK:- Target Method
    @objc func profileTapAction(){
        if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- Helper Method
    func openVideo(videoId: String ) {
        /*if let vc = UIStoryboard.challenge.get(MyPostViewController.self) {
            vc.isMyProfile = false
            vc.videoType =   .gallery
            //vc.videoArr = self.leaderBoardChallenges
            vc.videoId = videoId
            vc.isFromLeaderboard = true
            vc.challenge_id = self.challenge_id
            self.navigationController?.pushViewController(vc, animated: true)
            
        }*/
        
        
        
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

    func openProfile(userId: String ) {
        if userId == AuthManager.shared.loggedInUser?.user_id {
            UserDefaults.standard.set(true, forKey: "movetoProfile")
            self.navigationController?.popToRootViewController(animated: false)
        }else {
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self) {
                vc.user.user_id = userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func followUser(obj: UserAPIModel ) {
        if Auth.auth().currentUser != nil {
            self.followUnfollowUser(obj: obj)
        } else {
            self.showAlert()
        }
        
    }
    
    func showAlert() {
        // create the alert
        let alert = UIAlertController(title: "Alert", message: "You are not logged in Squabble App, want to login?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { action in
            
            // do something like...
            let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
            let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            vc.selectedIndex = 4
            self.navigationController?.pushViewController(vc, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            
            // do something like...
            alert.dismiss(animated: true)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func openShareScreen(obj: VideosModel){
        
        if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            showActionSheet(obj: obj)
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
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: API CALLS

    func getWinnings() {
        ProgressHud.showActivityLoaderWithTxt(text: "Fetching latest challenges...")
        
        APIService
            .singelton
            .getWinnings()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.first?.type ?? "")")
                            
                            self.challengesModelArray = val
                            
                            self.videoList = (val.first?.videos)!
                            self.selectedChallengeVideosCount = (val.first?.videos.count)!
                            
                            Logs.show(message: "\(self.challengesModelArray.count) ,, \(self.videoList.count)")

                            
                            self.collectionView.reloadData()
                            self.imageCollectionView.reloadData()
                            
                            ProgressHud.hideActivityLoader()
                        } else {
                            AppFunctions.showSnackBar(str: "No Winning Challenges")
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

    
}

extension LeaderboardViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 1  ? videoList.count : challengesModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardImageCollectionViewCell", for: indexPath) as! LeaderboardImageCollectionViewCell
            let obj = videoList[indexPath.row]
            cell.cellSetup(obj: obj)
            cell.nameLabel.text = "\(indexPath.row + 1)"

            cell.cellClicked = { status in
                //self.openVideo(videoId: self.videoList[indexPath.row].video_id ?? "")
                self.navigateToVideoPlayerVC(videoList: self.videoList, ip: indexPath)
            }
            
            cell.profileClicked = { status in
                self.openProfile(userId: self.videoList[indexPath.row].userId ?? "")
            }
            
            cell.shareClicked = { status in
                self.openActivityController(obj: self.videoList[indexPath.row])
            }
            
            cell.followClicked = { status in
                self.followUser(obj: self.videoList[indexPath.row].user)
            }
            
            DispatchQueue.main.async {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardNameCollectionViewCell", for: indexPath) as! LeaderboardNameCollectionViewCell
            let obj = challengesModelArray[indexPath.row]
            cell.nameLabel.text = obj.name
            if selectedIndex == indexPath.row  {
                cell.innerView.backgroundColor = .white
                cell.nameLabel.textColor =  .black
            }else {
                cell.nameLabel.textColor =  .white
                cell.innerView.backgroundColor = .clear
            }
            return  cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1{
            return CGSize(width: imageCollectionView.bounds.width - 80 , height: imageCollectionView.bounds.height)
        }else {
            let object  = challengesModelArray[indexPath.item]
            let labelSize = CGFloat((object.name?.width(withheight: 30, font: UIFont.systemFont(ofSize: 15)))! )
            return CGSize(width: collectionView.bounds.width > labelSize ? labelSize : collectionView.bounds.width - 20, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1{
            
        }else {
            selectedIndex = indexPath.item
            videoList = challengesModelArray[indexPath.row].videos
            self.collectionView.reloadData()
            self.imageCollectionView.reloadData()
            /*self.challenge_id = self.challenges[selectedIndex].challenge_id ?? ""
            self.getLeaderBoardData(challenegId: self.challenges[selectedIndex].challenge_id ?? "")*/
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageCollectionView.didScroll()
    }
}


extension LeaderboardViewController {
    func getChallengeList(){
        WebServices.getLeaderBoard { (response) in
            /*if let arr = response?.array {
                self.challenges = arr
                self.collectionView.reloadData()
                if self.challenges.count > 0 {
                    self.getLeaderBoardData(challenegId: self.challenges[self.selectedIndex].challenge_id ?? "")
                }
                self.noLabel.isHidden = self.challenges.count != 0
                
            }*/
        }
    }
    
    func getLeaderBoardData(challenegId: String){
        var param = [String: Any]()
        param["challenge_id"] = challenegId
        self.challenge_id = challenegId
        WebServices.fetchChallenege(params: param) { (resposne) in
            /*if let arr = resposne?.array {
                self.leaderBoardChallenges = arr
                self.imageCollectionView.reloadData()
                if self.leaderBoardChallenges.count > 0 {
                    self.imageCollectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredVertically, animated: false)
                }
                
                self.noLabel.isHidden = self.leaderBoardChallenges.count != 0
                
            }*/
        }
    }
    
    func followUnfollowUser(obj: UserAPIModel){
        followUnfollowUser(userId: obj.id)
        //AppFunctions.showSnackBar(str: "Token Expired, Follow didn't happend.")
    }
    func acceptRejectRequestUser(obj: RewardsModel){
        var param  = [String: Any]()
        param["primary_key_follow_id"] = obj.primary_key_follow_id
        param["follow_status"] = "3"
        
        WebServices.acceptRejectRequest(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.is_following = 0
                obj.request_status = ""
                self.imageCollectionView.reloadData()
            }
        }
    }
    
    func followUnfollowUser(userId: String) {
        APIService
            .singelton
            .followUnFollowUser(userId: userId)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val != "" {
                            Logs.show(message: "OBJ \(val)")
                            AppFunctions.showSnackBar(str: "User added to followers")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
}


extension LeaderboardViewController {
    func showActionSheet(obj: VideosModel) {
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor = .red
        
        let appGalleryAction = UIAlertAction(title: "Share To External", style: .default, handler:
                                                {
                                                    (alert: UIAlertAction!) -> Void in
                                                    self.openActivityController(obj: obj)
                                                })
        
        /*let libraryAction = UIAlertAction(title: "Share To Internal", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                self.openShare(obj: obj)
                                            })*/
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                print("Cancelled")
                                            })
        
        optionMenu.addAction(appGalleryAction)
        //optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func openActivityController(obj: VideosModel){
        AppUtility.createDynamicLinkWith("\(obj.id ?? "0")", "", obj.thumbnail_url ?? "" ,superViewController: self, username: obj.name ?? "")
    }
    
    func openShare(obj: RewardsModel){
        if let vc = UIStoryboard.challenge.get(ChallengeShareViewController.self){
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.videoObj = obj
            vc.videoId = obj.video_id
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
}
