//
//  IAPHandler.swift
//  GreenEntertainment
//
//  Created by Prempriya on 12/04/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import Foundation
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperPurchaseFailNotification = Notification.Name("IAPHelperPurchaseFailNotification")

    static let IAPHelperNoTransactionAvailaableNotification = Notification.Name("IAPHelperNoTransactionAvailaableNotification")
}

class IAPHelper: NSObject  {
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
 
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        for transaction in SKPaymentQueue.default().transactions {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
      //  SKPaymentQueue.default().add(self)
    }
    
    
    func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    func buyProduct(_ product: SKProduct, email: String) {
        for transaction in SKPaymentQueue.default().transactions {
            SKPaymentQueue.default().finishTransaction(transaction)
        
        }
        print("Buying \(product.productIdentifier)...")
        
        let payment = SKMutablePayment(product: product) //SKPayment(product: product)
        payment.applicationUsername = email
        SKPaymentQueue.default().remove(self)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
}

// MARK: - StoreKit API

extension IAPHelper {
    
    func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    func isProductPurchased() -> Bool {
        return purchasedProductIdentifiers.count > 0
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases(userName : String) {
       /* if true{
            let refreshRequest = SKReceiptRefreshRequest()
            refreshRequest.delegate = self
            refreshRequest.start()
        }
        else{
            SKPaymentQueue.default().add(self)*/
            SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername:userName)
        //}
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        print("Invalid product identifiers \(response.invalidProductIdentifiers)")

        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
    
}

// MARK: - SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
     
            for transaction in transactions {
                print("SKPayment Application username: " + (transaction.payment.applicationUsername ?? "nil"))
                switch (transaction.transactionState) {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    complete(transaction: transaction)
                   // SKPaymentQueue.default().finishTransaction(transaction)
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    print("Transactionn purchased.")

                    break
                case .failed:
                    fail(transaction: transaction)
                   // SKPaymentQueue.default().finishTransaction(transaction)
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    print("Transactionn failed.")

                    break
                case .restored:
                    restore(transaction: transaction)
                    //SKPaymentQueue.default().finishTransaction(transaction)
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    print("Transactionn restore.")
                    
                    break
                case .purchasing:
                    break
                case .deferred:
                    break
                @unknown default:
                    break
                }

            }
        }

    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}
extension IAPHelper {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        let transactions = queue.transactions
        if transactions.count > 0 {
            for transaction in transactions {
                print("Restore SKPayment Application username" + (transaction.payment.applicationUsername ?? "nil"))
                switch (transaction.transactionState) {
                case .purchased:
                    complete(transaction: transaction)
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    print("Transaction complete.")
                    break
                case .failed:
                    fail(transaction: transaction)
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    print("Transaction failed.")
                    break
                case .restored:
                    restore(transaction: transaction)
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    print("Transaction restore.")
                    break
                case .purchasing:
                    break
                case .deferred:
                    break
                @unknown default:
                    break
                }
            }
        } else {
             NotificationCenter.default.post(name: .IAPHelperNoTransactionAvailaableNotification, object: nil)   
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete... \(transaction.payment.productIdentifier)")
        savePurchaseLocaly(identifier: transaction.payment.productIdentifier, transactionId: transaction.transactionIdentifier ?? "")
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        savePurchaseLocaly(identifier: productIdentifier, transactionId: transaction.transactionIdentifier ?? "")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            AlertController.alert(message: localizedDescription)
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        NotificationCenter.default.post(name: .IAPHelperPurchaseFailNotification, object: nil)

    }
    
    private func savePurchaseLocaly(identifier: String?, transactionId: String) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: transactionId)
    }
}

