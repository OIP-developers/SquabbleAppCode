//
//  UIImageViewExtension.swift
//  WOWE
//
//  Created by QUYTECH_ankit_ios on 03/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import AVKit

let placeholderImage = UIImage(named: "placeholder")

extension UIImageView{
   
 static func getThumbnailImage(_ url :String?) -> UIImage? {
        guard let urlTemp = URL(string: (url ?? "")) else {
            return nil
        }
     
        let asset: AVAsset = AVAsset(url: urlTemp)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)

        } catch {
            return nil
        }
    }
    
    
func getThumbnailImage(_ url :String?, placeholder: UIImage? = placeholderImage) {
    var kf = self.kf
    kf.indicatorType = .activity
    kf.indicator?.startAnimatingView()
    guard let urlTemp = URL(string: (url ?? "")) else {
        self.image = placeholder ;
        return
    }
 
    let asset: AVAsset = AVAsset(url: urlTemp)
    let imageGenerator = AVAssetImageGenerator(asset: asset)

    do {
        let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
        kf.indicator?.stopAnimatingView()
        self.image =  UIImage(cgImage: thumbnailImage)

    } catch let error {
        print(error)
        self.image = placeholder
    }
}
    
   
    
}
