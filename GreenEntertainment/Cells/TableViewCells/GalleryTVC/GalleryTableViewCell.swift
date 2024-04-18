//
//  GalleryTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Video

class GalleryTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    var imageArr = ["galler","gallery-1","galler","gallery-1","galler","gallery-1","galler","gallery-1","galler","gallery-1","galler","gallery-1"]
    var cellClicked:((IndexPath) -> Void)? = nil
    var removeClicked:((IndexPath) -> Void)? = nil
    var addClicked:((IndexPath) -> Void)? = nil

    

    var postsArray = [RewardsModel]()
    //var postsVidArray = [[String:Any]]()
    var postsVidArray = [VideosModel]()

    var videoType : VideoType = .myPost
    var selectedRow = -1
    var isFromProfile = false
    
    var videoList = [VideosModel()]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate  = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func hideAddBtn(val: [VideosModel]) {
        videoList = val
        collectionView.reloadData()
    }
    
    func cellSetup(arr : [RewardsModel], type: VideoType, isFromProfile: Bool = false){
        self.postsArray = arr
        self.isFromProfile = isFromProfile
        self.collectionView.reloadData()
        self.videoType = type
        delay(delay: 0.01) {
            self.collectionView.setEmptyText(status: self.postsArray.count == 0)
           // self.collectionView.reloadData()
        }
    }
    func cellSetup2(arr : [VideosModel], type: VideoType, isFromProfile: Bool = false){
        self.postsVidArray = arr
        self.isFromProfile = isFromProfile
        self.collectionView.reloadData()
        self.videoType = type
        delay(delay: 0.01) {
            self.collectionView.setEmptyText(status: self.postsVidArray.count == 0)
            // self.collectionView.reloadData()
        }
    }
    func cellSetupForTrophy(arr : [RewardsModel], type: VideoType){
        self.postsArray = arr
        self.collectionView.reloadData()
        self.videoType = type
        delay(delay: 0.01) {
            self.collectionView.setEmptyText(status: self.postsArray.count == 0)
           // self.collectionView.reloadData()
        }
    }
}

extension GalleryTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsVidArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        let obj = postsVidArray[indexPath.row]
        if let url = URL(string: obj.thumbnail_url!) {
            cell.galleryImageView.kf.setImage(with: url, placeholder: UIImage(named: "sizzle_card"))
        }
        if userToGo.isEmpty {
            cell.removeButton.isHidden = false
            if (videoList[indexPath.row].challenges != nil) {
                if videoList[indexPath.row].challenges.count <= 0 {
                    cell.addButton.isHidden = false
                    cell.galleryImageView.borderColor = .white
                    cell.galleryImageView.borderWidth = 1.0
                } else {
                    cell.addButton.isHidden = true
                    cell.galleryImageView.borderColor = UIColor.red
                    cell.galleryImageView.borderWidth = 1.5
                }
            }
        } else {
            cell.removeButton.isHidden = true
            cell.addButton.isHidden = true
            cell.galleryImageView.borderColor = .white
            cell.galleryImageView.borderWidth = 1.0
        }
        
        
        
        
//        if self.videoType == .myPost,obj.is_posted == "1", obj.challenge.check_if_completed == 0  {
//            cell.galleryImageView.borderWidth = 1.0
//            cell.galleryImageView.borderColor = .red
//            cell.removeButton.isHidden = AuthManager.shared.loggedInUser?.user_id != obj.user_id
//        }else {
//            cell.galleryImageView.borderWidth = 0.0
//            cell.removeButton.isHidden = true
//        }
        
//        if obj.challenge.check_if_completed == 1 {
//            cell.removeButton.isHidden = true
//        }
        
//        if obj.challenge.check_if_completed == 0 {
//            if obj.challenge.challenge_type == "2" || obj.challenge.challenge_type == "3" {
//                cell.removeButton.isHidden = true
//            }
//        }
        
        cell.removeClicked = {
             self.removeClicked?(indexPath)
        }
        
        cell.addClicked = {
            self.addClicked?(indexPath)
        }
        
        
        cell.dateLabel.isHidden = self.videoType == .myPost
        cell.challenegNameLabel.isHidden = self.videoType == .myPost
        cell.challenegNameLabel.text = obj.name
        //cell.dateLabel.text = getReadableDateWithYear(timeStamp: "\(obj["created_At"] as! String)")
        delay(delay: 0.1) {
            let layer2 = self.gradientLayer(cell.bottomView.bounds)
            cell.bottomView.layer.insertSublayer(layer2, at: 0)
            cell.bottomView.alpha = 0.4
            cell.setNeedsLayout()
            cell.setNeedsDisplay()
        }
//        if isFromProfile, videoType == .myPost, obj.is_posted == "0" {
//            cell.addButton.isHidden = selectedRow != indexPath.row
//
//            cell.addButton.tag = indexPath.row  + 10000
//            let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(postToChallenge))
//            longPress.minimumPressDuration = 1
//            cell.contentView.addGestureRecognizer(longPress)
//            cell.addButton.addTarget(self, action: #selector(addToChallenge(_:)), for: .touchUpInside)
//        }

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionView.frame.width /  2 - 5, height: self.collectionView.frame.width /  2 + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cellClicked?(indexPath)
    }
    
   func gradientLayer(_ frame: CGRect) -> CAGradientLayer {
           let layerGradient = CAGradientLayer()
               layerGradient.colors = blackGradientColors

               layerGradient.locations = [0.0, 1.0]
               layerGradient.frame = frame
    
                   return layerGradient
          }
    
    @objc func postToChallenge(_ gestureRecogniser: UILongPressGestureRecognizer){
        if gestureRecogniser.state == .began {
            let location = gestureRecogniser.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: location)
          //  let cell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as! GalleryCollectionViewCell
            selectedRow = indexPath?.row as! Int
            

            
        }
        
        collectionView.reloadData()
        
        print("Press")
        
    }
    
    @objc func addToChallenge(_ sender: UIButton){
        let tag = sender.tag - 10000
        //self.addClicked?(selectedRow)
    }
}




