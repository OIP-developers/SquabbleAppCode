//
//  SubscriptionModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class SubscriptionModel : NSObject, Codable {
    
    var id : String!
    var title : String!
    var type : String!
    var expireYears : Int!
    var expireMonths : Int!
    var expireDays : Int!
    var offerdCoin : Int!
    var price : Int!
    var actualPrice : Int!
    
    override init() {
        id = ""
        title = ""
        type = ""
        expireYears = 0
        expireMonths = 0
        expireDays = 0
        offerdCoin = 0
        price = 0
        actualPrice = 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case type = "type"
        case expireYears = "expireYears"
        case expireMonths = "expireMonths"
        case expireDays = "expireDays"
        case offerdCoin = "offerdCoin"
        case price = "price"
        case actualPrice = "actualPrice"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        title  = try values.decodeIfPresent(String.self, forKey: .title)
        type  = try values.decodeIfPresent(String.self, forKey: .type)
        expireYears  = try values.decodeIfPresent(Int.self, forKey: .expireYears)
        expireMonths  = try values.decodeIfPresent(Int.self, forKey: .expireMonths)
        expireDays  = try values.decodeIfPresent(Int.self, forKey: .expireDays)
        expireDays  = try values.decodeIfPresent(Int.self, forKey: .expireDays)
        offerdCoin  = try values.decodeIfPresent(Int.self, forKey: .offerdCoin)
        price  = try values.decodeIfPresent(Int.self, forKey: .price)
        actualPrice  = try values.decodeIfPresent(Int.self, forKey: .actualPrice)
    }
}

