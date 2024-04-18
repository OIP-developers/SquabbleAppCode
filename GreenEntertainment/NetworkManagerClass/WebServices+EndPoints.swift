//
//  Webservice+EndPoints.swift
//  GreenEntertainment
//
//  Created by MacMini-iOS on 18/07/19.
//  Copyright © 2019 Quytech. All rights reserved.
//



extension WebServices {
    
    static var baseUrl: String {
       
        //Production url
      //  return "https://quytech.net/green-entertainment/mobileapi/"
        // Staging
        return "https://quytech.net/green-entertainment-test/mobileapi/"
        
          // return "http://3.7.147.28/green-entertainment/mobileapi/"
    }
    
    
    enum EndPoint : String {
        case registration = "sign_up"
        case login = "sign_in"
        case registerVerifyOtp = "verify_otp"
        case resendOtp = "resend_otp"
        case forget_password = "forget_password"
        case reset_password = "reset_password"
        case change_password = "change_password"
        case edit_user_profile = "edit_user_profile"
        case term_condition = "term"
        case about_us = "about"
        case logout = "logout"
        case fetch_content = "fetch_content"
        case update_existing_email = "update_existing_email"
        case view_user_profile = "other_user_profile"
        case get_followers_followings = "get_followers_followings"
        case my_rewards = "my_rewards"
        case claim_reward = "claim_reward"
        case notification_setting = "notification/settings"
        case update_notification_setting = "update/notification/settings"
        case contact_us = "contact_us"
        case user_suggestion = "user_suggestion"
        case users = "list_users_except_me"
        case send_invite = "send_invite"
        case follow_user = "follow_unfollow"
        case app_gallery = "app_gallery"
        case get_challenge_list = "challenges"
        case donate_money_to_user = "donate_money_to_user"
        case send_message = "send_message"
        case view_users_list = "view_users_list"
        case delete_chat_messages = "delete_chat_messages"
        case view_message = "view_message"
        case share_video = "share_video"
        case increase_view_count_video = "increase_view_count_video"
        case find_friends = "find_user"
        case save_video_file = "save_video_file"
      //  case save_video_file = "video_without_aws"
        case challenge_name_list = "challenge_name_list"
        case post_video_challenge = "post_video_challenge"
        case participate_challenge = "participate_challenge"
        case filter_transaction = "filter_transaction"
        case save_video_to_gallery = "post_video_to_gallery"
        case notifications = "notifications"
        case vote_video = "vote_video"
        case trending_general_following = "trending_general_following"
        case delete_notification = "delete_notification"
        case clear_notification = "clear_notification"
        case search_challenge = "challenge_search"
        case fetch_challenge_data = "fetch_challenge_data"
        case get_leader_board = "get_leader_board"
        case unread_counts = "unread_counts"
        case mark_read_notification = "mark_read_notification"
        case add_money_to_wallet = "add_money_to_wallet"
        case user_balance = "user_balance"
        case user_badge_list = "user_badge_list"
        case claim_badge = "claim_badge"
        case live_streaming_check = "live_streaming_check"
        case getClientSecretKey = "create_paymentIntent"
        case get_ephemeral_key = "get_ephemeral_key"
        case add_new_bank = "add_new_bank_account"
        case bank_list = "user_bank_list"
        case delete_bank = "delete_bank_account"
        case withdraw_money_bank = "withdraw_money_bank"
        case update_bank_account = "update_bank_account"
        case delete_video = "delete_video_file"
        case livestream_view = "livestream_view"
        case remove_video_challenge = "remove_video_challenge"
        case edit_video_caption = "edit_video_caption"
        case video_detail = "video_detail"
        case is_admin_live = "is_admin_live"
        case user_account_settings = "user_account_settings"
        case update_user_account_settings = "update_user_account_settings"
        case accept_reject = "accept_reject_cancel"
        case get_request_notification_list = "get_request_notification_list"
        case delete_request = "delete_request"
        case badge_update = "badge_update"
        case search_followings = "search_followings"
        case reportvideo = "reportvideo"
        case delete_trophy_video = "delete_trophy_file"
        case topup_coins_value = "topup_coins_value"
        case user_bank_info = "user_bank_info"
        case block_unblock_user = "block_unblock_user"
        case blocked_user_list = "blocked_user_list"
        case token_withdraw_value = "token_withdraw_value"
        case tc_show = "tc_show"
        case gift_purchase = "gift_purchase"
        case delete_bankAcc = "delete_bank"
        case user_app_time = "user_app_time"
        case user_app_download = "user_app_download"


        var path : String {
            let url = baseUrl
            return url + self.rawValue
        }
    }

}

enum Response {
    case success(Any?)
    case failure(String?)
}

internal struct APIConstants {
    
    static let code = "code"
    static let success = "success"
    static let message = "message"
    
}

enum Validate : String {
    case none
    case success = "200"
    case failure = "400"
    case invalidAccessToken = "240"
    case adminBlocked = "402"
    
    static func link(code: String) -> Validate {
        switch code {
        case "200", "409","402", "201", "203","0":
            return .success
        default:
            return .failure
        }
    }
}

