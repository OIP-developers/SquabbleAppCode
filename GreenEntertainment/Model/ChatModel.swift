//
//  ChatModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 22/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class ChatModel : NSObject, Codable {
    
    var id : String!
    var profilePic : String!
    var name : String!
    var sender_id : String!
    var receiver_id : String!
    var chatChannelId : String!
    var blockStatus : Bool!
    var chatMessages: [ChatModelExt]!
    
    
    override init() {
        id = ""
        name = ""
        sender_id = ""
        receiver_id = ""
        chatChannelId = ""
        blockStatus = false
        profilePic = ""
        chatMessages = [ChatModelExt]()
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case sender_id = "sender_id"
        case receiver_id = "receiver_id"
        case chatChannelId = "chatChannelId"
        case blockStatus = "blockStatus"
        case profilePic = "profilePic"
        case chatMessages = "chatMessages"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        name  = try values.decodeIfPresent(String.self, forKey: .name)
        sender_id  = try values.decodeIfPresent(String.self, forKey: .sender_id)
        receiver_id  = try values.decodeIfPresent(String.self, forKey: .receiver_id)
        chatChannelId  = try values.decodeIfPresent(String.self, forKey: .chatChannelId)
        profilePic  = try values.decodeIfPresent(String.self, forKey: .profilePic)
        blockStatus  = try values.decodeIfPresent(Bool.self, forKey: .blockStatus)
        chatMessages  = try values.decodeIfPresent([ChatModelExt].self, forKey: .chatMessages)
    }
    
}

class ChatModelExt : NSObject, Codable {
    
    var id : String!
    var message : String!
    var time : String!
    var name : String!
    var sender_id : String!
    var receiver_id : String!
    
    
    override init() {
        id = ""
        name = ""
        sender_id = ""
        receiver_id = ""
        message = ""
        time = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case sender_id = "sender_id"
        case receiver_id = "receiver_id"
        case message = "message"
        case time = "time"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        name  = try values.decodeIfPresent(String.self, forKey: .name)
        sender_id  = try values.decodeIfPresent(String.self, forKey: .sender_id)
        receiver_id  = try values.decodeIfPresent(String.self, forKey: .receiver_id)
        message  = try values.decodeIfPresent(String.self, forKey: .message)
        time  = try values.decodeIfPresent(String.self, forKey: .time)
    }
    
}
