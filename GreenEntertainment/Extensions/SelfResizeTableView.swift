//
//  SelfResizeTableView.swift
//  Spancro
//
//  Created by Quytech on 18/09/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import Foundation
import UIKit

class SelfSizedTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        print("height:::\(height)")
        return CGSize(width: contentSize.width, height: height)
    }
}


class SelfSizedCollectionView: UICollectionView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        if #available(iOS 13.0, *) {
          // Running iOS 11 OR NEWER
            let height = min(contentSize.height , maxHeight)
            return CGSize(width: contentSize.width, height: height)
        } else {
          // Earlier version of iOS
            let height = min(contentSize.height - 130 , maxHeight)
            return CGSize(width: contentSize.width, height: height)
        }
      
    }
}


