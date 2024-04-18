//
//  ViewExtension.swift
//  Centareum
//
//  Created by apple on 19/11/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import UIKit

extension UIView {
    
    func showShadowLayout()  {
        
        layer.shadowRadius = 8
        layer.masksToBounds = true
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: -1, height: 1)
     //   layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        //layer.rasterizationScale = UIScreen.main.scale

    }

}

extension UITableView {
    
    func addPlaceHolderViewWithErrorText(placeholderText:String,isShow:Bool) {
        
        let myView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        let myLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        myLabel.textColor = UIColor.black
        myLabel.font = UIFont.init(name: "GEInspira-Bold", size: 17)
        myLabel.numberOfLines = 0
        myLabel.textAlignment = .center
        myLabel.text = placeholderText
        myView.addSubview(myLabel)
        
        if isShow {
            self.backgroundView = myView
        }else{
            let myTempView = UIView()
            self.backgroundView = myTempView
        }
    }
    
}

extension UICollectionView {
    
    func addPlaceHolderViewWithErrorText(placeholderText:String,isShow:Bool,fromCenterToAbove:CGFloat) {
        
        let myView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        let myLabel = UILabel.init(frame: CGRect.init(x: 0, y: (0-fromCenterToAbove), width: self.frame.size.width, height: self.frame.size.height))
        myLabel.textColor = UIColor.black
        myLabel.font = UIFont.init(name: "GEInspira-Bold", size: 17)
        myLabel.numberOfLines = 0
        myLabel.textAlignment = .center
        myLabel.text = placeholderText
        myView.addSubview(myLabel)
        
        if isShow {
            self.backgroundView = myView
        }else{
            let myTempView = UIView()
            self.backgroundView = myTempView
        }
    }
    
}
