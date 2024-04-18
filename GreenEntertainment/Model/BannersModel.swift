//
//  BannersModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 07/02/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class BannersModel : NSObject, Codable {
    
    var id : String!
    var title : String!
    var thumbnail : String!
    var status : Bool!
    var isPublish : Bool!
    var isVerified : Bool!
    var isDeleted : Bool!
    
    override init() {
        id = ""
        title = ""
        thumbnail = ""
        status = false
        isPublish = false
        isVerified = false
        isDeleted = false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case thumbnail = "thumbnail"
        case status = "status"
        case isPublish = "isPublish"
        case isVerified = "isVerified"
        case isDeleted = "isDeleted"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        title  = try values.decodeIfPresent(String.self, forKey: .title)
        thumbnail  = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        status  = try values.decodeIfPresent(Bool.self, forKey: .status)
        isPublish  = try values.decodeIfPresent(Bool.self, forKey: .isPublish)
        isDeleted  = try values.decodeIfPresent(Bool.self, forKey: .isDeleted)
        isVerified  = try values.decodeIfPresent(Bool.self, forKey: .isVerified)
    }
}

