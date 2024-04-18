//
//  AddStripeAccountViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 13/04/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit
import WebKit

class AddStripeAccountViewController: UIViewController {
    @IBOutlet weak var webView:WKWebView!
    var isEdit:Bool!
    var amount : String = ""
    var bankAddcompletion: (() -> Void)? = nil
    
    var isProduction = false
    

    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:--Testing
          //let redirectURI = "https://quytech.net/green-entertainment-test/mobileapi/customer_detail#/"
        //let strUrl = "https://dashboard.stripe.com/express/oauth/authorize?state=\(AuthManager.shared.loggedInUser?.auth_token ?? "")" + "&response_type=code&client_id=\(Constants.stripe_Test_ClientId)" + "&scope=read_write&redirect_uri=\(redirectURI)"
        //MARK:--Live
        let redirectURI = isProduction ?  "https://quytech.net/green-entertainment/mobileapi/customer_detail#/" : "https://quytech.net/green-entertainment-test/mobileapi/customer_detail#/"
        let strUrl = "https://dashboard.stripe.com/express/oauth/authorize?state=\(AuthManager.shared.loggedInUser?.auth_token ?? "")" + "&response_type=code&client_id=\(isProduction ? Constants.stripe_Live_ClientId : Constants.stripe_Test_ClientId)" + "&scope=read_write&redirect_uri=\(redirectURI)"
        webView.navigationDelegate = self
        let urlRequest = URLRequest.init(url: URL.init(string: strUrl)!)
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
        ProgressHud.showActivityLoader()
        // Do any additional setup after loading the view.
    }
}

extension AddStripeAccountViewController {
    //MARK:- UIButton Action Method

    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddStripeAccountViewController:WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?

        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        print("decidePolicyFor - url: \(url)")
        
        //Uncomment below code if you want to open URL in safari
        /*
        if navigationAction.navigationType == .linkActivated, url.absoluteString.hasPrefix("https://developer.apple.com/") {
            action = .cancel  // Stop in WebView
            UIApplication.shared.open(url)
        }
        */
    }

    //Equivalent of webViewDidStartLoad:
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
    }

    //Equivalent of didFailLoadWithError:
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nserror = error as NSError
        if nserror.code != NSURLErrorCancelled {
            webView.loadHTMLString("Page Not Found", baseURL: URL(string: "https://developer.apple.com/"))
        }
    }

    //Equivalent of webViewDidFinishLoad:
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        ProgressHud.hideActivityLoader()
        let urlStr = webView.url?.description ?? ""
        print("=====CheckUrl==",urlStr)
        //MARK:--Live
//https://quytech.net/green-entertainment/success/payment
        //https://quytech.net/green-entertainment/failure/payment
        //MARK:--testing
        //https://quytech.net/green-entertainment-test/failure/payment
        if urlStr.contains(find: isProduction ? "https://quytech.net/green-entertainment/success/payment" : "https://quytech.net/green-entertainment-test/success/payment") {
            delay(delay: 0.8) {
                self.getBankAccount()
            }
        }else if  urlStr.contains(find: isProduction ? "https://quytech.net/green-entertainment/failure/payment" : "https://quytech.net/green-entertainment-test/failure/payment") {
            delay(delay: 1.0) {
                AlertController.alert(title: "", message: "Bank/Card not added.Please add again.", buttons: ["OK"]) { (alert, index) in
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: SendMoneyToBankViewController.self) {
                            self.navigationController?.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }else {
            //
             ProgressHud.showActivityLoader()
            if urlStr.contains(find: isProduction ? "https://quytech.net/green-entertainment/success/payment" : "https://quytech.net/green-entertainment-test/success/payment") {
                           delay(delay: 0.8) {
                               self.getBankAccount()
                    }
                }else{
                    ProgressHud.hideActivityLoader()
                    AlertController.alert(title: "", message: "Try Again.", buttons: ["OK"]) { (alert, index) in
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: SendMoneyToBankViewController.self) {
                                self.navigationController?.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
            }
            }
    }

}

extension AddStripeAccountViewController {
    func getBankAccount(){
        WebServices.getAccountDetail{ (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let obj = response.object {
                        if obj.brand.isEmpty {
                            AlertController.alert(title: "", message: "Bank added successfully.", buttons: ["OK"]) { (alert, index) in

                                self.navigationController?.popViewController(animated: false)
                                self.bankAddcompletion?()
                              
                            }
                        }else {
                            AlertController.alert(title: "", message: "Card added successfully.", buttons: ["OK"]) { (alert, index) in
//                                for controller in self.navigationController!.viewControllers as Array {
//                                    if controller.isKind(of: SendMoneyToBankViewController.self) {
//                                        self.navigationController?.popToViewController(controller, animated: true)
//                                        break
//                                    }
//                                }
//
                                self.navigationController?.popViewController(animated: false)
                                self.bankAddcompletion?()
                            }
                        }
                    }
                }
            }
        }
    }
}
