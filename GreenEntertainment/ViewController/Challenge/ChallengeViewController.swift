//
//  ChallengeViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 10/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class ChallengeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = UIStoryboard.challenge.get(ChallengeShootViewController.self){
            navigationController?.pushViewController(vc, animated: false)
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
