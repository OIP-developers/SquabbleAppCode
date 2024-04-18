//
//  CropImageViewController.swift
//  FutureNow
//
//  Created by Sunil Joshi on 18/01/20.
//  Copyright © 2020 quytech-unity. All rights reserved.
//

import UIKit

protocol CropDelegate {
    func croppedImage(image: UIImage)
}

class CropImageViewController: UIViewController,CropPickerViewDelegate {
    
    @IBOutlet weak var cropPickerView: CropPickerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    var profileImage = UIImage()
    var delegate: CropDelegate?
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cropPickerView.image = profileImage
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func cropImage(){
        self.cropPickerView.crop { (error, image) in
            if let error = (error as NSError?) {
                let alertController = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if let img = image {
                self.profileImage = img
                self.delegate?.croppedImage(image: self.profileImage)
                self.navigationController?.popViewController(animated: false)
            }
            
        }
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnActn(_ sender: Any) {
        cropImage()
        
    }
    
    func cropPickerView(_ cropPickerView: CropPickerView, image: UIImage) {
    }
    
    func cropPickerView(_ cropPickerView: CropPickerView, error: Error) {
    }
    
}
