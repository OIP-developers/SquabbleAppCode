//
//  GalleryCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 11/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var challenegNameLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    
    var removeClicked:(() -> Void)? = nil
    var addClicked:(() -> Void)? = nil

    
    

    override func awakeFromNib() {
    super.awakeFromNib()
//       let layer2 = gradientLayer(bottomView.bounds)
//      bottomView.layer.insertSublayer(layer2, at: 0)
        
    }
    
    @IBAction func removeButtonAction(_ sender: UIButton){
        self.removeClicked?()
    }
   
    @IBAction func addButtonAction(_ sender: Any) {
        self.addClicked?()
    }
    
    
}
