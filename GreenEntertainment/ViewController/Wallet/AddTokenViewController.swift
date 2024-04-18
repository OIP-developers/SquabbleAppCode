//
//  AddTokenViewController.swift
//  GreenEntertainment
//
//  Created by Prempriya on 12/04/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import UIKit
import StoreKit

class AddTokenViewController: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenPriceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var inAppProducts: [SKProduct]?
    var coinList = [CoinListModel]()
    var selectedIndex = 0
    var transferType: TransferType = .bank

    
    // MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callCoinListAPI()
//        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification(_:)),
//                                               name: .IAPHelperPurchaseNotification,
//                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseFailNotification(_:)),
                                               name: .IAPHelperPurchaseFailNotification,
                                               object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getWalletBalance()
    }
    
    @objc func handlePurchaseFailNotification(_ notification: Notification){
        ProgressHud.hideActivityLoader()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        if let identifier = notification.object as? String {
            print("identifier:-\(identifier)")
            ProgressHud.hideActivityLoader()
            delay(delay: 0.1) {
             //   self.addMoneyToWallet(transactionId: identifier)
            }
          //  self.apiForStoreWalletInfo(intentId:identifier, type: "in_app_purchase")
        }
    }
    
    // MARK:-  Helper Method
    fileprivate func setupHeaderData(){
        let obj = coinList[selectedIndex]
        tokenLabel.text = "\(obj.coins_count) Tokens"
        tokenPriceLabel.text = "$ \(obj.dollar_value)"
        
        for transactionPending in SKPaymentQueue.default().transactions {
                SKPaymentQueue.default().finishTransaction(transactionPending)
            }
    }
    
    func setupInAppPurchase() {
        var productIdentifiers: Set<String> = []
        for object in self.coinList {
            productIdentifiers.insert(object.apple_purchase_id)
        }
        print("START IN APP PRODUCT FETCHING")
        ProgressHud.showActivityLoader()
        SquabbleProducts.instance.initiateProducts(identifier: productIdentifiers)
        SquabbleProducts.storeInstance().requestProducts { (status, products) in
            self.inAppProducts = products
            for object in self.coinList {
                if let product = products?.filter({ return $0.productIdentifier == object.apple_purchase_id}).first {
                    object.product = product
                }
            }
            ProgressHud.hideActivityLoader()
            print("IN APP PRODUCT FETCHED")
        }
    }
    
    @IBAction func backbuttonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyButonAction(_ sender: UIButton){
        
        //if let vc = UIStoryboard.wallet.get(ChoosePaymentViewController.self) {
        if let vc = UIStoryboard.wallet.get(SubscriptionVC.self) {
            //vc.coinObj = self.coinList[selectedIndex]
            navigationController?.pushViewController(vc, animated: true)
        }
        
//        if IAPHelper.canMakePayments() {
//            guard let product = self.coinList[selectedIndex].product else { return }
//            ProgressHud.showActivityLoader()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//
//            }
//            SquabbleProducts.storeInstance().buyProduct(product, email: AuthManager.shared.loggedInUser?.email ?? "")
//        }
    }
}


extension AddTokenViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coinList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "TokenCollectionViewCell", for: indexPath) as! TokenCollectionViewCell
        let obj = coinList[indexPath.item]
        cell.contentView.borderColor = selectedIndex == indexPath.row ? .white : .clear
        cell.contentView.borderWidth = selectedIndex == indexPath.row ? 4.0 : 0.0
        cell.contentView.layer.cornerRadius = 19.0
        cell.tokenLabel.text = "\(obj.coins_count) Tokens"
        cell.tokenPriceLabel.text = "$ \(obj.dollar_value)"
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        setupHeaderData()
        self.collectionView.reloadData()
        for transaction in SKPaymentQueue.default().transactions {
               print(transaction)
               SKPaymentQueue.default().finishTransaction(transaction)
           }
//        AlertController.alert(title: "Purchase!!", message: "Are you sure you want to purchase tokens?", buttons: ["Yes","No"]) { (alert, index) in
//            if index == 0 {
//
//            }
//        }
        

        

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 115, height: 115)
    }
}


extension AddTokenViewController {
    func callCoinListAPI() {
        WebServices.getCoinList { (response) in
            if let dataArray = response?.array{
                self.coinList = dataArray
                
                if let products = self.inAppProducts {
                    for object in self.coinList {
                        if let product = products.filter({ return $0.productIdentifier == object.apple_purchase_id}).first {
                            object.product = product
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.setupInAppPurchase()
                    }
                }
                self.setupHeaderData()
                self.collectionView.reloadData()
            }
        }
    }
    
    func getWalletBalance(){
        WebServices.getAccountBalance { (response) in
            if let object = response?.object {
                let auth = AuthManager.shared.loggedInUser
                auth?.user_balance = object.user_balance
                AuthManager.shared.loggedInUser = auth
                let balance = Double(AuthManager.shared.loggedInUser?.user_balance ?? 0)
                if balance < 2 {
                    self.balanceLabel.attributedText =  getTextWithTokenImage(startString: "", price: " \(Int(balance)) Token", imageAddtionalSize: -25)
                }else {
                    self.balanceLabel.attributedText =  getTextWithTokenImage(startString: "", price: " \(Int(balance)) Tokens", imageAddtionalSize: -25)
                }
                
                //self.balanceLabel.text = "\(balance) \(balance > 1 ? "Tokens" : "Token")"
            }
        }
    }
    func addMoneyToWallet(transactionId: String){
        var param = [String: Any]()
        param["amount"] = self.coinList[self.selectedIndex].coins_count
        param["transaction_id"] =  transactionId
        
        WebServices.addMoneyToWallet(params: param, loader : true) { (response) in
            if let vc = UIStoryboard.wallet.get(SendingMoneyViewController.self) {
                vc.transferType = .wallet
                vc.amount = self.coinList[self.selectedIndex].coins_count
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
