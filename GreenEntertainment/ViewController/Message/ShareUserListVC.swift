//
//  ShareUserListVC.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 15/12/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ShareUserListVC: UIViewController {
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var usersTV: UITableView!
    
    var followingUserList = [FollowUsers]()
    var messageUserList = [ChatModel]()
    var db: Firestore!
    var videoUrl = ""
    var chats = [ChatModelExt]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        registerCells()
        getMessageList()
        // Do any additional setup after loading the view.
    }
    
    func registerCells() {
        
        usersTV.tableFooterView = UIView()
        usersTV.separatorStyle = .none
        usersTV.delegate = self
        usersTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        usersTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        
        usersTV.register(UINib(nibName: "ShareUserTVCell", bundle: nil), forCellReuseIdentifier: "ShareUserTVCell")
        usersTV.register(UINib(nibName: "HeadingTVCell", bundle: nil), forCellReuseIdentifier: "HeadingTVCell")
    }
    
    func getMessageList(){
        
        
        let collectionRef = db.collection("ChatUsers")
        collectionRef.getDocuments { (querySnapshot, err) in
            if let error = err {
                Logs.show(message: "Error: \(error)")
                return
            }
            self.messageUserList.removeAll()
            let decoder = JSONDecoder()
            //Make a mutable copy of the NSDictionary
            if let docs = querySnapshot?.documents {
                for doc in docs {
                    let dict = doc.data()
                    if let data = try?  JSONSerialization.data(withJSONObject: dict, options: []) {
                        do {
                            let user = try decoder.decode(ChatModel.self, from: data)
                            self.messageUserList.append(user)
                        } catch (let error) {
                            Logs.show(message: "No user: \(error)")
                        }
                        
                    }
                }
                self.getMyProfile()
            }
        }
        
    }
    
    
    func getMyProfile() {
        //ProgressHud.showActivityLoader()
        APIService
            .singelton
            .getMyProfile()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.id != "" {
                            
                            if val.follower != nil {
                                self.followingUserList = val.follower
                            }
                            for u in messageUserList {
                                self.followingUserList = self.followingUserList.filter({$0.first_name != u.name })
                            }
                            
                            usersTV.reloadData()
                            //ProgressHud.hideActivityLoader()
                        } else {
                            //ProgressHud.hideActivityLoader()
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func AddMessageUserList(user: FollowUsers, isNew: Bool, chatModel: ChatModel) {
        
        Logs.show(message: "IS NEW : \(isNew)")
        var user1 = [String:Any]()
        
        if isNew {
            if Auth.auth().currentUser != nil {
                user1["sender_id"] = AppFunctions.getUserID()
                user1["receiver_id"] = user.id
                user1["name"] = user.first_name
                user1["blockStatus"] = false
                
                let userIds = [user.id, AppFunctions.getUserID()].compactMap { $0 }
                let sortedIds = userIds.sorted()
                user1["chatChannelId"] = sortedIds.joined(separator: " - ")

                user1["chatChannelId"] = user.id + " - " + AppFunctions.getUserID()
                user1["profilePic"] = user.profile_picture == nil ? "https://firebasestorage.googleapis.com:443/v0/b/squabble-42140.appspot.com/o/Images_Folder%2FprofImage_1664877616.jpg?alt=media&token=06573605-861a-4d75-a304-313d833a9b8f" : user.profile_picture
                
            }
        }
                
        var chanelId = ""
        if isNew {
            chanelId = user1["chatChannelId"] as! String
        } else {
            chanelId = chatModel.chatChannelId
        }
        
        getMessageHistory(chanelId: chanelId, chatModel: chatModel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            var dictModel = [String:Any]()
            var dictModelChat = [String:Any]()
            var dictModelChatArray = [[String:Any]]()
            
            var chat = [String:Any]()
            chat["sender_id"] = AppFunctions.getUserID()
            chat["receiver_id"] = isNew ? user1["receiver_id"] as? String : chatModel.receiver_id
            chat["name"] = isNew ? user1["name"] as? String : chatModel.name
            chat["message"] = "Hey I would like you to watch this.. \nVideo : " + self.videoUrl
            chat["time"] = "\(Date())"
            
            do {
                for c in self.chats {
                    dictModelChat = try self.encode(c)
                    dictModelChatArray.append(dictModelChat)
                }
                dictModelChatArray.append(chat)
            } catch(let error) {
                Logs.show(message: "Model E: \(error)")
            }
            
            if isNew {
                user1["chatMessages"] = dictModelChatArray
            } else {
                do {
                    dictModel = try self.encode(chatModel)
                    dictModel["chatMessages"] = dictModelChatArray
                } catch(let error) {
                    Logs.show(message: "Model E: \(error)")
                }
            }
            
            self.db.collection("ChatUsers").document(isNew ? user1["chatChannelId"] as! String : chatModel.chatChannelId).setData(isNew ? user1 : dictModel)
        }
        
        AppFunctions.showSnackBar(str: "Video Shared...")
        
        self.dismiss(animated: true)
        
    }
    
    func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let jsonData = try JSONEncoder().encode(value)
        return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
    }
    
    func getMessageHistory(chanelId: String, chatModel: ChatModel){
        
        let collectionRef = db.collection("ChatUsers").document(chanelId)
        
        collectionRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                
                Logs.show(message: "CHAT: \(document)")
                let decoder = JSONDecoder()
                let dict = document.data()
                if let data = try?  JSONSerialization.data(withJSONObject: dict!, options: []) {
                    do {
                        let chat = try decoder.decode(ChatModel.self, from: data)
                        
                        if chat.chatMessages != nil {
                            self?.chats.removeAll()
                            self?.chats.append(contentsOf: (chatModel.chatMessages)!)
                            
                        }
                        
                    } catch (let error) {
                        Logs.show(message: "No user: \(error)")
                    }
                }
                
            } else {
                Logs.show(message: "No chat")
            }
        }
    }
}

