//
//  ChallengeModel.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 29/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class ChallengeModel: Mappable {
    var challenge_id: String?
    var hashtag: String?
    var title: String?
    var price: String?
    var challenge_type: String?
    var start_timestamp: String?
    var end_timestamp: String?
    var status: String?
    var claim_status: String?
    var check_if_completed: Int?
    var is_voted: Int?
    var is_prime_time: String?

    
    init(){
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        challenge_id <- map["challenge_id"]
        hashtag <- map["hashtag"]
        title <- map["title"]
        price <- map["price"]
        challenge_type <- map["challenge_type"]
        start_timestamp <- map["start_timestamp"]
        end_timestamp <- map["end_timestamp"]
        status <- map["status"]
        claim_status <- map["claim_status"]
        check_if_completed <- map["check_if_completed"]
        is_voted <- map["is_voted"]
        is_prime_time <- map["is_prime_time"]
        
    }
    
}


class SearchModel: Mappable {
    
    var video_id: String?
    var video_text: String?
    var user_id: String?
    var video_path: String?
    var video_thumbnail: String?
    var first_name: String?
    var last_name: String?
    var username: String?
    var image_url: String?
    var tag: String?
    var title: String?
    var is_posted: String?
    var views_count: String?
    var votes_count: String?
    var video_share_count: String?
    var user_name: String?
    var user_image: String?
    var is_following: Int?
    var is_sponsered: String?
    var is_voted: Int?
    var challenge_id: String?
    var video_owner: String?
    var video_thumbnail_new: String?
    var setting: String?
    var request_status: String?
    var primary_key_follow_id: String?
    var tagged_user = [TaggedUser]()
    var challenge = ChallengeModel()
    var is_voted_two_times: Int?
    var is_voted_prime: Int?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        video_id <- map["video_id"]
        video_text <- map["video_text"]
        user_id <- map["user_id"]
        video_path <- map["video_path"]
        video_thumbnail <- map["video_thumbnail"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        username <- map["username"]
        image_url <- map["image_url"]
        tag <- map["tag"]
        title <- map["title"]
        is_posted <- map["is_posted"]
        views_count <- map["views_count"]
        votes_count <- map["votes_count"]
        video_share_count <- map["video_share_count"]
        user_name <- map["user_name"]
        user_image <- map["user_image"]
        is_following <- map["is_following"]
        is_sponsered <- map["is_sponsered"]
        is_voted <- map["is_voted"]
        challenge_id <- map["challenge_id"]
        video_owner <- map["video_owner"]
        video_thumbnail_new <- map["video_thumbnail_new"]
        setting <- map["setting"]
        request_status <- map["request_status"]
        primary_key_follow_id <- map["primary_key_follow_id"]
        tagged_user <- map["tagged_user"]
        challenge <- map["challenge"]
        is_voted_two_times <- map["is_voted_two_times"]
        is_voted_prime <- map["if_prime_voted"]
    }
}
