//
//  BadgeListViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 24/07/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class BadgeListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var badgeArr = [Badge]()
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        getBadgeList()
        badgeUpdate()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}

extension BadgeListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCollectionViewCell", for: indexPath) as! BadgeCollectionViewCell
        //let obj = badgeArr[indexPath.item]
        //cell.cellSetup(obj: obj)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionView.frame.width / 3 - 12, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.claimBadge(obj: badgeArr[indexPath.row])
    }
    
}

extension BadgeListViewController {
    func getBadgeList(){
        WebServices.getBadgeList { (response) in
            if let arr = response?.array {
                self.badgeArr = arr
                self.collectionView.reloadData()
            }
        }
    }
    func claimBadge(obj: Badge) {
        var param = [String: Any]()
        param["badge_id"] = obj.badge_id
        
        WebServices.clainBadge(params: param) { (response) in
            if response?.statusCode == 200 {
                AlertController.alert(message: "\(response?.message ?? "")")
            }
        }
    }
    
    func badgeUpdate() {
        WebServices.badgeUpdate(params: [:]) { (response) in
            
        }
    }
}



