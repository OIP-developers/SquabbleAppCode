//
//  FilterVideoCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 11/09/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class FilterVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var commonImageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    override  func awakeFromNib() {
        //commonImageView.transform = commonImageView.transform.rotated(by: .pi)
        self.filterNameLabel.aroundShadow(.black)

    }
    
}


