//
//  BankModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 27/12/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class BankModel : NSObject, Codable {
    
    var country : String!
    var currency : String!
    var account_holder_name : String!
    var account_number : String!
    var routing_number : String!
    
    override init() {
        country = ""
        currency = ""
        account_holder_name = ""
        account_number = ""
        routing_number = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case country = "country"
        case currency = "currency"
        case account_holder_name = "account_holder_name"
        case account_number = "last4"
        case routing_number = "routing_number"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        country  = try values.decodeIfPresent(String.self, forKey: .country)
        currency  = try values.decodeIfPresent(String.self, forKey: .currency)
        account_holder_name  = try values.decodeIfPresent(String.self, forKey: .account_holder_name)
        account_number  = try values.decodeIfPresent(String.self, forKey: .account_number)
        routing_number  = try values.decodeIfPresent(String.self, forKey: .routing_number)
    }
}

