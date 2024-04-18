//
//  RewardsModel.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 29/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class RewardsModel: Mappable {
   
    var video_id: String?
    var video_path: String?
    var user_id: String?
    var video_thumbnail: String?
    var is_posted: String?
    var created_at: Int?
    var created_att: String?

    var updated_at: String?
    var status: String?
    var views_count: String?
    var votes_count: String?
    var video_share_count: String?
    var challenge = ChallengeModel()
    var is_save_to_gallery: String?
    var video_text: String?
    var user_name: String?
    var user_image: String?
    var is_following: Int?
    var is_sponsered: String?
    var is_voted: Int?
    var is_voted_two_times: Int?
    var winner_views_count: String?
    var winner_votes_count: String?
    
    var player: AVPlayer?
    var isPlayed = false
    var isEnded = false
    var intro_video_id: String?
    var intro_video_path: String?
    var intro_video_thumbnail: String?
    var video_thumbnail_new: String?
    var challenge_id: String?
    var setting: String?
    var request_status: String?
    var primary_key_follow_id: String?
    var aws_video_path: String?
    var playerUrl: URL?
    var mp4_video_path: String?
    var username: String?
    var tagged_user = [TaggedUser]()
    var video_exist: Int?
    var is_prime_time: String?
    var voted_in_prime: Int?
    var is_voted_prime: Int?
    var rank: Int?
    var is_deleted: Int?
   
    init(){
    }
    
    required init?(map: Map) {
        
    }
    
    func addObserver() {
         // print(" ======== = = == = = == Observer added = == =  == = =  ")
//          NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name:
//              NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue:
        OperationQueue.main) { [weak self] notification in //1
            guard let strongSelf = self else { return } //2
         //   print(" ======== = = == = = == video ended called = == =  == = =  ")
            strongSelf.isEnded = true
            strongSelf.player?.seek(to: CMTime.zero)
            if strongSelf.isPlayed {
                strongSelf.player?.play()
            }
        }

      }
      
      func removeObserver() {
         // print(" ======== = = == = = == Observer removeObserver = == =  == = =  ")
          NotificationCenter.default.removeObserver(self)
      }
      
      deinit {
            player = nil
       // print(" ======== = = == = = == Object deinit = == =  == = =  ")
          NotificationCenter.default.removeObserver(self)
      }
      
      @objc func videoDidEnd() {
         // print(" ======== = = == = = == video ended called = == =  == = =  ")
          self.isEnded = true
          self.player?.seek(to: CMTime.zero)
          if self.isPlayed {
              self.player?.play()

          }
      }
    
    func mapping(map: Map) {
        is_deleted <- map["is_deleted"]
        video_id <- map["video_id"]
        video_path <- map["video_path"]
        user_id <- map["user_id"]
        video_thumbnail <- map["video_thumbnail"]
        is_posted <- map["is_posted"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        status <- map["status"]
        views_count <- map["views_count"]
        votes_count <- map["votes_count"]
        video_share_count <- map["video_share_count"]
        challenge <- map["challenge"]
        is_save_to_gallery <- map["is_save_to_gallery"]
        video_text <- map["video_text"]
        user_name <- map["user_name"]
        user_image <- map["user_image"]
        is_following <- map["is_following"]
        is_sponsered <- map["is_sponsered"]
        is_voted <- map["is_voted"]
        winner_views_count <- map["winner_views_count"]
        winner_votes_count <- map["winner_votes_count"]
        intro_video_id <- map["intro_video_id"]
        intro_video_path <- map["intro_video_path"]
        intro_video_thumbnail <- map["intro_video_thumbnail"]
        video_thumbnail_new <- map["video_thumbnail_new"]
        challenge_id <- map["challenge_id"]
        created_att <- map["created_at"]
        setting <- map["setting"]
        request_status <- map["request_status"]
        primary_key_follow_id <- map["primary_key_follow_id"]
        aws_video_path <- map["aws_video_path"]
        mp4_video_path <- map["mp4_video_path"]
        username <- map["username"]
        tagged_user <- map["tagged_user"]
        video_exist <- map["video_exist"]
        is_prime_time <- map["is_prime_time"]
        is_voted_two_times <- map["is_voted_two_times"]
        is_voted_prime <- map["if_prime_voted"]
        rank <- map["rank"]
    }
       
}

class TaggedUser: Mappable {
    var username: String?
    var user_id: String?
    var blocked_status: Int?
    var check_if_you_block : Int?
 
    init(){
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        user_id <- map["user_id"]
        blocked_status <- map["blocked_status"]
        check_if_you_block <- map["check_if_you_block"]
    }
    
    
}
