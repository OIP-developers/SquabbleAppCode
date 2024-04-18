//
//  ChallengeFeedTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseAnalytics
import CodableFirebase
import Video

import RxSwift

class ChallengeFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var participateButton: UIButton!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeHeightConstraint: NSLayoutConstraint!
    
    var removeClicked:((IndexPath) -> Void)? = nil

    var challengeVideos = [RewardsModel]()
    var homeObj = HomeModel()
    var cellClicked: ((IndexPath, [VideosModel]) -> Void)? = nil
    
    var videoList = [VideosModel]()
    var dailyVids = [VideosModel]()
    var weeklyVids = [VideosModel]()
    var monthlyVids = [VideosModel]()
    
    var dispose_Bag = DisposeBag()

    //private var videoList: [Video] = HardcodeDataProvider.getVideos() //= HardcodeDataProvider.getVideos()
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()
    
    
//    var timer = Timer()
    var timer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //getVideoList()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        timer.invalidate()
    }
    
    func setupChallenge(arr : [RewardsModel], obj: HomeModel){
        self.challengeVideos = arr
        self.homeObj = obj
     //   self.handleTimer()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
                            //self.videoList = val
                            
//                            self.dailyVids = val.filter({$0.challenge.type == "daily"})
//                            self.weeklyVids = val.filter({$0.challenge.type == "weekly"})
//                            self.monthlyVids = val.filter({$0.challenge.type == "monthly"})
//
//                            Logs.show(message: " VIDEOSSSSSS:::  \(self.dailyVids) ,, \(self.weeklyVids) ,, \(self.monthlyVids)")
//
//
                            self.collectionView.reloadData()
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
    
   // func getVideoList() {
       // Logs.show(message: "Saved Vids :::: ")
        /*let videoDB = Database.database().reference()
        let videoReference = videoDB.child("All_Videos")
        videoReference.getData(completion: { [weak self]err, snapshot in
            if snapshot?.hasChildren() == true {
                if self?.videoList != nil {
                    self?.videoList.removeAll()
                }
                if let errorr = err {
                    Logs.show(message: "Saved Vids Error : \(errorr.localizedDescription)")
                    AppFunctions.showSnackBar(str: "\(errorr.localizedDescription)")
                    ProgressHud.hideActivityLoader()
                    return
                }
                guard let value = snapshot?.value else { return }
                
                if snapshot?.childrenCount == 1 {
                    do {
                        let video = try FirebaseDecoder().decode(Video.self, from: value)
                        Logs.show(message: "Saved Vids : \(video)")
                        self?.videoList.append(video)
                        //self?.navigateToVideoPlayerVC()
                    } catch let error {
                        print(error)
                        AppFunctions.showSnackBar(str: "\(error.localizedDescription)")
                        ProgressHud.hideActivityLoader()
                    }
                } else {
                    do {
                        let video = try FirebaseDecoder().decode([Video].self, from: value)
                        Logs.show(message: "Saved Vids : \(video)")
                        self?.videoList = video
                        //self?.navigateToVideoPlayerVC()
                    } catch let error {
                        print(error)
                        AppFunctions.showSnackBar(str: "\(error.localizedDescription)")
                        ProgressHud.hideActivityLoader()
                    }
                }
                self?.collectionView.reloadData()
            }
        })*/
   // }
    
}


extension ChallengeFeedTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.count //self.challengeVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeParticipantCollectionViewCell", for: indexPath) as! ChallengeParticipantCollectionViewCell
        /*let obj = challengeVideos[indexPath.row]
        cell.participantImageView.image = nil
        if let url = URL(string: obj.video_thumbnail_new ?? "") {
            cell.participantImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        cell.nameLabel.text = ""  // obj.is_sponsered == "0" ? obj.user_name : ""
        cell.removeClicked = {
            self.removeClicked?(indexPath)
        }
        
        if obj.is_posted == "1" {
            if self.homeObj.challenge_type == "1"{
                cell.removeButton.isHidden = AuthManager.shared.loggedInUser?.user_id != obj.user_id
            }else {
                cell.removeButton.isHidden = true
            }
        }else {
            cell.removeButton.isHidden = true
        }*/
        cell.removeButton.isHidden = true
        cell.nameLabel.text = videoList[indexPath.row].name
        if let url = URL(string: videoList[indexPath.row].thumbnail_url!) {
            cell.participantImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }

        delay(delay: 0.1) {
            let layer2 = self.gradientLayer(cell.bottomView.bounds)
            cell.bottomView.layer.insertSublayer(layer2, at: 0)
            cell.bottomView.alpha = 0.4
            cell.participantImageView.layer.cornerRadius = 8
            
            cell.setNeedsLayout()
            cell.setNeedsDisplay()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 75, height:  self.videoList.count > 0 ? 95 : 0)
        //return CGSize.init(width: 75, height: 95)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cellClicked?(indexPath,videoList)
        
    }
    
    func gradientLayer(_ frame: CGRect) -> CAGradientLayer {
        let layerGradient = CAGradientLayer()
        layerGradient.colors = blackGradientColors
        
        layerGradient.locations = [0.0, 1.0]
        layerGradient.frame = frame
        
        return layerGradient
    }
    
}


