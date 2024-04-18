//
//  VideosListVC.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on Wednesday14/09/2022.
//  Copyright © 2022 Quytech. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SimpleAnimation
import Firebase
import FirebaseAuth
import FirebaseAnalytics
import MediaPlayer
import ActiveLabel
import FTPopOverMenu_Swift

import RxSwift

import CodableFirebase
import Video
import VideoUI


class VideosListVC: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var videoCV: UICollectionView!
    @IBOutlet weak var filterView: UIStackView!
    @IBOutlet weak var generalBtn: UIButton!
    
    @IBOutlet weak var dropDownIV: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var noVideoView: UIView!
    
    //MARK: Actions
    
    @IBAction func backBtnPressed(_ sender: Any) {
        showTabBar()
    }
    
    //MARK: Properties
    
    var videoList = [VideosModel]()
    let dispose_Bag = DisposeBag()

    //private var videoList: [Video] = HardcodeDataProvider.getVideos() //= HardcodeDataProvider.getVideos()
    private lazy var store: VideoURLStore = {
        try! UserDefaultsVideoURLStore(userDefaults: UserDefaults(suiteName: "videoAppSuite"))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getVideoList()
        hideTabBar()
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func showTabBar() {
        tabBarController?.tabBar.alpha = 1
        tabBarController?.tabBar.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            //use if you want to darken the background
            //self.viewDim.alpha = 0.8
            //go back to original form
            self.tabBarController?.tabBar.isHidden = false
            self.tabBarController?.tabBar.transform = .identity
            self.tabBarController?.selectedIndex = 0
        })
    }

    
    func hideTabBar() {
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            //use if you wish to darken the background
            //self.viewDim.alpha = 0
            self.tabBarController?.tabBar.alpha = 0
            
        }) { (success) in
            self.tabBarController?.tabBar.isHidden = true

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
                                self.videoList = val
                                for v in val {
                                    Logs.show(message: "vID: \(v.id)")
                                }
                                self.navigateToVideoPlayerVC()
                            } else {
                                self.noVideoView.isHidden = false
                                AppFunctions.showSnackBar(str: "No Videos available")
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
        /*ProgressHud.showActivityLoader()
        let videoDB = Database.database().reference()
        let videoReference = videoDB.child("All_Videos")
        videoReference.getData(completion: { [weak self] err, snapshot in
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
                        self?.navigateToVideoPlayerVC()
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
                        self?.navigateToVideoPlayerVC()
                    } catch let error {
                        print(error)
                        AppFunctions.showSnackBar(str: "\(error.localizedDescription)")
                        ProgressHud.hideActivityLoader()
                    }
                }
            } else {
                self?.noVideoView.isHidden = false
                AppFunctions.showSnackBar(str: "No Videos available")
                ProgressHud.hideActivityLoader()
            }
        })*/
    }
    
    func navigateToVideoPlayerVC() {
        ProgressHud.hideActivityLoader()
        
      
        shuffled_indices = self.videoList.indices.shuffled()
        self.videoList = shuffled_indices.map { self.videoList[$0] }
      
        let remoteVideoLoader = HardcodeVideoLoader(videos: (self.videoList))
        let avVideoLoader = HLSVideoLoader(identifier: "cacheHLSVideoIdentifier", store: (self.store))
        
        let videoViewController = VideoUIComposer.videoComposedWith(videoloader: remoteVideoLoader, avVideoLoader: avVideoLoader, fromVC: "Feed", vidList: self.videoList, ip: IndexPath(row: -1, section: -1))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(videoViewController, animated: false)
    }

}
extension VideosListVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        showTabBar()
        return true
    }
}


/*extension VideosListVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeListCollectionViewCell", for: indexPath) as! ChallengeListCollectionViewCell
        
        let item = videoList[indexPath.row]
        
        cell.setPlayer(urlString: item["video_url"] as! String)
        //cell.showHidePopupContents(value: true)
        if let url = URL(string: item["video_url"] as! String) {
            cell.thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: Window_Width , height: self.videoCV.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let cell = cell as?
ChallengeListCollectionViewCell {

            //oldAndNewIndices.1 = indexPath.row
            //currentIndex = indexPath.row
            cell.replay()

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ChallengeListCollectionViewCell {
            cell.pause()
        }
    }
    
}

extension VideosListVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        showTabBar()
        return true
    }
}


public class SmoothCollectionViewLayout: UICollectionViewFlowLayout {
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        // Page height used for estimating and calculating paging.
        let pageHeight = UIScreen.main.bounds.size.height
 + self.minimumLineSpacing
        //Logs.show(message: "pageHeight : \(pageHeight)")
        // Make an estimation of the current page position.
        let approximatePage = collectionView.contentOffset.y/pageHeight
        
        // Determine the current page based on velocity.
        let currentPage = velocity.y == 0 ? round(approximatePage) : (velocity.y < 0.0 ? floor(approximatePage) : ceil(approximatePage))
        
        // Create custom flickVelocity.
        let flickVelocity = velocity.y * 0.3
        
        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
        
        let newVerticalOffset = ((currentPage + flickedPages) * pageHeight) - collectionView.contentInset.top
        
        return CGPoint(x: proposedContentOffset.x, y: newVerticalOffset)
        
    }
}
*/
