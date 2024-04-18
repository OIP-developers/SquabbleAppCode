//
//  UserSuggestionsViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/08/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift


class UserSuggestionsViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var headerLabel: UILabel!
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func customSetup(){
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 20, bottom: 10, right: 10)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if textView.text.trimWhiteSpace.isEmpty {
            AlertController.alert(message: "Please enter message.")
        }else {
            self.submitUserSuggestion()
        }
    }
    
}

extension UserSuggestionsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.textInputMode?.primaryLanguage == "emoji") || !((textView.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textView.text! as NSString
        str = str.replacingCharacters(in: range, with: text) as NSString
        
        if str.length > 256 {
            return false
        }
        
        return true
    }
}


extension UserSuggestionsViewController {
    func submitUserSuggestion(){
        var param = [String: Any]()
        param["message"] = textView.text.base64Encoded()
        
        WebServices.submitUserSuggestion(params: param) { (response) in
            if response?.statusCode == 200 {
                AlertController.alert(title: "", message: "\(response?.message ?? "")", buttons: ["OK"]) { (alert, index) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

