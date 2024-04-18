//
//  MessageListViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase

class MessageListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var chatsUsers = [ChatModel]()
    
    var db: Firestore!
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessageList()
        
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}

extension MessageListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListTableViewCell", for: indexPath) as! MessageListTableViewCell
        let obj = chatsUsers[indexPath.row]
        cell.cellSetup(obj: obj)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            vc.chatModel = chatsUsers[indexPath.row]
            let transition = CATransition()
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.fade
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
            // completionHandler(true)
            //self.deleteMessage(obj: self.chats[indexPath.row])
        }
        deleteAction.image = UIImage.init(named: "icn_cross")
        deleteAction.backgroundColor = RGBA(9, g: 9, b: 9, a: 1.0)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}

extension MessageListViewController {
    
    func getMessageList(){
        
        
        let collectionRef = db.collection("ChatUsers")
        collectionRef.getDocuments { (querySnapshot, err) in
            if let error = err {
                Logs.show(message: "Error: \(error)")
                return
            }
            self.chatsUsers.removeAll()
            let decoder = JSONDecoder()
            //Make a mutable copy of the NSDictionary
            if let docs = querySnapshot?.documents {
                for doc in docs {
                    let dict = doc.data()
                    if let data = try?  JSONSerialization.data(withJSONObject: dict, options: []) {
                        do {
                            let user = try decoder.decode(ChatModel.self, from: data)
                            self.chatsUsers.append(user)
                        } catch (let error) {
                            Logs.show(message: "No user: \(error)")
                        }
                        
                    }
                }
            }
                        
            Logs.show(message: "\(self.chatsUsers)")
            self.tableView.reloadData()

        }
        
    }
    
    func deleteMessage(obj: UserModel){
        
    }
}

