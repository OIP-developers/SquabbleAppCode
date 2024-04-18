//
//  GeneralResponse.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/01/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class GeneralResponse : NSObject, Codable {
    var statusCode : String!
    var message : String!
    var body : Body!
    
    override init() {
        statusCode = "0"
        message = ""
        body = Body()
    }
    private enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case message = "message"
        case body = "data"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode  = try values.decodeIfPresent(String.self, forKey: .statusCode)
        message  = try values.decodeIfPresent(String.self, forKey: .message)
        body  = try values.decodeIfPresent(Body.self, forKey: .body)
    }
}

class Body : NSObject, Codable {
    var like: String!
    var follow: String!
    var challenges : [ChallengesModel]!
    var challenge : ChallengesModel!
    var categories : [CategoriesModel]!
    var winners : [ChallengesModel]!
    var videos : [VideosModel]!
    var video : VideosModel!
    var banners : [BannersModel]!
    var subscriptions : [SubscriptionModel]!
    var payment : PaymentModel!
    var user : UserAPIModel!
    var users : [UserAPIModel]!
    var tokens : Token!
    var searchData : SearchModelNew!
    var bankData : BankModel!
    
    
    override init() {
        like = ""
        follow = ""
        challenges = [ChallengesModel]()
        challenge = ChallengesModel()
        categories = [CategoriesModel]()
        winners = [ChallengesModel]()
        videos = [VideosModel]()
        video = VideosModel()
        banners = [BannersModel]()
        subscriptions = [SubscriptionModel]()
        payment = PaymentModel()
        user = UserAPIModel()
        users = [UserAPIModel]()
        tokens = Token()
        searchData = SearchModelNew()
        bankData = BankModel()
    
    }
    
    private enum CodingKeys: String, CodingKey {
        case like = "like"
        case follow = "follow"
        case challenges = "challenges"
        case challenge = "challenge"
        case categories = "categories"
        case winners = "winners"
        case videos = "videos"
        case video = "video"
        case banners = "banners"
        case subscriptions = "subscriptions"
        case payment = "payment"
        case user = "user"
        case users = "users"
        case tokens = "tokens"
        case searchData = "data"
        case bankData = "bank"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        like  = try values.decodeIfPresent(String.self, forKey: .like)
        follow  = try values.decodeIfPresent(String.self, forKey: .follow)
        challenges  = try values.decodeIfPresent([ChallengesModel].self, forKey: .challenges)
        challenge  = try values.decodeIfPresent(ChallengesModel.self, forKey: .challenge)
        categories  = try values.decodeIfPresent([CategoriesModel].self, forKey: .categories)
        winners  = try values.decodeIfPresent([ChallengesModel].self, forKey: .winners)
        videos  = try values.decodeIfPresent([VideosModel].self, forKey: .videos)
        video  = try values.decodeIfPresent(VideosModel.self, forKey: .video)
        banners  = try values.decodeIfPresent([BannersModel].self, forKey: .banners)
        subscriptions  = try values.decodeIfPresent([SubscriptionModel].self, forKey: .subscriptions)
        payment  = try values.decodeIfPresent(PaymentModel.self, forKey: .payment)
        user  = try values.decodeIfPresent(UserAPIModel.self, forKey: .user)
        users  = try values.decodeIfPresent([UserAPIModel].self, forKey: .users)
        tokens  = try values.decodeIfPresent(Token.self, forKey: .tokens)
        searchData  = try values.decodeIfPresent(SearchModelNew.self, forKey: .searchData)
        bankData  = try values.decodeIfPresent(BankModel.self, forKey: .bankData)
    }
}

