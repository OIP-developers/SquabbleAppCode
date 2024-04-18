//
//  AuthTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class AuthTableViewCell: UITableViewCell {

    @IBOutlet weak var commonTextField: SkyFloatingLabelTextField!

    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commonTextField.errorMessagePlacement = .bottom
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
