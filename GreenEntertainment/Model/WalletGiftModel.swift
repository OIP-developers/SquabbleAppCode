//
//  WalletGiftModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 25/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation
class WalletModel : NSObject, Codable {
    
    var id : String! // = CategoriesModel()
    var coins: Int!
    var gifts: Int!
    
    override init() {
        id = ""
        coins = 0
        gifts = 0
       
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case coins = "coins"
        case gifts = "gifts"
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        coins  = try values.decodeIfPresent(Int.self, forKey: .coins)
        gifts  = try values.decodeIfPresent(Int.self, forKey: .gifts)
    }
}
