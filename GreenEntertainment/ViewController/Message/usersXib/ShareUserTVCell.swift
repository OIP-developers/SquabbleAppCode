//
//  ShareUserTVCell.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 15/12/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import UIKit

class ShareUserTVCell: UITableViewCell {

    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
