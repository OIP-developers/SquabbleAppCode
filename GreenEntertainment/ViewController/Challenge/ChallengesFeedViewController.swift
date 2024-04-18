//
//  ChallengesFeedViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import AVKit
import Pulsator
import FlexiblePageControl

import Firebase
import FirebaseAuth
import FirebaseAnalytics
import Video
import CodableFirebase
import RxSwift

import SwiftDate

let valueAdedInIndexNumber = 1000000000

class ChallengesFeedViewController: UIViewController {
    
    @IBOutlet weak var searchBarHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var pageControl: FXPageControl!
    @IBOutlet weak var searchTopButton: UIButton!
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var liveButton: UIButton!
    
    private let refresher = UIRefreshControl()

    
    //var ChallengeArray = ["Daily Challenge","Weekly Challenge","Monthly Challenge"]
    var ChallengeArray = [String]()
    var ChallengeNameArray = [String]()
    var particpentArr = ["40","18","21"]
    var prizeArr = ["30","100","250"]
    var challengesModelArray = [ChallengesModel]()
    
    var offset = 0
    var refreshControl: UIRefreshControl!
    var listArray = [HomeModel]()
    var BannerArray = [BannersModel]()
    var timerValue = 0
    var timer = Timer()
    var selectedIndex = 0
    let imagePickerController = UIImagePickerController()
    var file: AttachmentInfo?
    var isMoreData = true
    var searchText = ""
    var token = ""
    var encoded_token = ""
    var liveModel = LiveModel()
    var videoCount = 0
    var dynamic_error_message = ""
    var videoUploadStatus = 0
    var video_upload_access_error_message = ""
    
    //var videoList = [[String:Any]]()
    var videoList = [VideosModel]()
    var voteVideoList = [VideosModel]()
    var dailyVids = [VideosModel]()
    var weeklyVids = [VideosModel]()
    var monthlyVids = [VideosModel]()
    
    var voteBtnPressedInRow = 0
    
    var challengeType = ""
    var dispose_Bag = DisposeBag()
    
    //private var videoList: [Video] = HardcodeDataProvider.getVideos() //= HardcodeDataProvider.getVideos()
    //private var videoList: [VideosModel] = HardcodeDataProvider.getVideos() //= HardcodeDataProvider.getVideos()
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.liveButton.isHidden = true
        customSetup()
        getBanners()
        Logs.show(message: "\(UserDefaults.standard.string(forKey: "loggedInUserUID") ?? "")")
        
