//
//  WalkthroughViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import SwiftyGif

class WalkthroughViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: FXPageControl!
    @IBOutlet weak var backButton: UIButton!
    
    var imageArray = ["illustration_ondoarding2","illustration_onboarding1","","illustration_onboarding3",""]
    var headerArray = ["Shoot video","Participate in challenges","Swipe right to vote","Win Money",""]
    var subheaderArray = ["Record a video on Squabble or upload from your library.","Submit your video to one of our Daily Challenges.","Vote on your favorite videos and help them advance to the Weekly Challenge. ","Creators and Voters can win money on Squabble every day!",""]
    var isFromSetting = false
    var fromInitial = false
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func customSetup(){
        self.pageControl.numberOfPages = headerArray.count - 1
        self.pageControl.selectedDotColor = .white
        self.pageControl.dotColor = .darkGray
        self.pageControl.currentPage = 0
        self.pageControl.backgroundColor = .clear
        self.pageControl.dotSize = 12
        
        
        if fromInitial {
            self.backButton.isHidden = true
            if let val = KeychainWrapper.standard.bool(forKey: "App") {
                if !val {
                    updateAppCount()
                }
            }else {
                updateAppCount()
            }
        }
        
    }
    
    //MARK:- UIButton Method
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

extension WalkthroughViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFromSetting ? headerArray.count - 1 : headerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 2 {
            do {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalkthroughCollectionViewCell", for: indexPath) as! WalkthroughCollectionViewCell
                let gif = try UIImage(gifName: "vote.gif")
                cell.headrLabel.text = headerArray[indexPath.row]
                cell.subHeadrLabel.text = subheaderArray[indexPath.row]
                cell.voteImageView.startAnimatingGif()
                cell.voteImageView.setGifImage(gif, loopCount: -1)
                cell.commonImageView.isHidden = true
                cell.voteImageView.isHidden = false
                
                return cell
            }catch {
                print(error)
                return UICollectionViewCell()
            }
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalkthroughCollectionViewCell", for: indexPath) as! WalkthroughCollectionViewCell
            cell.headrLabel.text = headerArray[indexPath.row]
            cell.subHeadrLabel.text = subheaderArray[indexPath.row]
            cell.voteImageView.stopAnimatingGif()
            cell.commonImageView.image  =  UIImage.init(named: imageArray[indexPath.row])
            cell.commonImageView.isHidden = false
            cell.voteImageView.isHidden = true
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: Window_Width, height: Window_Height)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == imageArray.count - 1 ) { //it's your last cell
            //Load more data & reload your collection view
            if !isFromSetting {
                UserDefaults.standard.set(true, forKey: "guestUser")
//                if let vc = UIStoryboard.challenge.get(ChallengeListViewController.self) {
//                    let navigationController = UINavigationController(rootViewController: vc)
//                    navigationController.navigationBar.isHidden = true
//                    APPDELEGATE.navigationController = navigationController
//                    APPDELEGATE.window?.rootViewController = navigationController
//                }
                if let vc = UIStoryboard.tabbar.get(TabbarViewController.self) {
                    let navigationController = UINavigationController(rootViewController: vc)
                    navigationController.navigationBar.isHidden = true
                    APPDELEGATE.navigationController = navigationController
                    APPDELEGATE.window?.rootViewController = navigationController
                }
            }
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("Begin Dragging")
        if !isFromSetting {
            if pageControl.currentPage == 3 {
                if (scrollView.frame.size.width + scrollView.contentOffset.x) >= scrollView.contentSize.width{
                    
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.frame.size.width + scrollView.contentOffset.x) >= scrollView.contentSize.width{
            if !isFromSetting {
                
            }
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        
    }
}


extension WalkthroughViewController {
    func updateAppCount() {
        var param = [String : Any]()
        param["device_id"] = AuthManager.shared.deviceID ?? "sdfsdfdsf"
        WebServices.updateAppCount(params: param) { (response) in
            KeychainWrapper.standard.set(true, forKey: "App")
        }
    }
}
