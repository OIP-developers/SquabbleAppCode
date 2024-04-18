//
//  CategoriesModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 19/01/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class CategoriesModelArray : NSObject, Codable {
    var category : CategoriesModel! // = CategoriesModel()
    override init() {
        category = CategoriesModel()
    }
    private enum CodingKeys: String, CodingKey {
        case category = "category"
    }
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category  = try values.decodeIfPresent(CategoriesModel.self, forKey: .category)
    }
}

class CategoriesModel : NSObject, Codable {
    
    var id : String!
    var name : String!
    var status : Bool!
    var isPublish : Bool!
    var isVerified : Bool!
    var isDeleted : Bool!
   
    override init() {
        id = ""
        name = ""
        status = false
        isPublish = false
        isVerified = false
        isDeleted = false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case status = "status"
        case isPublish = "isPublish"
        case isVerified = "isVerified"
        case isDeleted = "isDeleted"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try values.decodeIfPresent(String.self, forKey: .id)
        name  = try values.decodeIfPresent(String.self, forKey: .name)
        status  = try values.decodeIfPresent(Bool.self, forKey: .status)
        isPublish  = try values.decodeIfPresent(Bool.self, forKey: .isPublish)
        isDeleted  = try values.decodeIfPresent(Bool.self, forKey: .isDeleted)
        isVerified  = try values.decodeIfPresent(Bool.self, forKey: .isVerified)
    }
}

