//
//  ChallengeParticipatePopupViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 08/04/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit

protocol CustomParticipateSelectionDelegate {
    func agreeTermsAndConditions(status: Bool, obj: RewardsModel)
    func clickedTermsAndConditions(obj: RewardsModel)
}


class ChallengeParticipatePopupViewController: UIViewController {
    
    @IBOutlet weak var termsAcceptButton: UIButton!
    @IBOutlet weak var showAgainButton: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    
    
    var isAgreeToTnC = false
    var isShowAgain = false

    var isFromSetting = false
    var termsAcceptedCompletion: ((Bool, HomeModel) -> Void)? = nil
    var termsClickedCompletion: (() -> Void)? = nil
    
    var delegate: CustomParticipateSelectionDelegate?
    var obj = RewardsModel()

    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributedTermsAndCondition()
//        if let termsStatus = UserDefaults.standard.value(forKey: "isAgreeToTnC") as? Bool, termsStatus {
//            self.isAgreeToTnC = termsStatus
//            self.termsAcceptButton.isSelected = self.isAgreeToTnC
//        }
        self.isAgreeToTnC = AuthManager.shared.loggedInUser?.isAgreeToTermsnC == 1
        self.termsAcceptButton.isSelected = self.isAgreeToTnC
        
        titleLabel.text = "Squabble Challenge rules:\n\nAny user may submit a video to a challenge and/or vote on the videos in a challenge. Users may vote one time per video between 9am-8pm est. and again from 8pm-9pm est. The video with the highest number of votes at the end of the challenge wins!"

        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view == self.backgroundView {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    //MARK:- UIButton Action Method

    @IBAction func showButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isShowAgain = !isShowAgain
//        UserDefaults.standard.set(isShowAgain, forKey: "isShowAgain")
//        UserDefaults.standard.synchronize()
        
    }
    
    @IBAction func agreeTermsAndConditionButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isAgreeToTnC = !isAgreeToTnC
//        UserDefaults.standard.set(isAgreeToTnC, forKey: "isAgreeToTnC")
//        UserDefaults.standard.synchronize()
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if !isAgreeToTnC {
            AlertController.alert(message: "Please accept terms and conditions.")
        }else {
            delay(delay: 0.3) {
                self.updateParticipateOption()
            }
            
           // self.termsAcceptedCompletion?(true)
            dismiss(animated: true, completion: nil)
        }
    }

}


extension ChallengeParticipatePopupViewController {
    fileprivate func setAttributedTermsAndCondition() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        self.termsLabel.addGestureRecognizer(tapGesture)
        let string = Constants.kChallengeTerms
        let termsString = Constants.kTermsAndCondition
        let attributedString = NSMutableAttributedString(string: string)
        let firstAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: Fonts.Rubik.regular.font(.large)]
        let secondAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: Fonts.Rubik.regular.font(.large)]
        attributedString.addAttributes(firstAttributes, range: NSRange(location: 0, length: string.count-1))
        
        let range = attributedString.mutableString.range(of: termsString)
        if (range.location != NSNotFound && range.location + range.length <= attributedString.length) {
            // It's safe to use range on str
            attributedString.addAttributes(secondAttributes, range: range)
        }
        
        DispatchQueue.main.async {
            self.termsLabel.attributedText = attributedString
        }
        
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        guard let range = self.termsLabel.text?.range(of: Constants.kTermsAndCondition)?.nsRange else {
            return
        }
        if tap.didTapAttributedTextInLabel(label: self.termsLabel, inRange: range) {
            // Substring tapped
            
          //  self.termsClickedCompletion?()
            self.dismiss(animated: true, completion: nil)
            self.delegate?.clickedTermsAndConditions(obj: self.obj)
            
        }
    }
}

extension ChallengeParticipatePopupViewController {
    func updateParticipateOption(){
        var param = [String: Any]()
        param["term_status"] = !isAgreeToTnC ? "0" : "1"
        param["dont_show"] =  !isShowAgain ? "0" : "1"
        
        WebServices.updateParticipateStatus(params: param, loader : true) { (response) in
            if let object = response?.object {
                let auth = AuthManager.shared.loggedInUser
                auth?.isShowAgain = object.isShowAgain
                auth?.isAgreeToTermsnC = object.isAgreeToTermsnC
                AuthManager.shared.loggedInUser = auth
                self.delegate?.agreeTermsAndConditions(status: self.isAgreeToTnC, obj: self.obj)
               // self.balanceLabel.text = String(format: "$ %.2f", balance)
            }
        }
    }
}
