//
//  SearchViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 09/09/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Video

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!

    var ChallengesListArray = [ChallengesModel]()
    var userListArray = [UserAPIModel]()
    var videosListArray = [VideosModel]()
    var listArrayy = ["challenge","user","zzz"]
    var searchCompletion: ((String) -> Void)? = nil
    var searchText = ""
    
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()
    
    var workItemReference: DispatchWorkItem? = nil
    
    // MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchTextField.addTarget(self, action: #selector(textChange(_ :)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.searchTextField.text = searchText
        /*if !searchText.isEmpty {
            searchChallenge()
        }*/
    }
    
    @objc func textChange(_ textField: UITextField){
        self.searchText = textField.text ?? ""
        if textField.text == "" {
            self.countLabel.text = ""
        }
        workItemReference?.cancel()
        let searchWorkItem = DispatchWorkItem {
            self.searchChallenge()
        }
        workItemReference = searchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: searchWorkItem)
        
//        if textField.text == "" {
//            self.searchText = ""
//            delay(delay: 0.3) {
//                 self.searchChallenge()
//                self.listArray.removeAll()
//                self.countLabel.text = ""
//                self.tableView.reloadData()
//            }
//            delay(delay: 0.4) {
//                self.listArray.removeAll()
//                self.countLabel.text = ""
//                self.tableView.reloadData()
//            }
//        }else {
//            self.searchChallenge()
//        }
    }
    
    // MARK:- UIButton Action Method
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        self.searchCompletion?("")
        navigationController?.popViewController(animated: true)
    }
    
    func navigateToVideoPlayerVC(videoList: [VideosModel], ip: IndexPath) {
        ProgressHud.hideActivityLoader()
        
        let remoteVideoLoader = HardcodeVideoLoader(videos: videoList)
        let avVideoLoader = HLSVideoLoader(identifier: "cacheHLSVideoIdentifier", store: (self.store))
        
        
        let videoViewController = VideoUIComposer.videoComposedWith(videoloader: remoteVideoLoader, avVideoLoader: avVideoLoader, fromVC: "Search", vidList: videoList, ip: ip) // CHECK HERE
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(videoViewController, animated: false)
    }
    
}

extension SearchViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           var str:NSString = textField.text! as NSString
           str = str.replacingCharacters(in: range, with: string) as NSString
        self.searchText = "\(str)"
        if str == "" {
            //self.listArray.removeAll()
            self.tableView.reloadData()
                 }else {
        }
        
           return true
       }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if searchTextField.text?.count ?? 0 > 0 {
            searchText = textField.text ?? ""
            searchChallenge()
        }
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ChallengesListArray.count
        } else if section == 1 {
            return userListArray.count
        } else {
            return videosListArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let obj = listArray[indexPath.row]
        
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationChallengeTableViewCell", for: indexPath) as! NotificationChallengeTableViewCell
                cell.titleLabel.text = ChallengesListArray[indexPath.row].name
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell") as! FollowTableViewCell
                
                if let url = URL(string: userListArray[indexPath.row].profile_picture ?? "") {
                    cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
                }
                cell.nameLabel.text = userListArray[indexPath.row].first_name
                cell.followButton.setTitle("User", for: .normal)

                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell") as! FollowTableViewCell
                
                if let url = URL(string: videosListArray[indexPath.row].thumbnail_url ?? "") {
                    cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: ""))
                }
                cell.nameLabel.text = videosListArray[indexPath.row].name
                cell.followButton.setTitle("Video", for: .normal)


                return cell
                
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        switch indexPath.section {
            case 0:
                self.searchCompletion?(ChallengesListArray[indexPath.row].id ?? "")
                self.navigationController?.popViewController(animated: true)
            case 1:
                
                let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
                vc.selectedIndex = 4
                goneToUser = true
                userToGo = userListArray[indexPath.row].id
                self.navigationController?.pushViewController(vc, animated: true)
                
            default:
                let ip = IndexPath(row: indexPath.row, section: 0)
                navigateToVideoPlayerVC(videoList: videosListArray, ip: ip)
                
        }
        
        
        /*let obj = listArray[indexPath.row]
        if obj.tag == "user" {
            if let vc = UIStoryboard.profile.get(UserProfileViewController.self){
                vc.user.user_id = obj.user_id
                navigationController?.pushViewController(vc, animated: true)
            }
        }else if obj.tag == "challenge" {
            self.searchCompletion?(obj.title ?? "")
            self.navigationController?.popViewController(animated: true)
        }else {
            if let vc = UIStoryboard.challenge.get(VideoPlayViewController.self){
                let object = RewardsModel()
                
                object.video_id = obj.video_id
                object.video_path = obj.video_path
                object.video_thumbnail = obj.video_thumbnail
                object.is_posted = obj.is_posted
                object.is_following = obj.is_following
                object.views_count = obj.views_count
                object.votes_count = obj.votes_count
                object.is_voted = obj.is_voted
                object.user_id = obj.user_id
                object.user_name = obj.video_owner
                object.user_image = obj.user_image
                object.challenge_id = obj.challenge_id
                object.video_text = obj.video_text
                object.setting = obj.setting
                object.request_status = obj.request_status
                object.primary_key_follow_id = obj.primary_key_follow_id
                object.tagged_user = obj.tagged_user
                object.is_voted_two_times = obj.is_voted_two_times
                object.is_voted_prime = obj.is_voted_prime
                object.challenge = obj.challenge
            
                vc.challengesArr.append(object)
                navigationController?.pushViewController(vc, animated: true)
            }
        }*/
    }
    
}