        self.searchTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateLive(notfication:)), name: NSNotification.Name(rawValue: "UpdateLive"), object: nil)
        
        tableView.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        tableView.alwaysBounceVertical = true
        tableView.refreshControl = refresher // iOS 10
        tableView.addSubview(refresher)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timerValue = 0
        self.timer.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerValue = 0
        self.timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        timerValue = 0
        self.timer.invalidate()
        offset = 0
        
        isMoreData = true
        if searchText.isEmpty {
            getHomeVideosList()
            //callApiForChallengeList()
        }
        delay(delay: 0.3) {
            self.tableView.reloadData()
        }
        self.searchBarHeightConstant.constant = 0.0
        self.searchTopButton.isHidden = false
        
        
        
        let blockOperation = BlockOperation()
        
        blockOperation.addExecutionBlock {
            self.callApiForLiveStatus()
        }
        
        blockOperation.addExecutionBlock {
            if !(AuthManager.shared.loggedInUser?.auth_token?.isEmpty ?? true) {
                self.getCountApi()
            }
        }
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        operationQueue.addOperation(blockOperation)
        
        
        
    }
    
    override var   supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return  .portrait
        
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then a
        tableView.refreshControl?.beginRefreshing()
        getHomeVideosList()
        searchText = ""
    }
    
    func stopRefresher() {
        ProgressHud.hideActivityLoader()
        tableView.refreshControl?.endRefreshing()
    }
    
    func convertStringDateToTimeStamp(dateString: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: dateString)
        let dateStamp:TimeInterval = date!.timeIntervalSince1970
        return  Int(dateStamp)
    }

    
    @objc func updateLive(notfication: NSNotification){
        self.callApiForLiveStatus()
    }
    
    @objc func setTimer() {
        let now = Date().timeIntervalSince1970
        var endLblTxt = ""
        for (index, data) in self.challengesModelArray.enumerated() {
            var closingTime = 0
            
            if data.uploadCloseAt != nil {
                endLblTxt = "Uploading "
                if data.uploadCloseAt != "" {
                    closingTime = convertStringDateToTimeStamp(dateString: data.uploadCloseAt)
                }
            } else {
                endLblTxt = "Voting "
                if data.type == "weekly" || data.type == "monthly" {
                    let convertedTime = convertStringDateToTimeStamp(dateString: data.votingOpenAt)
                    if convertedTime > (Int(Date().timeIntervalSince1970)) {
                        if data.votingOpenAt != "" {
                            closingTime = convertStringDateToTimeStamp(dateString: data.votingOpenAt)
                        }
                    } else {
                        if data.votingCloseAt != "" {
                            closingTime = convertStringDateToTimeStamp(dateString: data.votingCloseAt)
                        }
                    }
                } else if data.votingCloseAt != "" {
                    closingTime = convertStringDateToTimeStamp(dateString: data.votingCloseAt)
                }
            }
            
            if closingTime != 0 {
                let remainingTime = closingTime - Int(now)
                let timeData = self.secondsToHoursMinutesSeconds(seconds: remainingTime)
                
                let labels = ["hourLabel", "minLabel", "secLabel"]
                let values = [timeData.0, timeData.1, timeData.2]
                
                for (i, _) in labels.enumerated() {
                    if let label = self.view.viewWithTag(index + (valueAdedInIndexNumber * (i+1))) as? UILabel {
                        if remainingTime <= 0 {
                            label.text = " --" + (i < labels.count - 1 ? " :" : "")
                        } else if values[i] < 10 {
                            label.text = " 0\(values[i])" + (i < labels.count - 1 ? " :" : "")
                        } else {
                            label.text = " \(values[i])" + (i < labels.count - 1 ? " :" : "")
                        }
                    }
                }
                
                if let statusLabel = self.view.viewWithTag(index + (valueAdedInIndexNumber * 6)) as? UILabel {
                    if data.type == "weekly" || data.type == "monthly" {
                        let convertedTime = convertStringDateToTimeStamp(dateString: data.votingOpenAt)
                        if convertedTime > (Int(Date().timeIntervalSince1970)) {
                            statusLabel.text = "\(endLblTxt)Starts In: "
                        } else {
                            statusLabel.text = "\(endLblTxt)Ends In: "
                        }
                    } else {
                        /*if remainingTime <= 0 {
                            statusLabel.text = "Time Passed"
                        } else if timeData.0 > 1 {*/
                        statusLabel.text = "\(endLblTxt)Ends In: "
                        /*} else {
                            statusLabel.text = "Starts In"
                        }*/
                    }
                }
            }
        }
    }

    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return ((seconds / 3600), (seconds / 60) % 60, seconds % 60)
    }

    
    func pullToRefersh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        self.timer.invalidate()
        self.offset = 0
        self.getHomeVideosList()
        refreshControl.endRefreshing()
    }
    
    
    func openVideoAction(arr: [RewardsModel], obj: RewardsModel, challenge_id: String,startTime: String, endTime: String,check_if_participated: String,challenge_type: String, isPrimeTime: String){
        DispatchQueue.main.async {
            
            if let vc = UIStoryboard.challenge.get(ChallengeListViewController.self) {
                vc.challengesArr = arr
                vc.isFromHome = true
                vc.videoId = obj.video_id ?? ""
                vc.challenge_id = challenge_id
                vc.startTime = startTime
                vc.endTime = endTime
                vc.challenge_type = challenge_type
                vc.is_prime_time = isPrimeTime
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    //MARK:- Helper Method
    func customSetup(){
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        pageControl.selectedDotColor = .white
        pageControl.dotColor = .clear
        pageControl.currentPage = 0
        pageControl.backgroundColor = .clear
        pageControl.dotSize = 8
        pageControl.dotBorderColor = .white
        pageControl.dotBorderWidth = 1
        pageControl.isHidden = false
    }
    
    func liveSetup(){
        
        let pulsator = Pulsator()
        pulsator.numPulse = 5
        pulsator.radius = 30.0
        pulsator.backgroundColor = UIColor.red.cgColor
        liveView.layer.addSublayer(pulsator)
        pulsator.start()
    }
    
    //MARK:- Target Method
    
    @objc func participateButtonAction(_ sender: UIButton){
        
        if Auth.auth().currentUser == nil {
            self.showAlert()
            return
        }
        
        if sender.tag == -1 {
            AppFunctions.showSnackBar(str: "You have already participated in this challenge!")
            return
        }
        
        if sender.tag == 0 || sender.tag >= 100 {
            //AppFunctions.showSnackBar(str: "Vote")
        voteBtnPressedInRow = sender.tag / 100
                var filteredChallenges = self.challengesModelArray.filter({$0.type ==  self.ChallengeArray.filter({$0 != ""})[voteBtnPressedInRow] && $0.name ==  self.ChallengeNameArray.filter({$0 != ""})[voteBtnPressedInRow]}).compactMap({ $0.videos }).reduce([], +)
                
                shuffled_indices = filteredChallenges.indices.shuffled()
                filteredChallenges = shuffled_indices.map { filteredChallenges[$0] }
                
                self.voteVideoList = filteredChallenges
                
            
            
            self.navigateToVideoPlayerVC(vidIndex: 0, videoList: voteVideoList, ip: IndexPath(row: 0, section: 0))
            
            
            return
        }
        /*switch sender.tag {
            case 1 :
                challengeType = "daily"
            case 2 :
                challengeType = "weekly"
            case 3 :
                challengeType = "monthly"
            default:
                print("")
        }*/
        
        AppFunctions.saveChalID(id: challengesModelArray[sender.tag].id)

        
        self.showActionSheet()
        /*if let vc = UIStoryboard.challenge.get(ParticipatePopupViewController.self){
            vc.isFromSetting = true
            vc.delegate = self
            //vc.obj = self.listArray[sender.tag]
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .custom
            self.navigationController?.present(vc, animated: true, completion: nil)
        }*/
        /*if let userloggedin = UserDefaults.standard.value(forKey: "loggedInUser") as? Bool , userloggedin {
            selectedIndex = sender.tag
            let obj = listArray[sender.tag]
            let dateSt = "\(Date().toMillis() ?? 0)"
            if Int(obj.start_timestamp ?? "0") ?? 0 > Int(dateSt) ?? 0 {
                AlertController.alert(title: "Alert", message: "You can't participate in this challenge as it has yet not started.")
            }else if Int(obj.end_timestamp ?? "0") ?? 0 < Int(dateSt) ?? 0 {
                AlertController.alert(title: "Alert", message: "You can't participate in this challenge because it has been completed.")
            }else {
                
                if AuthManager.shared.loggedInUser?.isAgreeToTermsnC == 1 {
                    if AuthManager.shared.loggedInUser?.isShowAgain == 1 {
                        let obj = self.listArray[sender.tag]
                        self.showActionSheet(obj: obj)
                    }else {
                        if let vc = UIStoryboard.challenge.get(ParticipatePopupViewController.self){
                            vc.isFromSetting = true
                            vc.delegate = self
                            vc.obj = self.listArray[sender.tag]
                            vc.modalTransitionStyle = .crossDissolve
                            vc.modalPresentationStyle = .custom
                            self.navigationController?.present(vc, animated: true, completion: nil)
                        }
                    }
                }else {
                    if let vc = UIStoryboard.challenge.get(ParticipatePopupViewController.self){
                        vc.isFromSetting = true
                        vc.delegate = self
                        vc.obj = self.listArray[sender.tag]
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .custom
                        self.navigationController?.present(vc, animated: true, completion: nil)
                    }
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
        }*/
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
    
    @IBAction func navigationSearchButtonAction(_ sender: UIButton) {
        
        if let vc = UIStoryboard.main.get(SearchViewController.self){
            vc.searchCompletion = { searchText in
                if searchText.isEmpty {
                    self.searchText = searchText
                }else {
                    self.searchText = searchText
                    self.searchChallenge()
                }
            }
            vc.searchText = self.searchText
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    //MARK:- UIButton Action Method
    @IBAction func leaderboardButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if let vc  =  UIStoryboard.main.get(LeaderboardViewController.self){
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func liveButtonAction(_ sender: UIButton){
//        self.view.endEditing(true)
//        if let vc = UIStoryboard.main.get(LiveWinnerViewController.self){
//            vc.token  = self.token
//            vc.encoded_token = self.encoded_token
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }

    func navigateToVideoPlayerVC(vidIndex: Int, videoList: [VideosModel], ip: IndexPath) {
        ProgressHud.hideActivityLoader()

        let remoteVideoLoader = HardcodeVideoLoader(videos: (videoList))
        let avVideoLoader = HLSVideoLoader(identifier: "cacheHLSVideoIdentifier", store: (self.store))
        
        
        let videoViewController = VideoUIComposer.videoComposedWith(videoloader: remoteVideoLoader, avVideoLoader: avVideoLoader, fromVC: "Feed", vidList: videoList, ip: ip)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(videoViewController, animated: false)
    }
    
    func getDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString) // replace Date String
    }
    
    
}

//MARK: CHALLENGEs Holder CV
extension ChallengesFeedViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChallengeArray.filter({$0 != ""}).count //listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeFeedTableViewCell") as! ChallengeFeedTableViewCell
        
        if (challengesModelArray[indexPath.row].type != "custom") {
            cell.nameLabel.text = "\(challengesModelArray[indexPath.row].type.capitalized ) \(challengesModelArray[indexPath.row].name ?? "")"
        } else {
            cell.nameLabel.text = "\(challengesModelArray[indexPath.row].name ?? "")"
        }
         //ChallengeArray[indexPath.row]
        cell.prizeLabel.text = " $\(challengesModelArray[indexPath.row].prize ?? 0)" //" $\(prizeArr[indexPath.row])"
        cell.prizeLabel.attributedText = getTextWithTokenImage(startString: "", price: " $\(challengesModelArray[indexPath.row].prize ?? 0)", imageAddtionalSize: 4, imageName: "ic_gift")
        cell.participantLabel.text = "\(challengesModelArray[indexPath.row].videos.count) Participants"
        
        cell.hourLabel.tag = indexPath.row + valueAdedInIndexNumber
        cell.minLabel.tag = indexPath.row + (valueAdedInIndexNumber * 2)
        cell.secLabel.tag = indexPath.row + (valueAdedInIndexNumber * 3)
        cell.daysLeftLabel.tag = indexPath.row + (valueAdedInIndexNumber * 4)
        cell.timeView.tag = indexPath.row + (valueAdedInIndexNumber * 5)
        cell.statusLabel.tag = indexPath.row + (valueAdedInIndexNumber * 6)
        
        cell.statusLabel.isHidden = false
        cell.timeLeftLabel.isHidden = false
        
       
        
        
        cell.hourLabel.isHidden = false
        cell.minLabel.isHidden = false
        cell.secLabel.isHidden = false
        cell.daysLeftLabel.isHidden = false
        cell.timeView.isHidden = false
        
        Logs.show(message: "ChallengeArray count: \(self.ChallengeArray.count)")
        Logs.show(message: "indexPath.row: \(indexPath.row)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            var filteredChallenges = self.challengesModelArray.filter({$0.type ==  self.ChallengeArray.filter({$0 != ""})[indexPath.row] && $0.name ==  self.ChallengeNameArray.filter({$0 != ""})[indexPath.row]}).compactMap({ $0.videos }).reduce([], +)
            
            shuffled_indices = filteredChallenges.indices.shuffled()
            filteredChallenges = shuffled_indices.map { filteredChallenges[$0] }
            
            cell.videoList = filteredChallenges
            self.voteVideoList = filteredChallenges
            cell.collectionView.reloadData()
            
        })
        
        
        cell.cellClicked =  { index, videoList in
            self.navigateToVideoPlayerVC(vidIndex: index.row, videoList: videoList, ip: index)
        }
        
        /*if challengesModelArray[indexPath.row].type != nil {
            switch challengesModelArray[indexPath.row].type {
                case "daily" :
                    cell.participateButton.tag = 1
                case "weekly" :
                    cell.participateButton.tag = 2
                case "monthly" :
                    cell.participateButton.tag = 3
                default:
                    print("")
            }
        }*/
        
        
       
        if (challengesModelArray[indexPath.row].uploadCloseAt != nil) {
            
            cell.participateButton.setTitle("Participate", for: .normal)
            if let isParticpent = challengesModelArray[indexPath.row].isParticipate {
                if isParticpent {
                    cell.participateButton.tag = -1
                } else {
                    cell.participateButton.tag = indexPath.row
                }
            }
        } else {
            cell.participateButton.setTitle("Vote", for: .normal)
            cell.participateButton.tag = 100 * indexPath.row
        }
        
       
        
        cell.participateButton.addTarget(self, action: #selector(participateButtonAction(_ :)), for: .touchUpInside)
        
        
       // cell.setupChallenge(arr: self.listArray[indexPath.row].challenge_video, obj:self.listArray[indexPath.row] )

        /*let obj = listArray[indexPath.row]
        cell.nameLabel.text = obj.title
//        if obj.price?.contains(find: ".") ?? false {
//            cell.prizeLabel.text = "$ \(obj.price ?? "")"
//        }else {
//            let dobPrize = Double(obj.price ?? "0.0")
//            cell.prizeLabel.text = String(format: "$ %.2f", dobPrize!)
//        }
        
        cell.prizeLabel.attributedText = getTextWithTokenImage(startString: "", price: " \(obj.price ?? "")", imageAddtionalSize: 4, imageName: "ic_gift")
        
        if let paticipientsCount = obj.no_of_participants{
            cell.participantLabel.text = Int(paticipientsCount) ?? 0 < 2 ? "\(paticipientsCount) Participant" :  "\(paticipientsCount) Participants"
        }
        
        if obj.challenge_type == "2" || obj.challenge_type == "3"  || (Int(obj.end_timestamp ?? "0") ?? 0 < (Int(Date().timeIntervalSince1970))) {
            cell.participateButton.isHidden = true
            cell.timeHeightConstraint.constant = 0
            cell.statusLabel.isHidden = true
        }else if  (Int(obj.start_timestamp ?? "0") ?? 0 > (Int(Date().timeIntervalSince1970))){
            cell.participateButton.isHidden = true
            cell.timeHeightConstraint.constant = 50
        } else {
            cell.participateButton.isHidden = false
            cell.participateButton.isEnabled = obj.check_if_participated == "0"
            cell.participateButton.backgroundColor = obj.check_if_participated == "1" ? .darkGray : .red
            cell.timeHeightConstraint.constant = 50
            cell.statusLabel.isHidden = false
            
        }
        
 
        
        cell.timeLeftLabel.isHidden = true
        cell.participateButton.tag = indexPath.row
        
        cell.participateButton.addTarget(self, action: #selector(participateButtonAction(_ :)), for: .touchUpInside)
        cell.setupChallenge(arr: self.listArray[indexPath.row].challenge_video, obj:self.listArray[indexPath.row] )
        cell.cellClicked =  { index in
            self.openVideoAction(arr: self.listArray[indexPath.row].challenge_video, obj: self.listArray[indexPath.row].challenge_video[index.row],challenge_id: self.listArray[indexPath.row].challenge_id ?? "",startTime: obj.start_timestamp ?? "" ,endTime: obj.end_timestamp ?? "",check_if_participated: obj.check_if_participated ?? "",challenge_type: obj.challenge_type ?? "", isPrimeTime: obj.isPrimeTime ?? "")
        }
         

        
        cell.removeClicked = {
            indexx in
            AlertController.alert(title: "", message: "Are you sure you want to remove video?",
                                  buttons: ["Yes","No"]) { (alert, index) in
                if index == 0 {
                    self.callApiForRemoveVideo(obj: obj, index: indexx.row)
                    
                }
            }
            
        }*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = self.challengesModelArray[indexPath.row]
        if obj.videos.count == 0 {
            return 160
        } else {
            return 245   //350
        }
        /*else {
            if obj.type == "weekly" || obj.type == "monthly"  {
                return 195  // 300
            } else if obj.type == "daily" && (Int(convertStringDateToTimeStamp(dateString: obj.votingCloseAt ?? "0")) < (Int(Date().timeIntervalSince1970))) {
                return 245   //  300
            }
            else {
                return 245   //350
            }
            
        }*/
    }
    
    
}
//MARK: Banner CV
extension ChallengesFeedViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BannerArray.count //self.liveModel.banner_image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeFeedCollectionViewCell", for: indexPath) as! ChallengeFeedCollectionViewCell
        cell.challengeImageView.contentMode = .scaleAspectFill
        if let url = URL(string: self.BannerArray[indexPath.item].thumbnail ?? "") {
            cell.challengeImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_bg_card"))
        } else {
            cell.challengeImageView.image = UIImage(named: "sizzle_card")
        }
        
        
        //cell.challengeImageView.image = UIImage(named: "sizzle_card")

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
//       \\ if self.token.isEmpty {
//            self.openLink(obj: liveModel.banner_image[indexPath.row])
//        }else {
//            if indexPath.row == 0 {
//                if let vc = UIStoryboard.main.get(LiveWinnerViewController.self){
//                    vc.token  = self.token
//                    vc.encoded_token = self.encoded_token
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
            pageControl.currentPage = Int(pageNumber)
        }
    }
    
    func openLink(obj: BannerModel){
        if let link = URL(string: obj.link ?? "") {
            UIApplication.shared.open(link)
        }
    }
}


