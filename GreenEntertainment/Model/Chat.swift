//
//  Chat.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 30/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Chat: Mappable {
    var user_id: String?
    var first_name: String?
    var last_name: String?
    var image_url: String?
    var chat_id: String?
    var start_timestamp: String?
    var end_timestamp: String?
    var chat_text: String?
    var receiver_id: String?
    var chat_type: String?
    var url: String?
    var created_timestamp: String?
    var unread_chat_count: String?
    var last_message: String?
    var last_message_timestamp: String?
    var name_of_user: String?
    var read_status:  String?
    var last_message_chat_type: String?
    var video_id: String?
    var video_path: String?
    var video_thumbnail: String?
    var share_message: String?
    var username: String?
    var setting: String?
    var request_status: String?
    var is_following: Int?
    var user_following_you: Int?
    var blocked_status: Int?
    var check_if_you_block : Int?

    
    init(){
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        user_id <- map["user_id"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        image_url <- map["image_url"]
        chat_id <- map["chat_id"]
        start_timestamp <- map["start_timestamp"]
        end_timestamp <- map["end_timestamp"]
        chat_type <- map["chat_type"]
        receiver_id <- map["receiver_id"]
        chat_text  <- map["chat_text"]
        url  <- map["url"]
        created_timestamp <- map["created_timestamp"]
        unread_chat_count <- map["unreadMsgCount"]
        last_message <- map["last_message"]
        last_message_timestamp <- map["last_message_timestamp"]
        name_of_user <- map["name_of_user"]
        read_status <- map["read_status"]
        last_message_chat_type <- map["last_message_chat_type"]
        video_id <- map["video_id"]
        video_path <- map["video_path"]
        video_thumbnail <- map["video_thumbnail"]
        share_message <- map["share_message"]
        username <- map["username"]
        setting <- map["setting"]
        request_status <- map["request_status"]
        is_following <- map["is_following"]
        user_following_you <- map["user_following_you"]
        blocked_status <- map["blocked_status"]
        check_if_you_block <- map["check_if_you_block"]
    }

}


