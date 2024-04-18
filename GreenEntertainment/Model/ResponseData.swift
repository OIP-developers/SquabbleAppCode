//
//  ResponseData.swift
//  SafeHouse
//
//  Created by DEEPAK on 07/05/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ResponseData < T: Mappable >: Mappable{
    var message: String?
    var object: T?
    var array : [T]?
    var statusCode: Int?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        message <- map[Constants.kMessage]
        object <- map[Constants.kData]
        array <- map[Constants.kData]
        statusCode <- map[Constants.Code]
    }
}

class Initial: Mappable{
    var otp: String?
    var authToken: String?
    
    var unread_chat_count: Int?
    var unread_wallet_count: Int?
    var unread_setting_count: Int?
    var unread_notification_count: Int?
    var views_count: String?
    var user_balance: Double?
    var flag: Int?
    var is_admin_live: Int?
    var token: String?
    var encoded_token: String?
    var setting: String?
    var video_count: Int?
    var video_id: Int?
    var gift_balance: Int?

    var dynamic_error_message: String?
    var video_upload_access_error_message: String?
    var check_video_upload_access: Int?
    var tagged_user =  [TaggedUser]()
    init() {
        
    }

    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        otp <- map[Constants.OTP]
        authToken <- map[Constants.AUTH_TOKEN]
        unread_chat_count <- map["unread_chat_count"]
        unread_notification_count <- map["unread_notification_count"]
        views_count <- map["views_count"]
        user_balance <- map["user_balance"]
        flag <- map["flag"]
        token <- map["token"]
        is_admin_live <- map["is_admin_live"]
        setting <- map["setting"]
        encoded_token <- map["encoded_token"]
        video_count  <- map["video_count"]
        dynamic_error_message <- map["dynamic_error_message"]
        video_id <- map["video_id"]
        check_video_upload_access <- map["check_video_upload_access"]
        video_upload_access_error_message <- map["video_upload_access_error_message"]
        unread_wallet_count <- map["unread_wallet_count"]
        unread_setting_count <- map["unread_setting_count"]
        gift_balance <- map["gift_balance"]
        tagged_user <- map["tagged_user"]
    }
}

class NotificationSetting: Mappable{
    var receive_notification: String?
    var status = false
    var badge_count: Int?
    var show_flag: String?
    var vote_notification: String?
    var follower_notification: String?
    var chat_notification: String?
    var live_notification: String?
    var money_notification: String?
    var reward_not_claimed: Int?

    
    init(){
        
    }
    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        receive_notification <- map["receive_notification"]
        status = receive_notification == "A"
        badge_count <- map["claimed_badges_count"]
        show_flag <- map["show_flag"]
        reward_not_claimed <- map["reward_not_claimed"]
    }
}




/// --- Multipart handling modal (upload image and upload video)---
class VideoModal: Mappable {
    var video_id: Int?
    var video_url: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        video_id <- map[Constants.Video_ID]
        video_url <- map[Constants.Video_URL]
    }
}

class ImageModal: Mappable {
    var image_id: Int?
    var image_url: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        image_url <- map[Constants.kImage_URL]
    }
}
//
class DataApptimeid: Mappable {
    var user_app_time_id: Int?
    init(){
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        user_app_time_id <- map["user_app_time_id"]
    }
    
    
}