extension ChallengesFeedViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.searchBarHeightConstant.constant = 0.0
            self.searchTopButton.isHidden = false
            self.view.layoutIfNeeded()
        })
        
        if searchTextField.text?.count ?? 0 > 0 {
            self.timer.invalidate()
            searchChallenge()
        }else {
            self.timer.invalidate()
            callApiForChallengeList()
        }
    }
}

extension ChallengesFeedViewController{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.searchBarHeightConstant.constant = 0.0
            self.searchTopButton.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
}


extension ChallengesFeedViewController {
    func showActionSheet() {
        
        let optionMenu =  UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        optionMenu.view.tintColor = .red
        let appGalleryAction = UIAlertAction(title: "Gallery", style: .default, handler:
                                                {
                                                    
                                                    (alert: UIAlertAction!) -> Void in
                                                    self.openGallery()//(obj: obj)
                                                })
        
        let libraryAction = UIAlertAction(title: "Library", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                                /*if self.videoUploadStatus == 0 {
                                                    AlertController.alert(message: self.video_upload_access_error_message)
                                                }else {
                                                    if self.videoCount == 20 {
                                                        AlertController.alert(message: self.dynamic_error_message)
                                                    }else {
                                                        
                                                    }
                                                }*/
            self.openLibrary()
                                            })
        
