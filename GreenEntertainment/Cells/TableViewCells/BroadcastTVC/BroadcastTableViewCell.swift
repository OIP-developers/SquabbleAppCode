//
//  BroadcastTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 23/09/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class BroadcastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
