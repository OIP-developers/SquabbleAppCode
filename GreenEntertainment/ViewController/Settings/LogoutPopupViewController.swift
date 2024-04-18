//
//  LogoutPopupViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 29/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogoutPopupViewController: UIViewController {
    var signoutCompletion:((Bool) -> Void)? = nil
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UIButton Action Method
    @IBAction func yesButtonAction(_ sender: UIButton){
        //callLogout()
        try! Auth.auth().signOut()
        self.signoutCompletion?(true)
        UserDefaults.standard.set(false, forKey: "loggedInUser")

        let storyBoard: UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)

        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func noButtonAction(_ sender: UIButton){
        signoutCompletion?(false)
        dismiss(animated: false, completion: nil)
    }
    
    //MARK:- Web Api Method
    func callLogout(){
        WebServices.logout { (response) in
            if response?.statusCode == 200 {
                let user = AuthManager.shared.loggedInUser
                AuthManager.shared.loggedInUser = user
                self.dismiss(animated: false, completion: nil)
                self.signoutCompletion?(true)
            }
        }
    }
    
}
