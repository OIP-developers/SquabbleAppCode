//
//  SearchModel.swift
//  GreenEntertainment
//
//  Created by Ahsan Iqbal on 18/09/2023.
//  Copyright © 2023 Quytech. All rights reserved.
//

import Foundation

class SearchModelNew : NSObject, Codable {
    
    var challenges: [ChallengesModel]!
    var users: [UserAPIModel]!
    var videos: [VideosModel]!
    
    
    override init() {
        challenges = [ChallengesModel]()
        users = [UserAPIModel]()
        videos = [VideosModel]()
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case challenges = "challenges"
        case users = "users"
        case videos = "videos"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        challenges  = try values.decodeIfPresent([ChallengesModel].self, forKey: .challenges)
        users  = try values.decodeIfPresent([UserAPIModel].self, forKey: .users)
        videos  = try values.decodeIfPresent([VideosModel].self, forKey: .videos)
    }
}
