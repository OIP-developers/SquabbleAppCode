//
//  VideoLoader.swift
//  Video
//
//  Created by PT.Koanba on 05/09/22.
//

import Foundation

public protocol VideoLoader {
    typealias Result = Swift.Result<[VideosModel], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
