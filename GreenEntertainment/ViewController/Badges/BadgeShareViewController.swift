//
//  BadgeShareViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 24/07/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class BadgeShareViewController: UIViewController {
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var badgeDescriptionLabel: UILabel!
    
    var badgeName: String?
    var imageName: String?
    
    //MARK: - UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Helper Method
    func initialSetup(){
        badgeLabel.text = badgeName
        if let url = URL(string: imageName ?? "") {
            badgeImageView.kf.setImage(with: url, placeholder: UIImage(named: "ic_user_placeholder"))
        }
    }
    
    func sharePost(text: String, image: UIImage) {
        let shareAll = [text , image] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
        ]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: - UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton){
        if let url = URL(string: imageName ?? "") {
            let data = try? Data(contentsOf: url)
            if let imageData = data {
                if  let image = UIImage(data: imageData) {
                    sharePost(text: badgeName ?? "", image: image)
                }
            }
        }else {
            sharePost(text: badgeName ?? "", image: UIImage())
        }
    }
}
