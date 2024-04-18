//
//  PaymentModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class PaymentModel : NSObject, Codable {
    
    var id : String! // = CategoriesModel()
    var client_secret : String! // = CategoriesModel()
    
    override init() {
        id = ""
        client_secret = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case client_secret = "client_secret"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        client_secret  = try values.decodeIfPresent(String.self, forKey: .client_secret)
    }
}
