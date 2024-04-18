//
//  PrivacyTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prempriya on 26/10/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class PrivacyTableViewCell: UITableViewCell {
    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var commonLabel: UILabel!
    var selectedIndexCompletion: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func commonButtonAction(_ sender: UIButton){
        selectedIndexCompletion?()
    }

}
