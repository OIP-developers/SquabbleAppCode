//
//  ChoosePaymentViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 05/05/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

enum PaymentType {
    case stripe
    case inApp
}

import UIKit
import Stripe

class ChoosePaymentViewController: UIViewController {
    
    @IBOutlet weak var stripeButton: UIButton!
    @IBOutlet weak var inAppButton: UIButton!
    
    var paymentType: PaymentType = .inApp
    var coinObj = CoinListModel()
    
    var transactionId = ""
    
    var clientSecret : String = ""
    private var paymentContext: STPPaymentContext!
    var customerContext = STPCustomerContext(keyProvider: MyAPIClient())
    var comeFirst = false

    // MARK: - UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePayemntButton()
        configureStripe()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseFailNotification(_:)),
                                               name: .IAPHelperPurchaseFailNotification,
                                               object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var cancelTapped = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let cancelTapped = UserDefaults.standard.value(forKey: "nnnnnnn") as? String {
                if (cancelTapped.count == 0 && self.comeFirst){
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.paymentContext.requestPayment()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Method
    fileprivate func updatePayemntButton(){
        stripeButton.isSelected = paymentType == .stripe
        inAppButton.isSelected = paymentType == .inApp
    }
    
    @objc func handlePurchaseFailNotification(_ notification: Notification){
        ProgressHud.hideActivityLoader()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        if let identifier = notification.object as? String {
            ProgressHud.hideActivityLoader()
            delay(delay: 0.1) {
                self.addMoneyToWallet(transactionId: identifier)
            }
        }
    }

    // MARK: - UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func proceedButtonAction(_ sender: UIButton){
        if paymentType == .inApp {
            if IAPHelper.canMakePayments() {
                guard let product = self.coinObj.product else { return }
                ProgressHud.showActivityLoader()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    
                }
                SquabbleProducts.storeInstance().buyProduct(product, email: AuthManager.shared.loggedInUser?.email ?? "")
            }
        } else {
            getClientSecret()
        }
    }
   
    @IBAction func stripeButtonAction(_ sender: UIButton){
        paymentType = .stripe
        updatePayemntButton()
    }
    
    @IBAction func inappButtonAction(_ sender: UIButton){
        paymentType = .inApp
        updatePayemntButton()
    }

}


extension ChoosePaymentViewController {
    func addMoneyToWallet(transactionId: String){
        var param = [String: Any]()
        param["amount"] = self.coinObj.coins_count
        param["transaction_id"] =  transactionId
        param["payment_method"] =  self.paymentType == .stripe ? "2" : "1"
        
        WebServices.addMoneyToWallet(params: param, loader : true) { (response) in
            if let vc = UIStoryboard.wallet.get(SendingMoneyViewController.self) {
                vc.transferType = .wallet
                vc.amount = self.coinObj.coins_count
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


extension ChoosePaymentViewController: STPPaymentContextDelegate {
    
    func configureStripe() {
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        // self.paymentContext.paymentCurrency = "INR"
        self.paymentContext.paymentAmount = Int(self.coinObj.coins_count) ?? 0 // This is in cents, i.e. $50 USD
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        // ProgressHud.showActivityLoader()
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
        self.transactionId = "\(paymentResult.paymentMethod?.stripeId ?? "")"
        // Confirm the PaymentIntent
        STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { (status, paymentIntent, error) in
            switch status {
            case .succeeded:
                
                self.comeFirst = false
                self.configureStripe()
                self.addMoneyToWallet(transactionId: self.transactionId)
                
                break
                
            // Your backend asynchronously fulfills the customer's order, e.g. via webhook
            //  completion(.success, nil)
            case .failed:
                AlertController.alert(message: "Payment Cancelled")
                self.comeFirst = false
                self.configureStripe()
                break
            case .canceled:
                break
            @unknown default:
                break
            }
        }
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentOptionsViewController, didSelect paymentMethod: STPPaymentMethod) {
        let selectedPaymentMethod = paymentMethod
        Debug.log("selectedPaymentMethod\(selectedPaymentMethod)")
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentOptionsViewController, didFailToLoadWithError error: Error) {
        Debug.log("did fail to load paymentmethodsview\(error)")
        dismiss(animated: true)
    }
    
    
    // MARK: - STPPaymentContextDelegate
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        if let customerKeyError = error as? MyAPIClient.CustomerKeyError {
            switch customerKeyError {
            case .missingBaseURL:
                // Fail silently until base url string is set
                print("[ERROR]: Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
            case .invalidResponse:
                // Use customer key specific error message
                print("[ERROR]: Missing or malformed response when attempting to `MainAPIClient.shared.createCustomerKey`. Please check internet connection and backend response formatting.");
                
                AlertController.alert(message: "Could not retrive customer information.")
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            // Use generic error message
            print("[ERROR]: Unrecognized error while loading payment context: \(error)");
            
            AlertController.alert(message: "Could not retrive customer information.")
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith status: STPPaymentStatus,
                        error: Error?) {
        
        switch status {
        case .error:
            AlertController.alert(message: "Error")
        case .success:
            AlertController.alert(message: "Success")
        case .userCancellation:
            return // Do nothing
        }
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("called")
        print("context",paymentContext)
        
    }
    
    //confirm payment
    //not calling this delegate
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
        // Confirm the PaymentIntent
        STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
            switch status {
            case .succeeded:
                AlertController.alert(message: "Payment Succeeded.")
                break
            case .failed:
                AlertController.alert(message: "Payment Cancelled.")
                break
            case .canceled:
                break
            @unknown default:
                break
            }
        }
    }
    
    
    
    
    func  getClientSecret() {
        
        /*WebServices.getClientSecretKey(params: ["amount":self.coinObj.coins_count as Any]) { (response) in
            if let response = response {
                self.clientSecret = response.object?.clientSecret ?? ""
              //  self.paymentContext.requestPayment()
                self.paymentContext.presentPaymentOptionsViewController()
                UserDefaults.standard.set("", forKey: "nnnnnnn")
                self.comeFirst = true
            }
        }*/
    }
}
