//
//  VideosModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 02/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class VideosModelArray : NSObject, Codable {
    var videos : VideosModel! // = ChallengesModel()
    
    override init() {
        videos = VideosModel()
        
    }
    private enum CodingKeys: String, CodingKey {
        case videos = "videos"
    }
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        videos  = try values.decodeIfPresent(VideosModel.self, forKey: .videos)
    }
}

public class VideosModel : NSObject, Codable {
    
    var id : String!
    var userId : String!
    var name : String!
    var caption : String!
    var thumbnail_url : String!
    var video_url : String!
    var likes_count : Int!
    var challenges : [ChallengesModelArray]!
    var categories : [CategoriesModelArray]!
    var likes : [LikesModel]!
    var user : UserAPIModel!
    var status : Bool!
    var isPublish : Bool!
    var isVerified : Bool!
    var isDeleted : Bool!
    var userVote : Bool!
    var postedUserFollow : Bool!
    
    override init() {
        id = ""
        userId = ""
        name = ""
        caption = ""
        thumbnail_url = ""
        video_url = ""
        likes_count = 0
        challenges = [ChallengesModelArray]()
        categories = [CategoriesModelArray]()
        likes = [LikesModel]()
        user = UserAPIModel()
        status = false
        isPublish = false
        isVerified = false
        isDeleted = false
        userVote = false
        postedUserFollow = false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "userId"
        case name = "name"
        case caption = "caption"
        case thumbnail_url = "thumbnail_url"
        case video_url = "video_url"
        case likes_count = "likes_count"
        case challenges = "challenges"
        case categories = "categories"
        case likes = "likes"
        case user = "user"
        case status = "status"
        case isPublish = "isPublish"
        case isVerified = "isVerified"
        case isDeleted = "isDeleted"
        case userVote = "userVote"
        case postedUserFollow = "postedUserFollow"
    }
    
    required public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        userId  = try values.decodeIfPresent(String.self, forKey: .userId)
        name  = try values.decodeIfPresent(String.self, forKey: .name)
        caption  = try values.decodeIfPresent(String.self, forKey: .caption)
        thumbnail_url  = try values.decodeIfPresent(String.self, forKey: .thumbnail_url)
        video_url  = try values.decodeIfPresent(String.self, forKey: .video_url)
        likes_count  = try values.decodeIfPresent(Int.self, forKey: .likes_count)
        challenges = try values.decodeIfPresent([ChallengesModelArray].self, forKey: .challenges)
        categories = try values.decodeIfPresent([CategoriesModelArray].self, forKey: .categories)
        likes = try values.decodeIfPresent([LikesModel].self, forKey: .likes)
        user = try values.decodeIfPresent(UserAPIModel.self, forKey: .user)
        status  = try values.decodeIfPresent(Bool.self, forKey: .status)
        isPublish  = try values.decodeIfPresent(Bool.self, forKey: .isPublish)
        isDeleted  = try values.decodeIfPresent(Bool.self, forKey: .isDeleted)
        isVerified  = try values.decodeIfPresent(Bool.self, forKey: .isVerified)
        userVote  = try values.decodeIfPresent(Bool.self, forKey: .userVote)
        postedUserFollow  = try values.decodeIfPresent(Bool.self, forKey: .postedUserFollow)
    }
}

class LikesModel : NSObject, Codable {
    
    var userId : String!
    var videoId : String!
    
}

