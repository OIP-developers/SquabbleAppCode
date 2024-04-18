//
//  SelectBankAccountViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import SafariServices
import Stripe

class SelectBankAccountViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var addTopButton: UIButton!
    @IBOutlet weak var addBottomButton: UIButton!
    
    
    var bankArray = [Bank]()
    var bankInfo = BankInfo()
    var transferType: TransferType = .bank
    var amount = ""
    let state: String  = AuthManager.shared.loggedInUser?.user_id ?? ""     // "5ece4797eaf5e" // generate a unique value for this
    let clientID: String = "ca_HoAwiRkdHe9lfkhbhj41H7toQRALBRcj" // the client ID found in your platform settings
    var last_four_digits = ""
    var bank_name = ""
    var bank_id = ""
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
      //  getBankList()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getBankAccount()
    }
    
    //MARK:-Initial Method
    func initialSetup(){
        addLabel.isHidden = bankArray.count == 0
        proceedButton.isHidden = bankArray.count == 0
        addTopButton.isHidden = bankArray.count != 0
        addBottomButton.isHidden = bankArray.count == 0
        
        addLabel.isHidden = true
        proceedButton.isHidden = false
        addTopButton.isHidden = true
        addBottomButton.isHidden = true
        //setupData()
    }
    
    func setupData(){
        let obj = Bank()
        obj.last4 = bankInfo.last4
        obj.bank_name = bankInfo.bank_name
        obj.user_bank_details_id = bank_id
        obj.brand = bankInfo.brand
        self.bankArray.append(obj)
        self.tableView.reloadData()
    }
    
    func openEditAccount(obj: Bank){
        if let vc = UIStoryboard.wallet.get(AddAccountViewController.self){
            vc.transferType = transferType
            vc.bank = obj
            vc.isFromEdit = true
            vc.addCompletion = { bankId in
                DispatchQueue.main.async {
                    self.getBankList()
                }
                delay(delay: 1) {
                    self.bankArray = self.bankArray.map({ (obj) -> Bank in
                        obj.status = obj.user_bank_details_id == bankId
                        return obj
                    })
                    self.tableView.reloadData()
                }
                
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- Target Method
    @objc func selectedButtonAction(_ sender: UIButton) {
        for (index, item) in bankArray.enumerated(){
            if index  == sender.tag {
                item.status = true //!(item.status ?? false)
            }else {
                item.status  = false
            }
        }
        tableView.reloadData()
    }
    
    //MARK:- UIButton Method
    @IBAction func proceedButtonAction(_ sender: UIButton){
        withdrawMoney()
    }
    
    @IBAction func addButtonAction(_ sender: UIButton){
        if let vc = UIStoryboard.wallet.get(AddAccountViewController.self){
            vc.transferType = transferType
            vc.addCompletion = { bankId in
                DispatchQueue.main.async {
                    self.getBankList()
                }
                delay(delay: 1) {
                    self.bankArray = self.bankArray.map({ (obj) -> Bank in
                        obj.status = obj.user_bank_details_id == bankId
                        return obj
                    })
                    self.tableView.reloadData()
                }
                
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
}

extension SelectBankAccountViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankNameTableViewCell", for: indexPath) as! BankNameTableViewCell
        let  obj = bankArray[indexPath.row]
        cell.radioButton.tag = indexPath.row
//        cell.accountNumberLabel.text = "xxxxxxxx\(String(obj.account_number?.suffix(4) ?? ""))"
//        cell.nameLabel.text = obj.bank_name
        cell.accountNumberLabel.text = "xxxxxxxx\(String(obj.last4?.suffix(4) ?? ""))"
        cell.nameLabel.text = bankInfo.brand.isEmpty ? obj.bank_name : obj.brand
       // cell.radioButton.addTarget(self, action: #selector(selectedButtonAction(_  :)), for: .touchUpInside)
       // cell.radioButton.isHidden = true
        cell.radioButton.isSelected = true
        cell.editButton.isHidden = true
       // cell.radioButton.isSelected = obj.status ?? false
        cell.editClicked = {
            self.openEditAccount(obj: obj)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
            self.deleteBankAcc(obj: self.bankArray[indexPath.row])
        }
        deleteAction.image = UIImage.init(named: "icn_cross")
        deleteAction.backgroundColor = RGBA(9, g: 9, b: 9, a: 1.0)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}

extension SelectBankAccountViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // the user may have closed the SFSafariViewController instance before a redirect
        // occurred. Sync with your backend to confirm the correct state
    }
    
    // This method handles opening native URLs (e.g., "your-app://")
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let stripeHandled = Stripe.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        } else {
            // This was not a stripe url – do whatever url handling your app
            // normally does, if any.
        }
        return false
    }
    
    // This method handles opening universal link URLs (e.g., "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = Stripe.handleURLCallback(with: url)
                if (stripeHandled) {
                    return true
                } else {
                    // This was not a stripe url – do whatever url handling your app
                    // normally does, if any.
                }
            }
        }
        return false
    }
    
    
}

extension SelectBankAccountViewController {
    func getBankList(){
        WebServices.getBankList { (response) in
            if let arr = response?.array {
                self.bankArray = arr
                self.initialSetup()
                if self.bankArray.count > 0 {
                    self.bankArray[0].status = true
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteBank(obj: Bank){
        var param = [String: Any]()
        param["user_bank_details_id"] = obj.user_bank_details_id
        
        WebServices.deleteBankAcc(params: param) { (response) in
            if response?.statusCode == 200 {
                self.navigationController?.popViewController(animated: true)
//                for (index,item) in self.bankArray.enumerated() {
//                    if item.user_bank_details_id == obj.user_bank_details_id {
//                        self.bankArray.remove(at: index)
//                        self.tableView.reloadData()
//                    }
//                }
            }
        }
    }
    
    func deleteBankAcc(obj: Bank){
        var param = [String: Any]()
        param["bank_id"] = obj.user_bank_details_id
        
        WebServices.deleteBankAcc(params: [:]) { (response) in
            if response?.statusCode == 200 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func withdrawMoney(){
        var param = [String: Any]()
        param["amount"] = amount
        param["user_bank_details_id"] = self.bankArray.filter{$0.status ?? false}.first?.user_bank_details_id
        
        WebServices.withdrawFromBank(params: param) { (response) in
            self.getWalletBalance()
            if let vc = UIStoryboard.wallet.get(SendingMoneyViewController.self){
                vc.transferType = self.transferType
                vc.amount = self.amount
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func getWalletBalance(){
        WebServices.getAccountBalance { (response) in
            if let object = response?.object {
                let auth = AuthManager.shared.loggedInUser
                auth?.user_balance = object.user_balance
                AuthManager.shared.loggedInUser = auth
            }
        }
    }
    
    func getBankAccount(){
        WebServices.getAccountDetail{ (response) in
            if let response = response {
                if response.statusCode == 200 {
                    if let obj = response.object {
                        self.bankInfo = obj
                        self.setupData()
                    }
                }
            }
        }
    }
}


class WalletBank: NSObject {
    var name: String?
    var status: Bool?
    var cvv: String?
    
    init(name: String, status: Bool) {
        self.name = name
        self.status = status
    }
}
