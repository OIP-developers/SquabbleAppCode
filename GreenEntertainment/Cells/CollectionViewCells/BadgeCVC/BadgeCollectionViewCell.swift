//
//  BadgeCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 24/07/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class BadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    func cellSetup(obj: Badge){
        badgeImageView.kf.indicator?.startAnimatingView()
        badgeLabel.text = obj.title
        if let url = URL(string: obj.badge_thumbnail ?? "") {
            badgeImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
            badgeImageView.kf.indicator?.stopAnimatingView()
        }
    }
    
}
