//
//  MobileTableViewCell.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 09/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class MobileTableViewCell: UITableViewCell {

    @IBOutlet weak var mobileTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var codeButton: UIButton!
    
    var codeCompletion: (() -> Void)? = nil

    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func codeButtonAction(_ sender: UIButton){
        self.codeCompletion?()
    }

}
