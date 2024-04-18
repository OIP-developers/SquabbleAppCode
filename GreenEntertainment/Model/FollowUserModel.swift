//
//  FollowUserModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 01/09/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class FollowUserAPIModel : NSObject, Codable {
    
    //var followerId: String!
    //var followingId: String!
    var follower: FollowUsers!
    var following: FollowUsers!
    
    
    override init() {
        //followerId = ""
        //followingId = ""
        follower = FollowUsers()
        following = FollowUsers()
    }
    
    private enum CodingKeys: String, CodingKey {
        //case followerId = "followerId"
        //case followingId = "followingId"
        case follower = "follower"
        case following = "following"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        //followerId  = try values.decodeIfPresent(String.self, forKey: .followerId)
        //followingId  = try values.decodeIfPresent(String.self, forKey: .followingId)
        follower  = try values.decodeIfPresent(FollowUsers.self, forKey: .follower)
        following  = try values.decodeIfPresent(FollowUsers.self, forKey: .following)
    }
}

class FollowUsers : NSObject, Codable {
    var id: String!
    var profile_picture: String!
    var first_name: String!
    var email: String!
    var gender: String!
    var last_name: String!
}
 
