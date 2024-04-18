//
//  ChallengeParticipantCollectionViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class ChallengeParticipantCollectionViewCell: UICollectionViewCell {
     @IBOutlet weak var participantImageView: UIImageView!
     @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    
    var removeClicked:(() -> Void)? = nil
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
    }
    
    
    @IBAction func removeButtonAction(_ sender: UIButton){
           self.removeClicked?()
       }

}
