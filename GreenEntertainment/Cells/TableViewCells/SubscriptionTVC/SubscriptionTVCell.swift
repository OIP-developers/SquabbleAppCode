//
//  SubscriptionTVCell.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import UIKit

class SubscriptionTVCell: UITableViewCell {
    
    
    @IBOutlet weak var subsType: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var tokenCount: UILabel!
    @IBOutlet weak var expireTimeLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
