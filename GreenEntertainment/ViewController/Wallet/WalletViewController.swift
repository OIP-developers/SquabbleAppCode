//
//  WalletViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

enum TransferType {
    case wallet
    case bank
    case donate
    case gift
}

enum TransactionFilterType {
    case all
    case sent
    case received
}

class WalletViewController: UIViewController {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recentLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var receivedButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var giftBalanceLabel: UILabel!

    @IBOutlet weak var giftPurchaseLabel: UILabel!
    @IBOutlet weak var tokenPurchaseLabel: UILabel!

    
    var isFilter: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.filterView.isHidden = !self.isFilter
            }
        }
    }
    var transferType: TransferType = .bank
    var filterType: TransactionFilterType = .all
    var transactions = [Account]()
    var dateArr = [Account]()
    var transactionDateArr = [Account]()
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //getTransactionList()
        //getWalletBalance()
        getMyProfile()
    }
    
    // MARK: - Helper Method
    func customSetup(){
        isFilter = false
        allButton.isSelected = true
        filterView.isUserInteractionEnabled = true
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapAction))
        filterView.addGestureRecognizer(viewTap)
    }
    
    func removeArray() {
        self.transactions.removeAll()
        self.dateArr.removeAll()
    }
    
    // MARK: - Target Method
    @objc func viewTapAction(){
        isFilter = false
    }
    
    //MARK:- UIButton Action Method
    @IBAction func addToWalletButtonAction(_ sender: UIButton){
        if let vc = UIStoryboard.wallet.get(AddTokenViewController.self) {
            vc.transferType = .wallet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func purchaseGiftButtonAction(_ sender: UIButton){
        if let vc = UIStoryboard.wallet.get(PurchaseGiftsViewController.self) {
            vc.transferType = .gift
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func filterButtonAction(_ sender: UIButton){
        isFilter = true
    }
    @IBAction func crossButtonAction(_ sender: UIButton){
        isFilter = false
    }
    @IBAction func donateButtonAction(_ sender: UIButton){
        if let vc = UIStoryboard.wallet.get(BankDetailsVC.self){
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func allButtonAction(_ sender: UIButton){
        isFilter = false
        allButton.isSelected = true
        receivedButton.isSelected = false
        sendButton.isSelected = false
        filterType = .all
        removeArray()
        getTransactionList()
    }
    @IBAction func receivedButtonAction(_ sender: UIButton){
        isFilter = false
        allButton.isSelected = false
        receivedButton.isSelected = true
        sendButton.isSelected = false
        filterType = .received
        removeArray()
        getTransactionList()
    }
    @IBAction func sendButtonAction(_ sender: UIButton){
        isFilter = false
        allButton.isSelected = false
        receivedButton.isSelected = false
        sendButton.isSelected = true
        filterType = .sent
        removeArray()
        getTransactionList()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendToBankButtonAction(_ sender: UIButton) {
        if let vc = UIStoryboard.wallet.get(SendMoneyToBankViewController.self) {
            vc.transferType = .bank
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dateArr.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.width, height: 30))
        let label = UILabel.init(frame: CGRect.init(x: 20, y: section > 0 ? 18 : 7.5, width: self.tableView.frame.width, height: 15))
        view.backgroundColor = KAppBlackColor
        label.backgroundColor = KAppBlackColor
        if section <= self.dateArr.count {
            label.text = self.dateArr[section].date
        }
        label.font = Fonts.Rubik.regular.font(.small)
        label.textColor = .white
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  section > 0 ? 40 : 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dateArr[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell", for: indexPath) as! WalletTableViewCell
        cell.cellSetup(obj: self.dateArr[indexPath.section].transactions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension WalletViewController {
    
    func getMyProfile() {
        
        APIService
            .singelton
            .getMyProfile()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" && val.Wallet != nil {
                            Logs.show(message: "\(val.id ?? "")")
                            if val.Wallet.id != "" {
                                self.balanceLabel.text = "\(val.Wallet.coins ?? 0)"
                                self.giftBalanceLabel.text = "\(val.Wallet.gifts ?? 0)"
                            }
                        } else {
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
    
    
    func getTransactionList(){
        var param = [String: Any]()
        param["filter_type"] = filterType == .all ? "1" : filterType ==  .sent ? "2" : "3"
        WebServices.filterTransaction(params: param) { (response) in
            if let arr = response?.array {
                self.transactions = arr
                self.getDateArray()
                self.tableView.reloadData()
            }
        }
    }
    
    func getWalletBalance(){
        WebServices.getAccountBalance { (response) in
            if let object = response?.object {
                let auth = AuthManager.shared.loggedInUser
                auth?.user_balance = object.user_balance
                auth?.gift_balance = object.gift_balance
                AuthManager.shared.loggedInUser = auth
                let balance = Int(AuthManager.shared.loggedInUser?.user_balance ?? 0)
                self.balanceLabel.text = "\(balance)"
                self.giftBalanceLabel.text = "\(object.gift_balance ?? 0)"
            }
        }
    }
    

    
    func getDateArray(){
        self.dateArr = removeDuplicateElements(transaction: self.transactions)
        self.transactionElementsArray()
    }
    
    func removeDuplicateElements(transaction: [Account]) -> [Account] {
        var uniqueDateArr = [Account]()
        for item in transactions {
            if !uniqueDateArr.contains(where: {$0.date == item.date }) {
                uniqueDateArr.append(item)
            }
        }
        return uniqueDateArr
    }
    
    func transactionElementsArray()  {
        for item in transactions {
            for (index, date) in dateArr.enumerated() {
                if item.date == date.date {
                    self.dateArr[index].transactions.append(item)
                }
            }
        }
    }
}


