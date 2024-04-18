//
//  StaticModel.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 26/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class StaticModel: Mappable {
    var page_title: String?
    var content: String?
    var slug: String?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        page_title <- map["page_title"]
        content <- map["content"]
        slug <- map["slug"]
    }
    
    
}

class Badge: Mappable {
    var badge_id: String?
    var badge_thumbnail: String?
    var created_at: String?
    var order: String?
    var title: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        badge_id <- map["badge_id"]
        badge_thumbnail <- map["badge_thumbnail"]
        created_at <- map["created_at"]
        order <- map["order"]
        title <- map["title"]
    }
    
    
}


class LiveModel: Mappable {
    var encoded_token: String?
    var token: String?
    var is_admin_live: Int?
    var banner_image = [BannerModel]()
    var video_count: Int?
    

    
    
    init() {
    }
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        encoded_token <- map["encoded_token"]
        token <- map["token"]
        is_admin_live <- map["is_admin_live"]
        banner_image <- map["banner_image"]
        video_count <- map["video_count"]
        
    }
    
    
}



class BannerModel: Mappable {
    var content: String?
    var banner_image_path: String?
    var link: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        content <- map["content"]
        banner_image_path <- map["banner_image_path"]
        link <- map["link"]
    }
    
    
}
