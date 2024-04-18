//
//  NotificationHeaderTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 07/01/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit

class NotificationHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var allButton: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
