//
//  User.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import StoreKit

public class UserProfile {
    var userID: String?
    var userEmail: String?
    var userNumber: String?
    var userZipCode: Int?
    
    init() {
    }
    deinit {
        print("User deinitialized")
    }
}

class User: Mappable, Comparable {
    
    
        
    var user_id: String?
    var socialId: Int?
    var socialIdString: String?
    var socialType: String?
    var age: String?
    var email: String?
    var username: String?
    var first_name: String?
    var image: String?
    var last_name: String?
    var phone_number: String?
    var zip_code: String?
    
    var mobile_number_country_code: String?
    var errorIndex = -1
    var errorMessage: String?
    var countryFlag: UIImage?
    
    var gender: String?
    var password: String?
    var newPassword: String?
    var confirm_password: String?
    var isAgreeToTnC: Bool?
    var hasEmailVerified: Bool?
    var highest_badge: String?
    var fbUserName: String?
    var instaUserName: String?
    var twitterUserName: String?
    var tiktokUserName: String?
    var isNotification: Bool?
    var profile_image: UIImage?
    
    var auth_token: String?
    var user_followers: Int?
    var user_followings: Int?
    
    var follow_status:Bool?
    var is_following: Int?
    var followingStatus: Bool?
    var followed_user_id: String?
    var followed_by_user_id: String?
 //   var highest_badge: String?
    
    var selectedStatus = 0   // 0 - send, 1 - undo , 2 - sent
    
    var app_gallery_posts = [RewardsModel]()
    var user_trophy_videos = [RewardsModel]()
    var claimed_badges_list = [Badge]()
    
    var user_balance: Double?
    var is_private: String?
    var setting: String?
    var request_status: String?
    var primary_key_follow_id: String?
    var dobTimestamp: String?
    var dob: String?
    var user_following_you: Int?
    var last_four_digits : String?
    var blocked_status: Int?
    var check_if_you_block : Int?
    
    var isAgreeToTermsnC: Int?
    var isShowAgain: Int?
    var gift_balance: Int?
    var bank_name: String?
    var account: String?
    var bank_id: String?
    
    init() {
        
    }
    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        
        user_id <- map["user_id"]
        image <- map["image_url"]
        mobile_number_country_code <- map["country_code"]
        auth_token <- map["auth_token"]
        age <- map["age"]
        email <- map["email_address"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        phone_number <- map["mobile_number"]
        gender <- map["gender"]
        zip_code <- map["zip_code"]
        username <- map["username"]
        fbUserName <- map["facebook_account"]
        instaUserName <- map["instagram_account"]
        twitterUserName <- map["twitter_account"]
        tiktokUserName <- map["tiktok_account"]
        user_followers <- map["user_followers"]
        user_followings <- map["user_followings"]
        follow_status <- map["follow_status"]
        is_following <- map["is_following"]
        followed_user_id <- map["followed_user_id"]
        followed_by_user_id <- map["followed_by_user_id"]
        app_gallery_posts <- map["app_gallery_posts"]
        user_trophy_videos <- map["user_trophy_videos"]
        user_balance <- map["token_balance"]
        claimed_badges_list <- map["claimed_badges_list"]
        highest_badge <- map["highest_badge"]
        setting <- map["setting"]
        request_status <- map["request_status"]
        primary_key_follow_id <- map["primary_key_follow_id"]
        dobTimestamp <- map["age"]
        dob <- map["dob"]
        last_four_digits <- map["last_four_digits"]
        blocked_status <- map["blocked_status"]
        check_if_you_block <- map["check_if_you_block"]
        isAgreeToTermsnC <- map["term_status"]
        isShowAgain <- map["dont_show"]
        gift_balance <- map["gift_balance"]
        bank_name <- map["bank_name"]
        account <- map["account"]
        bank_id <- map["id"]

        followingStatus = is_following == 1
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return (lhs.username ?? "") < (rhs.username ?? "")
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.username == rhs.username
    }
}


class CoinListModel: Mappable {
    
    var fn_coin_id : Int? = nil
    var dollar_value : String = ""
    var coins_count  : String = ""
    var status : Bool? = nil
    var created_at : Int? = nil
    var updated_at : Int? = nil
    var product: SKProduct? = nil
    var google_purchase_id : String = ""
    var apple_purchase_id : String = ""

    init() {
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        fn_coin_id <- map["fn_coin_id"]
        coins_count <- map["coins_count"]
        dollar_value <- map["dollar_value"]
        apple_purchase_id <- map["apple_purchase_id"]
        google_purchase_id <- map["google_purchase_id"]
        status <- map["status"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        
    }
}

class TokenModel: Mappable {
    
    var dollar_value : Double? = nil

    init() {
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        dollar_value <- map["dollar_value"]
       
        
    }
}



