//
//  BankdetailTVCell.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/12/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import UIKit

class BankdetailTVCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var valueTF: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