extension ChallengeFeedTableViewCell {
    
    func handleTimer() {
        self.timer?.invalidate()
        self.handleEventDateTime()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.handleEventDateTime()
        })
    }
    
    
    
    func handleEventDateTime() {
        let start_date = Date().getDate(timestamp: self.homeObj.start_timestamp ?? "") ?? Date()
        let end_date = Date().getDate(timestamp: self.homeObj.end_timestamp ?? "") ?? Date()
        print("title: \(self.homeObj.title ?? "")")
        print("start_date: \(start_date), timestamp:\(self.homeObj.start_timestamp ?? "")")
       // print("start_date toLocalTime: \(start_date.toLocalTime()), timestamp:\(self.homeObj.start_timestamp ?? "")")
        //print("start_date toGlobalTime: \(start_date.toGlobalTime()), timestamp:\(self.homeObj.start_timestamp ?? "")")
        
        print("end_date: \(end_date), timestamp:\(self.homeObj.end_timestamp ?? "")")
       // print("end_date toLocalTime: \(end_date.toLocalTime()), timestamp:\(self.homeObj.end_timestamp ?? "")")
       // print("end_date toGlobalTime: \(end_date.toGlobalTime()), timestamp:\(self.homeObj.end_timestamp ?? "")")
        

        self.homeObj.is_challenge_started = start_date.isGreaterThanDate(dateToCompare: Date())
        self.homeObj.is_challenge_ended = end_date.isGreaterThanDate(dateToCompare: Date())
        
        // date format
        let start_intervals: (days: Int, hours: Int, min: Int, sec: Int ) = start_date.getFormatedDateString()
        let end_intervals: (days: Int, hours: Int, min: Int, sec: Int ) = end_date.getFormatedDateString()

        // label set
        var initial_string = ""
        if !self.homeObj.is_challenge_started {
            initial_string = "Starts in "
        } else if self.homeObj.is_challenge_started && !self.homeObj.is_challenge_ended {
            initial_string = "Ends in "
        } else if self.homeObj.is_challenge_ended {
            
        }
        
        statusLabel.text = initial_string
        
        if !self.homeObj.is_challenge_started {
            if start_intervals.days > 0 {
                timeView.isHidden = true
                daysLeftLabel.isHidden = false
                daysLeftLabel.text = start_intervals.days > 1 ? "Starts In \(start_intervals.days) Days" : "Starts In \(start_intervals.days) Day"
                statusLabel.isHidden = true
            }else {
                daysLeftLabel.isHidden = true
                timeView.isHidden = false
                statusLabel.isHidden = false
            }
        } else {
           if end_intervals.days > 0 {
                timeView.isHidden = true
                 daysLeftLabel.isHidden = false
            statusLabel.isHidden = true
            daysLeftLabel.text = end_intervals.days > 1 ? "Ends In \(end_intervals.days) Days" :  "Ends In \(end_intervals.days) Day"
           }else {
            timeView.isHidden = false
            statusLabel.isHidden = false
            daysLeftLabel.isHidden = true
            }
        }
       // daysLeftLabel.text = "\(!homeObj.is_challenge_started ? start_intervals.days : end_intervals.days)"
        hourLabel.text = " \(!homeObj.is_challenge_started ? start_intervals.hours : end_intervals.hours) :"
        minLabel.text = "\(!homeObj.is_challenge_started ? start_intervals.min % 60 : end_intervals.min % 60) :"
        secLabel.text = " \(!homeObj.is_challenge_started ? ((start_intervals.sec % 3600) % 60) : ((end_intervals.sec % 3600) % 60))"
    
    }
}
