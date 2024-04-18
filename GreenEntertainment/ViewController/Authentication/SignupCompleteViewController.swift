//
//  SignupCompleteViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 18/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import SimpleAnimation

class SignupCompleteViewController: UIViewController {
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var tickView: UIView!
    @IBOutlet weak var signupLabel: UILabel!
    
    
    var image = UIImage()
    
   //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func customSetup(){
        tickImage.isHidden = true
        self.signupLabel.isHidden = true
        tickView.popIn(fromScale: 0.3, duration: 1, delay: 0.2) { (status) in
            self.tickImage.popIn(fromScale: 0.8, duration: 1, delay: 0) { (status) in
                self.tickImage.isHidden = false
                delay(delay: 0.5) {
                    if let vc  = UIStoryboard.profile.get(EditProfileViewController.self){
                        vc.image = self.image
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            self.signupLabel.isHidden = false
        }
        
    }

}
