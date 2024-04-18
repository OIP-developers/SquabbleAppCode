//
//  ProfileBadgeTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 09/01/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit

class ProfileBadgeTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var badgeIV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
