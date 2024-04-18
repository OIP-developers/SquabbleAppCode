//
//  BankDetailsVC.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/12/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import UIKit

class BankDetailsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tickBtn: UIButton!
    @IBOutlet weak var bankDetailsTV: UITableView!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        ProgressHud.hideActivityLoader()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tickBtnPressed(_ sender: Any) {
        
        // Assuming tickBtn.imageView?.image is not nil
        if let tickImage = tickBtn.imageView?.image,
           let icnTickImage = UIImage(named: "icn_tick"),
           let tickImageData = tickImage.pngData(),
           let icnTickImageData = icnTickImage.pngData() {
            
            if tickImageData == icnTickImageData {
                
                if country != "" && currency != "" && accountName != "" && accountNumber != "" && routingNumber != "" {
                    //Logs.show(message: country + currency + accountName + accountNumber + routingNumber)
                    addBank()
                } else {
                    showAlert(textMsg: "Some information is not added yet!", isEmpty: true)
                }
                
            } else {
                
                showAlert(textMsg: "Are you sure you want to delete linked bank details!", isEmpty: false)

                
            }
        } else {
            // One or both images are nil or couldn't be converted to data
            print("BOTH NILLL")
        }
    }
    
    var bankDetails = [String]()
    var textArray = ["Country","Currency","Account Holder Name","Account Number","Routing Number"]
    var placeholderBArray = ["Enter country name","Enter currency","Enter name on your account","Enter Account Number","Enter routing number"]

    var country = "" , currency = "" , accountName = "" , accountNumber = "" , routingNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getbank()
        
        registerCells()
    }

    func registerCells() {
        
        bankDetailsTV.tableFooterView = UIView()
        bankDetailsTV.separatorStyle = .none
        bankDetailsTV.delegate = self
        bankDetailsTV.dataSource = self
        bankDetailsTV.register(UINib(nibName: "BankdetailTVCell", bundle: nil),  forCellReuseIdentifier: "BankdetailTVCell")
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField.tag == 0 {
            country = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 1 {
            currency = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 2 {
            accountName = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 3 {
            accountNumber = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 4 {
            routingNumber = !textField.text!.isTFBlank ? textField.text! : ""
        }
        
    }
    
    func showAlert(textMsg: String, isEmpty: Bool) {
        // create the alert
        let alert = UIAlertController(title: "Alert", message: textMsg, preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        if !isEmpty {
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                
               // delete bank details
                self.deleteBank()
                
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            
            // do something like...
            alert.dismiss(animated: true)
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func getbank() {
        Logs.show(message: "Saved Vids :::: ")
        ProgressHud.showActivityLoader()
        
        
        APIService
            .singelton
            .getBankDetails()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if !val.account_number.isEmpty {
                            self.bankDetails = [val.country,val.currency,val.account_holder_name, val.account_number,val.routing_number]
                            tickBtn.setImage(UIImage(named: "icn_white_delete"), for: .normal)
                            bankDetailsTV.reloadData()
                            ProgressHud.hideActivityLoader()

                        } else {
                            AppFunctions.showSnackBar(str: "Error getting Bank details")
                            ProgressHud.hideActivityLoader()
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
    func addBank() {
        Logs.show(message: "Saved Vids :::: ")
        ProgressHud.showActivityLoader()

        let pram : [String : Any] = ["country": country,
                                    "currency": currency,
                                    "account_holder_name": accountName,
                                    "account_number": accountNumber,
                                    "routing_number": routingNumber]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        APIService
            .singelton
            .addBankDetails(Pram: pram )
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            
                            AppFunctions.showSnackBar(str: "Bank Details added!")
                            tickBtn.setImage(UIImage(named: "icn_white_delete"), for: .normal)
                            ProgressHud.hideActivityLoader()

                        } else {
                            AppFunctions.showSnackBar(str: "Error adding Bank details")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func deleteBank() {
        Logs.show(message: "Saved Vids :::: ")
        ProgressHud.showActivityLoader()
        
        
        APIService
            .singelton
            .deletebankDetails()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            
                            AppFunctions.showSnackBar(str: "Bank Details deleted!")
                            tickBtn.setImage(UIImage(named: "icn_tick"), for: .normal)
                            ProgressHud.hideActivityLoader()
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            AppFunctions.showSnackBar(str: "Error deleting Bank details")
                            ProgressHud.hideActivityLoader()
                            
                        }
                    case .error(let error):
                        print(error)
                        ProgressHud.hideActivityLoader()
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
}
extension BankDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderBArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BankdetailTVCell = tableView.dequeueReusableCell(withIdentifier: "BankdetailTVCell", for: indexPath) as! BankdetailTVCell
        
        cell.nameLbl.text = textArray[indexPath.row]
        cell.valueTF.placeholder = placeholderBArray[indexPath.row]
        cell.valueTF.delegate = self
        cell.valueTF.tag = indexPath.row
        
        if !bankDetails.isEmpty {
            cell.valueTF.text = bankDetails[indexPath.row]
            cell.valueTF.isEnabled = false
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
}
