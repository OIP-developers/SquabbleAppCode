//
//  AddMoneySelectAccountViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
//import Braintree
import Stripe

/*class AddMoneySelectAccountViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var proceedButton: UIButton!
    
    var transferType: TransferType = .bank
    var bankArray = [WalletBank]()
    var amount = ""
    var transactionId = ""
    
    var braintreeClient: BTAPIClient?
    
    var ephemeralKey: String?
    var clientSecret : String = ""
    private var paymentContext: STPPaymentContext!
    var customerContext = STPCustomerContext(keyProvider: MyAPIClient())
    
    
    var comeFirst = false
    
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        braintreeClient = BTAPIClient(authorization: "sandbox_ktf52d7g_ssj95wd82p985bmz")!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional
        proceedButton.setTitle("Pay $\(amount)", for: .normal)
        self.configureStripe()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Target Method
    @objc func selectedButtonAction(_ sender: UIButton) {
        for (index, item) in bankArray.enumerated(){
            if index  == sender.tag {
                item.status = true //!(item.status ?? false)
            }else {
                item.status  = false
                item.cvv = ""
            }
        }
        tableView.reloadData()
    }
    
    //MARK:- UIButton Action Method
    @IBAction func proceedButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        let obj = bankArray.filter{($0.status ?? false)}.first
        if obj?.cvv  == nil || obj?.cvv?.isEmpty ?? false {
            AlertController.alert(message: "Please enter cvv.")
        }else {
            
        }
    }
    
    @IBAction func debitButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let request = BTPayPalRequest(amount: amount)
        request.currencyCode = "USD" // Optional; see BTPayPalRequest.h for more options
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                self.transactionId = "\(tokenizedPayPalAccount.nonce)"
                self.addMoneyToWallet()
            } else if let error = error {
                // Handle error here...
            } else {
                // Buyer canceled payment approval
                AlertController.alert(message: "Buyer canceled payment approval")
            }
        }
    }
    
    @IBAction func creditButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        getClientSecret()
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
}

extension AddMoneySelectAccountViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankNameTableViewCell", for: indexPath) as! BankNameTableViewCell
        let  obj = bankArray[indexPath.row]
        cell.cvvTextField.delegate = self
        cell.cvvTextField.tag = indexPath.row +  100
        cell.radioButton.tag = indexPath.row
        cell.radioButton.addTarget(self, action: #selector(selectedButtonAction(_  :)), for: .touchUpInside)
        cell.cvvHeightConstraint.constant = obj.status ?? false ? 30  :  0
        cell.radioButton.isSelected = obj.status ?? false
        cell.cvvTextField.text = obj.cvv
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension AddMoneySelectAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if str.length > 3 || string == " " {
            return false
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let obj = bankArray[textField.tag - 100]
        obj.cvv =  textField.text?.trimWhiteSpace
        tableView.reloadData()
    }
    
}


extension AddMoneySelectAccountViewController : BTAppSwitchDelegate, BTViewControllerPresentingDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - BTAppSwitchDelegate
    
    
    // Optional - display and hide loading indicator UI
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        showLoadingUI()
        
        // NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingUI), name: NSNotification.Name.UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        hideLoadingUI()
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    // MARK: - Private methods
    
    @objc func showLoadingUI() {
        // ...
    }
    
    @objc  func hideLoadingUI() {
        
    }
    
    
}

extension AddMoneySelectAccountViewController {
    func addMoneyToWallet(){
        var param = [String: Any]()
        param["amount"] = "\(amount)"
        param["transaction_id"] =  self.transactionId
        //  param["currency"] = "USD"
        
        WebServices.addMoneyToWallet(params: param) { (response) in
            if let vc = UIStoryboard.wallet.get(SendingMoneyViewController.self) {
                vc.transferType = self.transferType
                vc.amount = self.amount
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}



extension AddMoneySelectAccountViewController: STPPaymentContextDelegate {
    
    func configureStripe() {
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        // self.paymentContext.paymentCurrency = "INR"
        self.paymentContext.paymentAmount = Int(self.amount) ?? 0 // This is in cents, i.e. $50 USD
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
        self.transactionId = "\(paymentResult.paymentMethod?.stripeId ?? "")"
        // Confirm the PaymentIntent
        STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { (status, paymentIntent, error) in
            switch status {
            case .succeeded:
                // Alerts.shared.show(alert: .success, message: StaticStrings.SSPaymentSucceeded.localized, type: .success)
                //  self.apiForStoreWalletInfo(intentId:paymentIntent?.stripeId ?? "", type: "stripe")
                self.comeFirst = false
                self.configureStripe()
                self.addMoneyToWallet()
                // AlertController.alert(message: "Payment Succeeded")
                
                break
                
            // Your backend asynchronously fulfills the customer's order, e.g. via webhook
            //  completion(.success, nil)
            case .failed:
                AlertController.alert(message: "Payment Cancelled")
                self.comeFirst = false
                self.configureStripe()
                break
            //  completion(.error, error) // Report error
            case .canceled:
                break
            //  completion(.userCancellation, nil) // Customer cancelled
            @unknown default:
                break
            // completion(.error, nil)
            }
        }
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentOptionsViewController, didSelect paymentMethod: STPPaymentMethod) {
        let selectedPaymentMethod = paymentMethod
        print("selectedPaymentMethod",selectedPaymentMethod)
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentOptionsViewController, didFailToLoadWithError error: Error) {
        print("did fail to load paymentmethodsview",error)
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
        //  Alerts.shared.show(alert: .error, message: StaticStrings.SSError.localized, type: .error)
        case .success:
            AlertController.alert(message: "Success")
            
        //  Alerts.shared.show(alert: .success, message: StaticStrings.SSSuccess.localized, type: .success)
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
            // Your backend asynchronously fulfills the customer's order, e.g. via webhook
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
        
        WebServices.getClientSecretKey(params: ["amount":self.amount as Any]) { (response) in
            if let response = response {
                self.clientSecret = response.object?.clientSecret ?? ""
                self.paymentContext.presentPaymentOptionsViewController()
                UserDefaults.standard.set("", forKey: "nnnnnnn")
                self.comeFirst = true
            }
        }
    }
}
*/