extension ShareUserListVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return  messageUserList.count > 0 ? messageUserList.count + 1 : 0 // Unread notifications
            case 1:
                return followingUserList.count + 1 // Read notifications
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0: // Unread notifications
                if indexPath.row == 0 { // Subheader
                    let cell: HeadingTVCell = tableView.dequeueReusableCell(withIdentifier: "HeadingTVCell", for: indexPath) as! HeadingTVCell
                    
                    cell.headingLbl.text = "Recent chats"
                    
                    return cell
                } else { //
                    let cell: ShareUserTVCell = tableView.dequeueReusableCell(withIdentifier: "ShareUserTVCell", for: indexPath) as! ShareUserTVCell
                    
                    cell.userNameLbl.text = messageUserList[indexPath.row - 1].name
                    if let url = URL(string: messageUserList[indexPath.row - 1].profilePic ?? "") {
                        cell.userProfilePic.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
                    }
                    return cell
                }
            case 1: //
                if indexPath.row == 0 { // Subheader
                    let cell: HeadingTVCell = tableView.dequeueReusableCell(withIdentifier: "HeadingTVCell", for: indexPath) as! HeadingTVCell
                    cell.headingLbl.text = "Followrs"
                    return cell
                } else { //
                    let cell: ShareUserTVCell = tableView.dequeueReusableCell(withIdentifier: "ShareUserTVCell", for: indexPath) as! ShareUserTVCell
                    
                    cell.userNameLbl.text = followingUserList[indexPath.row - 1].first_name
                    if let url = URL(string: followingUserList[indexPath.row - 1].profile_picture ?? "") {
                        cell.userProfilePic.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
                    }
                    return cell
                }
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 {
            if indexPath.row != 0 {
                AddMessageUserList(user: FollowUsers(), isNew: false, chatModel: messageUserList[indexPath.row - 1])
            }
        } else {
            if indexPath.row != 0 {
                AddMessageUserList(user: followingUserList[indexPath.row - 1], isNew: true, chatModel: ChatModel())
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
}

