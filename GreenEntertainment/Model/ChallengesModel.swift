//
//  ChallengesModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 01/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class ChallengesModelArray : NSObject, Codable {
    var challenge : ChallengesModel! // = ChallengesModel()
    
    override init() {
        challenge = ChallengesModel()
        
    }
    private enum CodingKeys: String, CodingKey {
        case challenge = "challenge"
    }
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        challenge  = try values.decodeIfPresent(ChallengesModel.self, forKey: .challenge)
    }
}

class ChallengesModel : NSObject, Codable {
    
    var id : String!
    var name : String!
    var type : String!
    var prize : Int!
    var uploadTime : String!
    var uploadOpenAt : String!
    var uploadCloseAt : String!
    var votingTime : String!
    var votingOpenAt : String!
    var votingCloseAt : String!
    var allowedVideos : Int!
    var status : Bool!
    var isParticipate : Bool!
    var isPublish : Bool!
    var isVerified : Bool!
    var isDeleted : Bool!
    var categories : [CategoriesExtModel]!
    var videos : [VideosModel]!
    
    override init() {
        id = ""
        name = ""
        type = ""
        prize = 0
        uploadTime = ""
        uploadOpenAt = ""
        uploadCloseAt = ""
        votingTime = ""
        votingOpenAt = ""
        votingCloseAt = ""
        allowedVideos = 0
        categories = [CategoriesExtModel]()
        videos = [VideosModel]()
        status = false
        isParticipate = false
        isPublish = false
        isVerified = false
        isDeleted = false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case type = "type"
        case prize = "prize"
        case uploadTime = "uploadTime"
        case uploadOpenAt = "uploadOpenAt"
        case uploadCloseAt = "uploadCloseAt"
        case votingTime = "votingTime"
        case votingOpenAt = "votingOpenAt"
        case votingCloseAt = "votingCloseAt"
        case allowedVideos = "allowedVideos"
        case categories = "categories"
        case videos = "videos"
        case status = "status"
        case isParticipate = "isParticipate"
        case isPublish = "isPublish"
        case isVerified = "isVerified"
        case isDeleted = "isDeleted"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        name  = try values.decodeIfPresent(String.self, forKey: .name)
        
        type  = try values.decodeIfPresent(String.self, forKey: .type)
        prize  = try values.decodeIfPresent(Int.self, forKey: .prize)
        uploadTime  = try values.decodeIfPresent(String.self, forKey: .uploadTime)
        uploadOpenAt  = try values.decodeIfPresent(String.self, forKey: .uploadOpenAt)
        uploadCloseAt  = try values.decodeIfPresent(String.self, forKey: .uploadCloseAt)
        votingTime  = try values.decodeIfPresent(String.self, forKey: .votingTime)
        votingOpenAt  = try values.decodeIfPresent(String.self, forKey: .votingOpenAt)
        votingCloseAt  = try values.decodeIfPresent(String.self, forKey: .votingCloseAt)
        allowedVideos  = try values.decodeIfPresent(Int.self, forKey: .allowedVideos)
        categories  = try values.decodeIfPresent([CategoriesExtModel].self, forKey: .categories)
        videos  = try values.decodeIfPresent([VideosModel].self, forKey: .videos)
        
        status  = try values.decodeIfPresent(Bool.self, forKey: .status)
        isParticipate  = try values.decodeIfPresent(Bool.self, forKey: .isParticipate)
        isPublish  = try values.decodeIfPresent(Bool.self, forKey: .isPublish)
        isDeleted  = try values.decodeIfPresent(Bool.self, forKey: .isDeleted)
        isVerified  = try values.decodeIfPresent(Bool.self, forKey: .isVerified)
    }
}

class CategoriesExtModel : NSObject, Codable {
    
    var challengeId : String!
    var categoryId : String!
    var category : CategoriesModel!
    
    override init() {
        challengeId = ""
        categoryId = ""
        category = CategoriesModel()
    }
    
    private enum CodingKeys: String, CodingKey {
        case challengeId = "challengeId"
        case categoryId = "categoryId"
        case category = "category"
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        challengeId  = try values.decodeIfPresent(String.self, forKey: .challengeId)
        categoryId  = try values.decodeIfPresent(String.self, forKey: .categoryId)
        category  = try values.decodeIfPresent(CategoriesModel.self, forKey: .category)
    }
}

