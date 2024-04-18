//
//  SubscriptionVC.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import UIKit
import Stripe

class SubscriptionVC: UIViewController {

    @IBOutlet weak var subsTV: UITableView!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var subsList = [SubscriptionModel]()
    var subsId = ""
    var paymentIntentId = ""
    
    var clientSecret : String = ""
    var paymentContext: STPPaymentContext? {
        didSet {
            print("PaymentContext was set")
        }
    }
    var customerContext = STPCustomerContext(keyProvider: MyAPIClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        getSubscription()
        configureStripe()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseFailNotification(_:)),
                                               name: .IAPHelperPurchaseFailNotification,
                                               object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: OBJC Methods
    
    @objc func handlePurchaseFailNotification(_ notification: Notification){
        ProgressHud.hideActivityLoader()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        if let identifier = notification.object as? String {
            ProgressHud.hideActivityLoader()
            delay(delay: 0.1) {
                Logs.show(message: "HANDLE PURCHASE")
                //self.addMoneyToWallet(transactionId: identifier)
            }
        }
    }
    
    //MARK: OTHER METHODS
    
    func registerCells() {
        
        subsTV.tableFooterView = UIView()
        subsTV.separatorStyle = .none
        subsTV.delegate = self
        subsTV.dataSource = self
        subsTV.register(UINib(nibName: "SubscriptionTVCell", bundle: nil), forCellReuseIdentifier: "SubscriptionTVCell")
    }
    
    func showAlert(subsModel: SubscriptionModel) {
        DispatchQueue.main.async(execute: {
            self.view.endEditing(true)
            let alert = UIAlertController.init(title: "", message: "You are going to avail \(subsModel.title ?? "") Subscription Plan.", preferredStyle: .alert)
            
            let acceptButton = UIAlertAction(title: "Avail", style: .default, handler: { (action: UIAlertAction) in
                self.applySubscription(subsId: subsModel.id)
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
                self.dismiss(animated: true)
            })
            
            alert.addAction(acceptButton)
            alert.addAction(cancelButton)
            
            
            self.present(alert, animated: true, completion: nil)
            
        })
    }
    
    //MARK: API METHODS
    
    func getSubscription() {
        
        APIService
            .singelton
            .getSubscriptions()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            Logs.show(message: "\(val.count)")
                            Logs.show(message: "Saved Vids : \(val)")
                            self.subsList = val
                            self.subsTV.reloadData()
                            //self.navigateToVideoPlayerVC()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "No Subscriptions available")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func applySubscription(subsId: String) {
        
        let pram : [String : Any] = ["subscriptionId": subsId]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .applyForSubs(Pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            self.paymentIntentId = val.id
                            self.clientSecret = val.client_secret
                            self.paymentContext?.requestPayment()//.presentPaymentOptionsViewController()
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in Subscriptions")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func confirmSubscription(paymentID: String) {
        
        APIService
            .singelton
            .confirmSubs(id: paymentID)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            AppFunctions.showSnackBar(str: "Subscriptions Availed")
                            self.navigationController?.popBack(3)
                            
                        } else {
                            //self.noVideoView.isHidden = false
                            AppFunctions.showSnackBar(str: "Error in Subscriptions")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }

}
//MARK: TableView Extention
extension SubscriptionVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SubscriptionTVCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionTVCell", for: indexPath) as! SubscriptionTVCell
        
        cell.priceLbl.text = "$\(subsList[indexPath.row].price ?? 0)"
        cell.tokenCount.text = "\(subsList[indexPath.row].offerdCoin ?? 0)"
        cell.expireTimeLbl.text = "\(subsList[indexPath.row].expireYears ?? 0) Year(s)"
        cell.subsType.text = subsList[indexPath.row].title

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(subsModel: subsList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


//MARK: STRIPE Extention
extension SubscriptionVC: STPPaymentContextDelegate {
    
    func configureStripe() {
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext?.delegate = self
        self.paymentContext?.hostViewController = self
        self.paymentContext?.paymentCurrency = "USD"
        self.paymentContext?.paymentAmount = 10 // This is in cents, i.e. $50 USD
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        // ProgressHud.showActivityLoader()
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
        //self.transactionId = "\(paymentResult.paymentMethod?.stripeId ?? "")"
        // Confirm the PaymentIntent
        STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { (status, paymentIntent, error) in
            switch status {
                case .succeeded:
                    print("Payment succeeded")
                    //self.configureStripe()
                    self.confirmSubscription(paymentID: self.paymentIntentId)
                    //self.addMoneyToWallet(transactionId: self.transactionId)
                    
                    break
                    
                    // Your backend asynchronously fulfills the customer's order, e.g. via webhook
                    //  completion(.success, nil)
                case .failed:
                    print("Payment failed")
                    AlertController.alert(message: "Payment Cancelled")
                    //self.configureStripe()
                    break
                case .canceled:
                    print("Payment cancelled")
                    break
                @unknown default:
                    print("Unknown payment status")
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
        if self.paymentContext?.selectedPaymentOption != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                //self.paymentContext?.requestPayment()
            }
        }
        print("Payment context did change")
        
    }
    
    //confirm payment
    //not calling this delegate
    /*func paymentContext(_ paymentContext: STPPaymentContext,
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
    }*/
    
    
    
    
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