extension SearchViewController {
    
    func searchChallenge() {
        APIService
            .singelton
            .searchInApp(searchStr: searchText )
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val != nil {
                            self.ChallengesListArray.removeAll()
                            self.videosListArray.removeAll()
                            self.userListArray.removeAll()
                            
                            if(val.challenges != nil) {
                                self.ChallengesListArray = val.challenges
                            }
                            if(val.videos != nil) {
                                self.videosListArray = val.videos
                            }
                            if(val.users != nil) {
                                self.userListArray = val.users
                            }
                            
                            //self.listArray = val
                            //self.ChallengesListArray = val
                            /*for challenges in val {
                                self.videosListArray.append(contentsOf: challenges.videos)
                                if (challenges.videos != nil) {
                                    for user in challenges.videos {
                                        self.userListArray.append(user.user)
                                    }
                                }
                            }*/
                            self.countLabel.text = "Total Results For \(self.searchText) : \(self.ChallengesListArray.count + self.videosListArray.count + self.userListArray.count)"
                            
                            if val.challenges.count == 0 && val.users.count == 0 && val.videos.count == 0 {
                                noDataFound(message: "No Data Found", tableView: self.tableView,tag: 102)
                                self.tableView.backgroundView?.isHidden = false
                            }else {
                                if self.tableView.backgroundView?.tag == 102 {
                                    self.tableView.backgroundView?.isHidden = true
                                }
                            }
                            
                            self.tableView.reloadData()
                        } else {
                            noDataFound(message: "No Data Found", tableView: self.tableView,tag: 102)
                            self.tableView.backgroundView?.isHidden = false
                            self.videosListArray.removeAll()
                            self.ChallengesListArray.removeAll()
                            self.userListArray.removeAll()
                            
                            self.tableView.reloadData()
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    /*func searchChallenge() {
           var param = [String: Any]()
           param["search_keyword"]  = searchText
           
           WebServices.globalSearch(params: param) { (response) in
               if let arr = response?.array {
                   self.listArray = arr
                    if self.listArray.count > 1 {
                         self.countLabel.text = "Total Results For \(self.searchText) : \(self.listArray.count)"
                    }else {
                         self.countLabel.text = "Total Result For \(self.searchText) : \(self.listArray.count)"
                    }
                   
                   if arr.count == 0 {
                       noDataFound(message: "No Data Found", tableView: self.tableView,tag: 102)
                       self.tableView.backgroundView?.isHidden = false
                   }else {
                       if self.tableView.backgroundView?.tag == 102 {
                           self.tableView.backgroundView?.isHidden = true
                       }
                   }
                   self.tableView.reloadData()
               }
          
           }
       }*/
}
