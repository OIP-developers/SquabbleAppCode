//
//  PreviewVC.swift
//  GreenEntertainment
//
//  Created by Quytech on 09/11/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class PreviewVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!

    var previewImage = UIImage(named: "sizzle_card")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSetup()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func defaultSetup() {
        closeButton.layer.cornerRadius = closeButton.bounds.height / 2
        imageView.contentMode = .scaleAspectFit
        self.imageView.image = previewImage
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
