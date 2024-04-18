//
//  NotificationModel.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 06/07/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class NotificationModel: Mappable {
    var notification_id: String?
    var user_id: String?
    var receiver_id: String?
    var notification_type: String?
    var payload: String?
    var title: String?
    var body: String?
    var is_read: String?
    var status: String?
    var created_at: String?
    var updated_at: String?
    var user_name: String?
    var user_image: String?
    var is_following: Int?
    var user_fullname_sharing_video: String?
    var who_followed_fullname: String?
    var who_followed_user_id: String?
    var who_followed_image: String?
    var token: String?
    var is_posted: String?
    var is_sponsered: String?
    var is_save_to_gallery: String?
    var is_win: String?
    var user_id_sharing_video: String?
    var user_image_sharing_video: String?
    var video_id: String?
    var video_path: String?
    var sender_id: String?
    var video_share_count: String?
    var video_text: String?
    var video_thumbnail: String?
    var views_count: String?
    var votes_count: String?
    var challenge_id: String?
    var challenge_title: String?
    var winner_name: String?
    var winner_image: String?
    var receiver_image: String?
    var start_timestamp: String?
    var end_timestamp: String?
    var sender_image: String?
    var intro_video_id: String?
    var intro_video_path: String?
    var intro_video_thumbnail: String?
    var sender_name: String?
    var badge_thumbnail: String?
    var badge_title: String?
    var receiver_name: String?
    var encoded_token: String?
    var share_message: String?
    var primary_key_follow_id: String?
    var who_followed_username: String?
    var donation_message: String?
    var blocked_status: Int?
    var check_if_you_block: Int?

    
    
    init(){
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        notification_id <- map["notification_id"]
        user_id <- map["user_id"]
        sender_id <- map["sender_id"]
        notification_type <- map["notification_type"]
        payload <- map["payload"]
        title <- map["title"]
        body <- map["body"]
        is_read <- map["is_read"]
        status <- map["status"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        user_name <- map["user_name"]
        user_image <- map["user_image"]
        is_following <- map["is_following"]
        user_fullname_sharing_video <- map["user_fullname_sharing_video"]
        who_followed_fullname <- map["who_followed_fullname"]
        who_followed_user_id <- map["who_followed_user_id"]
        who_followed_image <- map["who_followed_image"]
        is_posted <- map["is_posted"]
        is_sponsered <- map["is_sponsered"]
        is_save_to_gallery <- map["is_save_to_gallery"]
        is_win <- map["is_win"]
        user_id_sharing_video <- map["user_id_sharing_video"]
        user_image_sharing_video <- map["user_image_sharing_video"]
        video_id <- map["video_id"]
        video_path <- map["video_path"]
        video_share_count <- map["video_share_count"]
        video_text <- map["video_text"]
        video_thumbnail <- map["video_thumbnail"]
        views_count <- map["views_count"]
        votes_count <- map["votes_count"]
        challenge_title <- map["challenge_title"]
        winner_name <- map["winner_name"]
        winner_image <- map["winner_image"]
        start_timestamp <- map["start_timestamp"]
        end_timestamp <- map["end_timestamp"]
        receiver_image <- map["receiver_image"]
        receiver_id <- map["receiver_id"]
        intro_video_id <- map["intro_video_id"]
        intro_video_path <- map["intro_video_path"]
        intro_video_thumbnail <- map["intro_video_thumbnail"]
        sender_image <- map["sender_image"]
        sender_name <- map["sender_name"]
        badge_thumbnail <- map["badge_thumbnail"]
        badge_title <- map["badge_title"]
        token <- map["token"]
        challenge_id <- map["challenge_id"]
        receiver_name <- map["receiver_name"]
        encoded_token <- map["encoded_token"]
        share_message <- map["share_message"]
        primary_key_follow_id <- map["primary_key_following_id"]
        who_followed_username <- map["who_followed_username"]
        donation_message <- map["donation_message"]
        blocked_status <- map["blocked_status"]
        check_if_you_block <- map["check_if_you_block"]
    }
    
}



