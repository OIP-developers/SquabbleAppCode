//
//  Video.swift
//  Video
//
//  Created by PT.Koanba on 05/09/22.
//

import Foundation

public struct Video: Codable {
    public let video_id: String
    public let video_url: URL?
    public let Challange_name: String?
    public let thumbnail_url: String?
    
    public init(id: String, hlsURL: URL?, Challange_name: String, thumbnail_url: String?) {
        self.video_id = id
        self.video_url = hlsURL
        self.Challange_name = Challange_name
        self.thumbnail_url = thumbnail_url
    }
}
