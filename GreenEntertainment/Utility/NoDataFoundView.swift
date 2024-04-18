//
//  NoDataFoundView.swift
//  Molla Kuqe
//
//  Created by ETHANEMAC on 09/01/19.
//  Copyright © 2019 ETHANE TECHNOLOGIES PVT. LTD. All rights reserved.
//

import UIKit

protocol NoDataFoundViewDelegate: class {
    func didTapInfoButton()
}


class NoDataFoundView: UIView {

    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    weak var delegate: NoDataFoundViewDelegate?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "NoDataFoundView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}
