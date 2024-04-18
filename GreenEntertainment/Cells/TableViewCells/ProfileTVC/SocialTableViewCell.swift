//
//  SocialTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 09/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class SocialTableViewCell: UITableViewCell {

    @IBOutlet weak var commonTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var commonImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
