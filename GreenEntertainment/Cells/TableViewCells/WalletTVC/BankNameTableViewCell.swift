//
//  BankNameTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class BankNameTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var cvvHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!

    var editClicked: (() -> Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonAction(_ sender: UIButton){
        self.editClicked?()
    }

}
