//
//  BadgeModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 01/09/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class BadgeModel : NSObject, Codable {
    
    var title: String!
    var thumbnail: String!
    
    
    override init() {
        title = ""
        thumbnail = ""
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "title"
        case thumbnail = "thumbnail"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title  = try values.decodeIfPresent(String.self, forKey: .title)
        thumbnail  = try values.decodeIfPresent(String.self, forKey: .thumbnail)
    }
}
