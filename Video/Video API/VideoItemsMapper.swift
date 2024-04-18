//
//  VideoItemsMapper.swift
//  Video
//
//  Created by PT.Koanba on 05/09/22.
//

import Foundation

public final class VideoItemsMapper {

    private struct Root: Decodable {
        private let code, message: String
        private let data: [VideosModel] //RemoteFeedItem
        
        var videos: [VideosModel] {
                data.map({ vidMod in
                    var vidoeMod = VideosModel()
                    do {
                        try vidoeMod = VideosModel(from: vidMod as! Decoder)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    return vidoeMod
                })
            /*data.content.map { videosModel in
                videos = videosModel
                /*Video(
                    id: $0.post.medias[0].id,
                    hlsURL: $0.post.medias[0].hlsUrl, Challange_name: $0.post.medias[0].challengeName, thumbnail_url: $0.post.medias[0].thumbnail_url
                )*/
            }*/
        }
        
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [VideosModel] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteVideoLoader.Error.invalidData
        }
     
        return root.videos
    }
}
