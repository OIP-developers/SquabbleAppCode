//
//  UserModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 22/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class Token : Codable {
    var accessToken: String!
    var refreshToken: String!
}

class UserModel : NSObject, Codable {
    
    var id : String!
    var name : String!
    var sender_id : String
    var receiver_id : String
    var chatChannelId : String!
    var chatCount: Int
    var blockStatus : Bool!
    var profilePic : String!
    var time : String!
    
    override init() {
        id = ""
        name = ""
        sender_id = ""
        receiver_id = ""
        chatChannelId = ""
        chatCount = 0
        blockStatus = false
        profilePic = ""
        time = ""
        super.init()
    }
}


class UserAPIModel : NSObject, Codable {
    
    var id : String! // = CategoriesModel()
    var profile_picture: String!
    var first_name: String!
    var email: String!
    var gender: String!
    var last_name: String!
    var stripe_customerId: String!
    var isPublic: Bool!
    var follower: [FollowUsers]!
    var following: [FollowUsers]!
    var badge: [BadgeModel]!
    var videos: [VideosModel]!
    var Wallet: WalletModel!
    
    var isFollow: Bool!
    var isBlocked: Bool!
    
    var facebook: String!
    var tiktok: String!
    var instagram: String!
    var x: String!

    
    override init() {
        id = ""
        profile_picture = ""
        first_name = ""
        email = ""
        gender = ""
        last_name = ""
        stripe_customerId = ""
        isPublic = false
        follower = [FollowUsers()]
        following = [FollowUsers()]
        badge = [BadgeModel]()
        videos = [VideosModel]()
        Wallet = WalletModel()
        
        isFollow = false
        isBlocked = false
        
        facebook = ""
        tiktok = ""
        instagram = ""
        x = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case profile_picture = "profile_picture"
        case first_name = "first_name"
        case email = "email"
        case gender = "gender"
        case last_name = "last_name"
        case stripe_customerId = "stripe_customerId"
        case isPublic = "isPublic"
        case follower = "follower"
        case following = "Following"
        case badge = "badge"
        case videos = "videos"
        case Wallet = "Wallet"
        
        case isFollow = "isFollow"
        case isBlocked = "isBlocked"
        
        case facebook = "facebook"
        case tiktok = "tiktok"
        case instagram = "instagram"
        case x = "x"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        profile_picture  = try values.decodeIfPresent(String.self, forKey: .profile_picture)
        first_name  = try values.decodeIfPresent(String.self, forKey: .first_name)
        email  = try values.decodeIfPresent(String.self, forKey: .email)
        gender  = try values.decodeIfPresent(String.self, forKey: .gender)
        last_name  = try values.decodeIfPresent(String.self, forKey: .last_name)
        stripe_customerId  = try values.decodeIfPresent(String.self, forKey: .stripe_customerId)
        isPublic  = try values.decodeIfPresent(Bool.self, forKey: .isPublic)
        follower  = try values.decodeIfPresent([FollowUsers].self, forKey: .follower)
        following  = try values.decodeIfPresent([FollowUsers].self, forKey: .following)
        badge  = try values.decodeIfPresent([BadgeModel].self, forKey: .badge)
        videos  = try values.decodeIfPresent([VideosModel].self, forKey: .videos)
        Wallet  = try values.decodeIfPresent(WalletModel.self, forKey: .Wallet)
        
        isFollow  = try values.decodeIfPresent(Bool.self, forKey: .isFollow)
        isBlocked  = try values.decodeIfPresent(Bool.self, forKey: .isBlocked)
        
        facebook  = try values.decodeIfPresent(String.self, forKey: .facebook)
        instagram  = try values.decodeIfPresent(String.self, forKey: .instagram)
        tiktok  = try values.decodeIfPresent(String.self, forKey: .tiktok)
        x  = try values.decodeIfPresent(String.self, forKey: .x)

    }
}


