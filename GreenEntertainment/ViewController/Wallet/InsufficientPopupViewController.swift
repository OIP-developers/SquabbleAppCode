//
//  InsufficientPopupViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class InsufficientPopupViewController: UIViewController {
    
    @IBOutlet weak var amountlabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var completion:  (()  -> Void)? = nil
    var isFromGift = false
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromGift {
            if let amount = AuthManager.shared.loggedInUser?.gift_balance {
                self.amountlabel.attributedText =  getTextWithGiftImage(startString: "", price: "", lastString: " \(Int(amount))", imageAddtionalSize: 2, imageName: "ic_giftbox")
            }
        }else {
            if let amount = AuthManager.shared.loggedInUser?.user_balance {
                self.amountlabel.attributedText =  getTextWithTokenImage(startString: " ", price: " \(Int(amount))", imageAddtionalSize: -25)
            }
        }
        addButton.setTitle(isFromGift ? "Add Gifts To Wallet" : "Add Tokens To Wallet", for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UIButton Method
    @IBAction func backButtonAction(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
        completion?()
    }
    
}
