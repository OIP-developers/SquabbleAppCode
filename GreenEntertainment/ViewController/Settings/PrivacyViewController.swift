//
//  PrivacyViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 26/10/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPrivacySetting()
        user.is_private = AuthManager.shared.loggedInUser?.is_private
        // Do any additional setup after loading the view.
    }
    
    func updatePrivacyStatus(index: Int){
        if index == 0 {
            user.is_private = "2"
        }else {
            user.is_private = "1"
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton){
        updateAccountSetting()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
}


extension PrivacyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyTableViewCell", for: indexPath) as! PrivacyTableViewCell
        cell.selectedIndexCompletion = {
            self.updatePrivacyStatus(index: indexPath.row)
        }
        
        if  indexPath.row == 0{
            cell.commonLabel.text = "Public"
            cell.commonButton.isSelected = user.is_private != "1"
        }else {
            cell.commonLabel.text = "Private"
            cell.commonButton.isSelected = user.is_private == "1"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updatePrivacyStatus(index: indexPath.row)
    }
    
}


extension PrivacyViewController {
    
    func getPrivacySetting(){
        var param = [String: Any]()
        param["receive_notification"] = user.is_private
        
        //  1=>private,2=>public
        
        WebServices.getAccountSetting(params: [:]) { (response) in
            if response?.statusCode == 200 {
                if let obj = response?.object {
                    self.user.is_private = obj.setting
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func updateAccountSetting(){
        var param = [String: Any]()
        param["setting"] = user.is_private
        //  1=>private,2=>public
        
        WebServices.updateAccountSetting(params: param) { (response) in
            if response?.statusCode == 200 {
                AlertController.alert(title: "", message: "Updated successfully.", buttons: ["OK"]) { (alert, index) in
                    self.navigationController?.popViewController(animated: true)
                }
                self.tableView.reloadData()
            }
        }
    }
}