        let shootAction = UIAlertAction(title: "Shoot", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                /*if self.videoUploadStatus == 0 {
                                                    AlertController.alert(message: self.video_upload_access_error_message)
                                                }else {
                                                    if self.videoCount == 20 {
                                                        AlertController.alert(message: self.dynamic_error_message)
                                                    }else {
                                                        self.openShoot()//(obj:obj)
                                                    }
                                                }*/
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
        
        if let vc  = UIStoryboard.challenge.get(ChallengeShootViewController.self){
            //vc.challengeId = obj.challenge_id
            //vc.challengeName = obj.title
            //vc.homeObj = obj
            vc.isForChallange = true
            vc.challangeType = self.challengeType
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openGallery(){
        if let vc = UIStoryboard.challenge.get(GalleryViewController.self){
            //vc.challengeObj = obj
            //vc.isFromTabBar = true
            //vc.challengeObj = obj
            vc.challangeType = self.challengeType
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

extension ChallengesFeedViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        let videoURL = info[.mediaURL] as? NSURL
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
            }else {
                if let vc = UIStoryboard.challenge.get(VideoFilterViewController.self){
                    vc.videoURL = url as URL
                    vc.thumbnailImage = self.getThumbnailImage(forUrl: url as URL)!
                    vc.isFromLibrary = true
                    vc.isForChallange = true
                    vc.challangeType = self.challengeType
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}


//MARK: api for challenges list
extension ChallengesFeedViewController{
    
    func uniqueElementsFrom(array: [String]) -> [String] {
        //Create an empty Set to track unique items
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0) else {
                //If the set already contains this object, return false
                //so we skip it
                return false
            }
            //Add this item to the set since it will now be in the array
            set.insert($0)
            //Return true so that filtered array will contain this item.
            return true
        }
        return result
    }
    
    func typePriority(_ type: String) -> Int {
        switch type {
            case "daily":
                return 1
            case "weekly":
                return 2
            case "monthly":
                return 3
            default:
                return 0
        }
    }

    
    func getHomeVideosList() {
        ProgressHud.showActivityLoaderWithTxt(text: "Fetching latest challenges...")
        
        APIService
            .singelton
            .getActiveChalengesHome()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.challengesModelArray.removeAll()
                            
                            Logs.show(message: "\(val.first?.type ?? "")")
                            self.challengesModelArray = val.sorted(by: { c1, c2 in
                                (self.typePriority(c1.type), c1.votingCloseAt) < (self.typePriority(c2.type), c2.votingCloseAt)
                            })

                            //self.ChallengeArray = val.compactMap({ "\($0.type ?? "") - \($0.name ?? "")" })
                            self.ChallengeArray = challengesModelArray.compactMap({ $0.type })
                            self.ChallengeNameArray = challengesModelArray.compactMap({ $0.name })
                            //self.ChallengeArray = self.uniqueElementsFrom(array:self.ChallengeArray)
                            delay(delay: 0) {
                                self.timer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChallengesFeedViewController.setTimer), userInfo: nil, repeats: true)
                            }
                            self.tableView.setContentOffset(.zero, animated: true)
                            self.tableView.reloadData()
                            self.stopRefresher()
                            ProgressHud.hideActivityLoader()
                        } else {
                            AppFunctions.showSnackBar(str: "No Challenges Running")
                            self.stopRefresher()
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
    
    func getBanners() {
        APIService
            .singelton
            .getBanners()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            self.BannerArray = val
                            self.pageControl.numberOfPages = val.count
                            self.collectionView.reloadData()
                        } else {
                            Logs.show(message: "Val 0")
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func callApiForChallengeList() {
        var params = [String: Any]()
        params["limit"] = "10"
        params["offset"] = offset
        
        params["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        params["device_type"] = "2"
        params["fcm_token"] = AuthManager.shared.fcmToken ?? "dsdfdfdf"
        
        print("params",params)
        
        WebServices.getChallengesList(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let array = response.array {
                        
                        if self.offset == 0 {
                            self.listArray = array
                            self.tableView.reloadData()
                        }else {
                            if array.count == 0 {
                                self.isMoreData = false
                            }else {
                                self.listArray.append(contentsOf: array)
                                self.tableView.reloadData()
                            }
                        }
                        
                        delay(delay: 0) {
                            self.timer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChallengesFeedViewController.setTimer), userInfo: nil, repeats: true)
                        }
                    }
                    
                    if self.listArray.count == 0 {
                        noDataFound(message: "No Challenge Found", tableView: self.tableView,tag: 101)
                        self.tableView.backgroundView?.isHidden = false
                    }else {
                        if self.tableView.backgroundView?.tag == 101 {
                            self.tableView.backgroundView?.isHidden = true
                        }
                    }
                    
                }
            }
        })
    }
    
    func participateChallenge(obj: HomeModel,obj2:[RewardsModel]){
        var param = [String:Any]()
        param["challenge_id"] = obj.challenge_id
        WebServices.participateToChallenge(params: param) { (response) in
            if response?.statusCode == 200 {
                //self.showActionSheet(obj: obj)
            }
        }
    }
    
    func searchChallenge() {
        
        ProgressHud.showActivityLoaderWithTxt(text: "Fetching latest challenges...")
        
        APIService
            .singelton
            .getChalengeById(id: searchText)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            self.challengesModelArray.removeAll()
                            self.ChallengeArray.removeAll()
                            //Logs.show(message: "\(val.first?.type ?? "")")
                            self.challengesModelArray.append(val)
                            //self.ChallengeArray = val.compactMap({ "\($0.type ?? "") - \($0.name ?? "")" })
                            self.ChallengeArray.append(val.type)
                            //self.ChallengeArray = self.uniqueElementsFrom(array:self.ChallengeArray)
                            delay(delay: 0) {
                                self.timer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChallengesFeedViewController.setTimer), userInfo: nil, repeats: true)
                            }
                            self.tableView.setContentOffset(.zero, animated: true)
                            self.tableView.reloadData()
                            ProgressHud.hideActivityLoader()
                        } else {
                            AppFunctions.showSnackBar(str: "No Challenges Running")
                            ProgressHud.hideActivityLoader()
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
        
        /*WebServices.searchChallenge(params: param) { (response) in
            if let arr = response?.array {
                self.listArray = arr
                if arr.count == 0 {
                    noDataFound(message: "No Challenge Found", tableView: self.tableView,tag: 102)
                    self.tableView.backgroundView?.isHidden = false
                }else {
                    self.timer.invalidate()
                    self.timerValue = 0
                    if self.tableView.backgroundView?.tag == 102 {
                        self.tableView.backgroundView?.isHidden = true
                    }
                    delay(delay: 0) {
                        self.timer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChallengesFeedViewController.setTimer), userInfo: nil, repeats: true)
                    }
                    
                }
                self.tableView.reloadData()
            }
        }*/
    }
    
    
    //pagination
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("velocity = \(velocity)")
        if scrollView == self.tableView {
            if (scrollView.frame.size.height + scrollView.contentOffset.y) >= scrollView.contentSize.height{
                /*if isMoreData, searchText == "" {
                    self.timer.invalidate()
                    self.offset = offset + 10
                    callApiForChallengeList()
                }*/
                
                
            }
        }
    }
    
    func callApiForSaveVideo(data:NSData, url : URL){
        var params = [String: Any]()
        params["is_save_to_gallery"] = 0
        self.file = AttachmentInfo(withData: data as Data, fileName: "video.mp4", apiName: "video_file")
        var videoData = self.file ?? AttachmentInfo()
        videoData.apiKey = Constants.kVideo_File
        WebServices.saveVideo(params: params, files: [videoData]) { (resposne) in
            
            if let obj = resposne?.object  {
                if let vc = UIStoryboard.challenge.get(ChallengePostViewController.self) {
                    vc.videoID = obj.video_id
                    vc.videoURL = url
                    vc.homeObj = self.listArray[self.selectedIndex]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func callApiForRemoveVideo(obj: HomeModel, index: Int) {
        var params = [String: Any]()
        params["video_id"] = obj.challenge_video[index].video_id
        params["challenge_id"] = obj.challenge_id
        
        WebServices.removeVideo(params: params, successCompletion: { (response) in
            if let response = response {
                if response.statusCode == 200 {
                    obj.challenge_video.remove(at: index)
                    let count = Int(obj.no_of_participants ?? "0")
                    obj.no_of_participants = "\((count ?? 0) - 1)"
                    obj.check_if_participated = "0"
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func callApiForLiveStatus() {
        
        WebServices.getAdminLiveStatus(params: [:], successCompletion: { (response) in
            if let obj = response?.object {
                self.liveView.isHidden = obj.is_admin_live == 0
                self.liveButton.isHidden = obj.is_admin_live == 0
                self.liveModel = obj
                if obj.is_admin_live == 1 {
                    self.token = obj.token ?? ""
                    self.encoded_token = obj.encoded_token ?? ""
                    self.collectionView.reloadData()
                    self.liveSetup()
                    self.pageControl.isHidden = false
                    DispatchQueue.main.async {
                        self.pageControl.currentPage = 0
                    }
                    self.pageControl.numberOfPages = self.liveModel.banner_image.count
                    
                }else {
                    self.token = ""
                    self.encoded_token = ""
                    self.pageControl.isHidden = false
                    DispatchQueue.main.async {
                        self.pageControl.currentPage = 0
                    }
                    self.pageControl.numberOfPages = self.liveModel.banner_image.count
                    
                }
                if self.liveModel.banner_image.count > 0 {
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .left, animated: false)
                }
            }
            
        })
    }
    
    func getCountApi(){
        WebServices.getCounts { (response) in
            if let obj = response?.object {
                self.videoCount = obj.video_count ?? 0
                self.dynamic_error_message = obj.dynamic_error_message ?? ""
                self.videoUploadStatus = obj.check_video_upload_access ?? 0
                self.video_upload_access_error_message = obj.video_upload_access_error_message ?? ""
            }
        }
    }
    
}
extension ChallengesFeedViewController {
    
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


extension ChallengesFeedViewController: CustomSelectionDelegate {
    func agreeTermsAndConditions(status: Bool, obj: HomeModel) {
        if status {
            //self.showActionSheet(obj: obj)
        }
    }
    
    func clickedTermsAndConditions( obj: HomeModel) {
        if let vc = UIStoryboard.auth.get(StaticContentViewController.self){
            vc.isFromSetting = true
            vc.backCompletion = { obj in
                if let vc = UIStoryboard.challenge.get(ParticipatePopupViewController.self){
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
    
    
}
