//
//  InviteViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 19/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import Contacts

class InviteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var contacts = [FetchedContact]()
    
    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactImageDataAvailableKey,CNContactImageDataKey,CNContactThumbnailImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        
                        var phone = contact.phoneNumbers.first?.value.stringValue ?? ""
                        
                   //  phone =   phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        
                        
                        
                        self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: phone, imageData: (contact.imageDataAvailable ? contact.imageData : contact.thumbnailImageData) ?? Data(), status: false))
                    })
                    DispatchQueue.main.async {
                        
                        self.contacts = self.contacts.sorted()
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    //MARK:- Target Method
    @objc func inviteButtonAction(_ sender: UIButton){
        let obj = contacts[sender.tag]
        sendInvite(obj: obj)
        
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}
extension InviteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        let obj = contacts[indexPath.row]
        cell.followButton.tag = indexPath.row

        cell.nameLabel.text = "\(obj.firstName ) \(obj.lastName ?? "")\n\(obj.telephone ?? "")"
        if obj.imageData?.count == 0 {
            cell.profileImageView.image = UIImage(named: "ic_user_placeholder")
        }else {
            cell.profileImageView.image = UIImage(data: obj.imageData ?? Data())
        }
        cell.followButton.setTitle(obj.status ?? false ? "Invited" : "Invite", for: .normal)
        cell.followButton.backgroundColor = obj.status ?? false ? KAppGrayColor : KAppRedColor
        cell.followButton.isUserInteractionEnabled = !(obj.status ?? false)
        cell.followButton.addTarget(self, action: #selector(inviteButtonAction(_ :)), for: .touchUpInside)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
   
}


class FetchedContact: Comparable {
    
    
    var firstName: String = ""
    var lastName: String?
    var telephone: String?
    var imageData: Data?
    var status: Bool?
    
    init(firstName: String,lastName: String,telephone: String , imageData: Data,status: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.telephone = telephone
        self.imageData = imageData
        self.status = status
    }
    
    static func ==(lhs: FetchedContact, rhs: FetchedContact) -> Bool {
        return lhs.firstName == rhs.firstName
    }

    static func <(lhs: FetchedContact, rhs: FetchedContact) -> Bool {
        return lhs.firstName < rhs.firstName
    }
}


extension InviteViewController {
    
    func sendInvite(obj: FetchedContact){
        var param = [String: Any]()
        param["mobile_number"] = obj.telephone?.components(separatedBy: ["(", " ",")" , "-"]).joined()
        
        WebServices.sendInvite(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.status = true
                self.tableView.reloadData()
            }
        }
    }
    
}

