//
//  Webservices.swift
//  FutureNow
//
//  Created by MacMini-iOS on 18/07/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import ObjectMapper

enum WebServices { }

extension NSError {
    
    convenience init(localizedDescription : String) {
        self.init(domain: "AppNetworkingError", code: 0, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
    
    convenience init(code : Int, localizedDescription : String) {
        self.init(domain: "AppNetworkingError", code: code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
}

// MARK:
// --- User Management APIs --- //
extension WebServices {
    
        static func signup( params: [String: Any], files: [AttachmentInfo], successCompletion: ((ResponseData<User>?)-> Void)? ) {
            /*\AppNetworking.UPLOAD(endPoint: EndPoint.registration.path, parameters: params, headers: [:], files: files, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):
                    AlertController.alert(title: "", message:  message ?? "")
                    break
                }
            }*/
        }
    
    
    static func login( params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.login.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }

    static func verifyOTP( params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.registerVerifyOtp.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")


                break
            }
        }*/
    }
    
    
    static func forget_password( params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.forget_password.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")


                break
            }
        }*/
    }
    
   static func reset_password( params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.reset_password.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")


                break
            }
        }*/
    }
    static func change_password( params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.change_password.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")


                   break
               }
           }*/
       }
       

    
    static func resendOTP(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.resendOtp.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    
    static func editProfile( params: [String: Any], files: [AttachmentInfo], successCompletion: ((ResponseData<User>?)-> Void)? ) {
        /*\AppNetworking.UPLOAD(endPoint: EndPoint.edit_user_profile.path, parameters: params, headers: [:], files: files, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func getStaticContent(params: [String: Any], successCompletion: ((ResponseData<StaticModel>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.fetch_content.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<StaticModel>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func updateExistingEmail(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
              /*\AppNetworking.POST(endPoint: EndPoint.update_existing_email.path, parameters: params, loader: true) {  (response) in
                  switch response {
                  case .success(let value):
                      let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                      successCompletion?(response)
                      break
                  case .failure(let message):

                      AlertController.alert(title: "", message:  message ?? "")

                      break
                  }
              }*/
          }
    
    
   
    static func logout(successCompletion: ((ResponseData<Initial>?)-> Void)?){
         /*\AppNetworking.GET(endPoint: EndPoint.logout.path, loader: true) {  (response) in
             switch response {
             case .success(let value):
                 let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                 successCompletion?(response)
                 break
             case .failure(let message):
                 AlertController.alert(title: "", message:  message ?? "")
                 break
             }
         }*/
     }
    
    
    
    static func getUserProfile(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
          /*\AppNetworking.POST(endPoint: EndPoint.view_user_profile.path, parameters: params, loader: false) {  (response) in
              switch response {
              case .success(let value):
                  let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                  successCompletion?(response)
                  break
              case .failure(let message):

                  AlertController.alert(title: "", message:  message ?? "")

                  break
              }
          }*/
      }
    
    static func getFollowerFollowing(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.get_followers_followings.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    
    static func getMyRewards(params: [String: Any], successCompletion: ((ResponseData<RewardsModel>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.my_rewards.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func claimRewards(params: [String: Any], successCompletion: ((ResponseData<RewardsModel>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.claim_reward.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")
                
                break
                           }
                       }*/
        }

    static func getChallengesList( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.get_challenge_list.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func getNotificationSetting(successCompletion: ((ResponseData<NotificationSetting>?)-> Void)?){
        /*\AppNetworking.GET(endPoint: EndPoint.notification_setting.path, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<NotificationSetting>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func updateNotificationSetting(params: [String: Any], successCompletion: ((ResponseData<NotificationSetting>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.update_notification_setting.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                print(value ?? "")
                let response = Mapper<ResponseData<NotificationSetting>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func submitFeedback(params: [String: Any], successCompletion: ((ResponseData<NotificationSetting>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.contact_us.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<NotificationSetting>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func submitUserSuggestion(params: [String: Any], successCompletion: ((ResponseData<NotificationSetting>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.user_suggestion.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<NotificationSetting>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    
    static func getUsersList(successCompletion: ((ResponseData<User>?)-> Void)?){
           /*\AppNetworking.GET(endPoint: EndPoint.users.path, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):
                   AlertController.alert(title: "", message:  message ?? "")
                   break
               }
           }*/
       }
    
    
    
    static func sendInvite(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.send_invite.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func shareVideo(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.share_video.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    static func increaseViewCount(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.increase_view_count_video.path, parameters: params, loader: false) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func vote(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
              /*\AppNetworking.POST(endPoint: EndPoint.vote_video.path, parameters: params, loader: false) {  (response) in
                  switch response {
                  case .success(let value):
                      let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                      successCompletion?(response)
                      break
                  case .failure(let message):

                      AlertController.alert(title: "", message:  message ?? "")

                      break
                  }
              }*/
          }
    
    
    static func getChallengeVideoList(params: [String: Any], loadMore: Bool = true, successCompletion: ((ResponseData<RewardsModel>?)-> Void)?){
              /*\AppNetworking.POST(endPoint: EndPoint.trending_general_following.path, parameters: params, loader: loadMore) {  (response) in
                  switch response {
                  case .success(let value):
                      let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                      successCompletion?(response)
                      break
                  case .failure(let message):

                      AlertController.alert(title: "", message:  message ?? "")

                      break
                  }
              }*/
          }
       
    
    static func searchUser(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.find_friends.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func searchFollowUser(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.search_followings.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    static func searchChallenge(params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.search_challenge.path, parameters: params, loader: false) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func globalSearch(params: [String: Any], successCompletion: ((ResponseData<SearchModel>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.search_challenge.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<SearchModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    
    
    
    static func followUnfollowUser(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.follow_user.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func getGalleryList(successCompletion: ((ResponseData<RewardsModel>?)-> Void)?){
             /*\AppNetworking.GET(endPoint: EndPoint.app_gallery.path, loader: true) {  (response) in
                 switch response {
                 case .success(let value):
                     let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                     successCompletion?(response)
                     break
                 case .failure(let message):
                     AlertController.alert(title: "", message:  message ?? "")
                     break
                 }
             }*/
         }
    
    static func donateMoneyToUser(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.donate_money_to_user.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func sendmessage( params: [String: Any], files: [AttachmentInfo], successCompletion: ((ResponseData<Chat>?)-> Void)? ) {
           /*\AppNetworking.UPLOAD(endPoint: EndPoint.send_message.path, parameters: params, headers: [:], files: files, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<Chat>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):
                   AlertController.alert(title: "", message:  message ?? "")
                   break
               }
           }*/
       }
    
    static func deleteChatMessages(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.delete_chat_messages.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func deleteNotification(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
            /*\AppNetworking.POST(endPoint: EndPoint.delete_notification.path, parameters: params, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):

                    AlertController.alert(title: "", message:  message ?? "")

                    break
                }
            }*/
        }
    static func clearNotification(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
            /*\AppNetworking.POST(endPoint: EndPoint.clear_notification.path, parameters: params, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):

                    AlertController.alert(title: "", message:  message ?? "")

                    break
                }
            }*/
        }
    
    static func getNotification(params: [String: Any],successCompletion: ((ResponseData<NotificationModel>?)-> Void)?){
            /*\AppNetworking.POST(endPoint: EndPoint.notifications.path, parameters: params, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    let response = Mapper<ResponseData<NotificationModel>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):
                    AlertController.alert(title: "", message:  message ?? "")
                    break
                }
            }*/
        }
    
    //get chat list
    
    static func getChatList( successCompletion: ((ResponseData<Chat>?)-> Void)?) {
        /*\AppNetworking.GET(endPoint: EndPoint.view_users_list.path) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Chat>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message: message ?? "")
                break
            }
        }*/
    }
    
    
    static func getChatHistory( params: [String: Any], successCompletion: ((ResponseData<Chat>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.view_message.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Chat>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
//
    //save video
    static func saveVideo( params: [String: Any], files: [AttachmentInfo], successCompletion: ((ResponseData<Initial>?)-> Void)? ) {
        /*\AppNetworking.UPLOAD(endPoint: EndPoint.save_video_file.path, parameters: params, headers: [:], files: files, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    
    //challenge list
    static func getChallengesName(successCompletion: ((ResponseData<HomeModel>?)-> Void)?){
        /*\AppNetworking.GET(endPoint: EndPoint.challenge_name_list.path, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func postVideoToChallenge( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.post_video_challenge.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func participateToChallenge( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.participate_challenge.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func saveVideoToGallery( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.save_video_to_gallery.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func fetchChallenege( params: [String: Any], successCompletion: ((ResponseData<RewardsModel>?)-> Void)?){
            /*\AppNetworking.POST(endPoint: EndPoint.fetch_challenge_data.path, parameters: params, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):
                    AlertController.alert(title: "", message:  message ?? "")
                    break
                }
            }*/
        }
    
    static func getLeaderBoard(successCompletion: ((ResponseData<HomeModel>?)-> Void)?){
             /*\AppNetworking.GET(endPoint: EndPoint.get_leader_board.path, loader: true) {  (response) in
                 switch response {
                 case .success(let value):
                     let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                     successCompletion?(response)
                     break
                 case .failure(let message):
                     AlertController.alert(title: "", message:  message ?? "")
                     break
                 }
             }*/
         }
    
    static func getCounts(successCompletion: ((ResponseData<Initial>?)-> Void)?){
        /*\AppNetworking.GET(endPoint: EndPoint.unread_counts.path, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func readNotification( params: [String: Any], successCompletion: ((ResponseData<RewardsModel>?)-> Void)?){
              /*\AppNetworking.POST(endPoint: EndPoint.mark_read_notification.path, parameters: params, loader: true) {  (response) in
                  switch response {
                  case .success(let value):
                      let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                      successCompletion?(response)
                      break
                  case .failure(let message):
                      AlertController.alert(title: "", message:  message ?? "")
                      break
                  }
              }*/
          }
    
    
    // Wallet
    static func addMoneyToWallet(params: [String: Any], loader: Bool = true, successCompletion: ((ResponseData<User>?)-> Void)?){
                 /*\AppNetworking.POST(endPoint: EndPoint.add_money_to_wallet.path, parameters: params, loader: loader) {  (response) in
                     switch response {
                     case .success(let value):
                         let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                         successCompletion?(response)
                         break
                     case .failure(let message):

                         AlertController.alert(title: "", message:  message ?? "")

                         break
                     }
                 }*/
             }
    
    // Get Wallet coin list
    static func getCoinList( successCompletion: ((ResponseData<CoinListModel>?)-> Void)?) {
        /*\AppNetworking.GET(endPoint: EndPoint.topup_coins_value.path) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<CoinListModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                Alerts.shared.show(alert: .oops, message: message ?? "", type: .info)
                break
            }
        }*/
    }
    
    static func getAccountDetail(successCompletion: ((ResponseData<BankInfo>?)-> Void)?) {
        /*\AppNetworking.GET(endPoint: EndPoint.user_bank_info.path,loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<BankInfo>>().map(JSONObject:value)
                successCompletion?(response)
                break
           
            case .failure(let message):
                Alerts.shared.show(alert: .oops, message: message ?? "", type: .info)
                break
            }
        }*/
    }
    
    static func filterTransaction(params: [String: Any], successCompletion: ((ResponseData<Account>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.filter_transaction.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Account>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func getAccountBalance(successCompletion: ((ResponseData<Initial>?)-> Void)?){
         /*\AppNetworking.GET(endPoint: EndPoint.user_balance.path, loader: false) {  (response) in
             switch response {
             case .success(let value):
                 let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                 successCompletion?(response)
                 break
             case .failure(let message):
                 AlertController.alert(title: "", message:  message ?? "")
                 break
             }
         }*/
     }
       
       
    static func getBadgeList(successCompletion: ((ResponseData<Badge>?)-> Void)?){
        /*\AppNetworking.GET(endPoint: EndPoint.user_badge_list.path, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Badge>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func clainBadge(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
         /*\AppNetworking.POST(endPoint: EndPoint.claim_badge.path, parameters: params, loader: false) {  (response) in
             switch response {
             case .success(let value):
                 let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                 successCompletion?(response)
                 break
             case .failure(let message):

                 AlertController.alert(title: "", message:  message ?? "")

                 break
             }
         }*/
     }
    
    static func checkLiveStatus(params: [String: Any], loader: Bool = true, successCompletion: ((ResponseData<Initial>?)-> Void)?){
         /*\AppNetworking.POST(endPoint: EndPoint.live_streaming_check.path, parameters: params, loader: loader) {  (response) in
             switch response {
             case .success(let value):
                 let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                 successCompletion?(response)
                 break
             case .failure(let message):

                 AlertController.alert(title: "", message:  message ?? "")

                 break
             }
         }*/
     }
    
    static func updateLiveStatus(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.livestream_view.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func getClientSecretKey(params: [String: Any], successCompletion: ((ResponseData<ClientSecret>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.getClientSecretKey.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<ClientSecret>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    static func getEmpheralKey( params: [String: Any], successCompletion: ((ResponseData<ClientSecret>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.get_ephemeral_key.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<ClientSecret>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func addBankAccount( params: [String: Any], successCompletion: ((ResponseData<Bank>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.add_new_bank.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Bank>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func updateBankAccount( params: [String: Any], successCompletion: ((ResponseData<Bank>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.update_bank_account.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Bank>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    
    static func getBankList(successCompletion: ((ResponseData<Bank>?)-> Void)?){
        /*\AppNetworking.GET(endPoint: EndPoint.bank_list.path, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Bank>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func deleteBank(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.delete_bank.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func deleteBankAcc(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.delete_bankAcc.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func withdrawFromBank(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
          /*\AppNetworking.POST(endPoint: EndPoint.withdraw_money_bank.path, parameters: params, loader: true) {  (response) in
              switch response {
              case .success(let value):
                  let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                  successCompletion?(response)
                  break
              case .failure(let message):

                  AlertController.alert(title: "", message:  message ?? "")

                  break
              }
          }*/
      }
    
    static func deleteVideo( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.delete_video.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func deleteTrophyVideo( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.delete_trophy_video.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func removeVideo( params: [String: Any], successCompletion: ((ResponseData<HomeModel>?)-> Void)?) {
           /*\AppNetworking.POST(endPoint: EndPoint.remove_video_challenge.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<HomeModel>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):
                   AlertController.alert(title: "", message:  message ?? "")
                   break
               }
           }*/
       }
    
    static func editVideoCaption( params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?) {
            /*\AppNetworking.POST(endPoint: EndPoint.edit_video_caption.path, parameters: params, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):
                    AlertController.alert(title: "", message:  message ?? "")
                    break
                }
            }*/
        }
    
    static func getVideoDetail( params: [String: Any], successCompletion: ((ResponseData<RewardsModel>?)-> Void)?) {
            /*\AppNetworking.POST(endPoint: EndPoint.video_detail.path, parameters: params, loader: true) {  (response) in
                switch response {
                case .success(let value):
                    print(value ?? "")
                    let response = Mapper<ResponseData<RewardsModel>>().map(JSONObject:value)
                    successCompletion?(response)
                    break
                case .failure(let message):
                    AlertController.alert(title: "", message:  message ?? "")
                    break
                }
            }*/
        }
    
    static func getAdminLiveStatus( params: [String: Any], successCompletion: ((ResponseData<LiveModel>?)-> Void)?) {
               /*\AppNetworking.GET(endPoint: EndPoint.is_admin_live.path, parameters: params, loader: false) {  (response) in
                   switch response {
                   case .success(let value):
                       let response = Mapper<ResponseData<LiveModel>>().map(JSONObject:value)
                       successCompletion?(response)
                       break
                   case .failure(let message):
                       AlertController.alert(title: "", message:  message ?? "")
                       break
                   }
               }*/
           }
    
    static func getAccountSetting( params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?) {
        /*\AppNetworking.GET(endPoint: EndPoint.user_account_settings.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func updateAccountSetting( params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?) {
        /*\AppNetworking.POST(endPoint: EndPoint.update_user_account_settings.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                AlertController.alert(title: "", message:  message ?? "")
                break
            }
        }*/
    }
    
    static func acceptRejectRequest(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
              /*\AppNetworking.POST(endPoint: EndPoint.accept_reject.path, parameters: params, loader: true) {  (response) in
                  switch response {
                  case .success(let value):
                      let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                      successCompletion?(response)
                      break
                  case .failure(let message):

                      AlertController.alert(title: "", message:  message ?? "")

                      break
                  }
              }*/
          }
    
    static func getRequestNotificationList(params: [String: Any], successCompletion: ((ResponseData<NotificationModel>?)-> Void)?){
               /*\AppNetworking.POST(endPoint: EndPoint.get_request_notification_list.path, parameters: params, loader: true) {  (response) in
                   switch response {
                   case .success(let value):
                       let response = Mapper<ResponseData<NotificationModel>>().map(JSONObject:value)
                       successCompletion?(response)
                       break
                   case .failure(let message):

                       AlertController.alert(title: "", message:  message ?? "")

                       break
                   }
               }*/
           }
    
    static func deleteRequest(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
               /*\AppNetworking.POST(endPoint: EndPoint.delete_request.path, parameters: params, loader: true) {  (response) in
                   switch response {
                   case .success(let value):
                       let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                       successCompletion?(response)
                       break
                   case .failure(let message):

                       AlertController.alert(title: "", message:  message ?? "")

                       break
                   }
               }*/
           }
    
    static func badgeUpdate(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.badge_update.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                
                AlertController.alert(title: "", message:  message ?? "")
                
                break
            }
        }*/
    }
    
    static func reportVideo(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.reportvideo.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func blockUnblockUser(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
           /*\AppNetworking.POST(endPoint: EndPoint.block_unblock_user.path, parameters: params, loader: true) {  (response) in
               switch response {
               case .success(let value):
                   let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                   successCompletion?(response)
                   break
               case .failure(let message):

                   AlertController.alert(title: "", message:  message ?? "")

                   break
               }
           }*/
       }
    
    static func getBlockedUsers(params: [String: Any], successCompletion: ((ResponseData<User>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.blocked_user_list.path, parameters: params, loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):

                AlertController.alert(title: "", message:  message ?? "")

                break
            }
        }*/
    }
    
    static func getTokenWithdrawValue(successCompletion: ((ResponseData<TokenModel>?)-> Void)?) {
        /*\AppNetworking.GET(endPoint: EndPoint.token_withdraw_value.path,loader: true) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<TokenModel>>().map(JSONObject:value)
                successCompletion?(response)
                break
           
            case .failure(let message):
                Alerts.shared.show(alert: .oops, message: message ?? "", type: .info)
                break
            }
        }*/
    }
    static func updateParticipateStatus(params: [String: Any], loader: Bool = true, successCompletion: ((ResponseData<User>?)-> Void)?){
                 /*\AppNetworking.POST(endPoint: EndPoint.tc_show.path, parameters: params, loader: !loader) {  (response) in
                     switch response {
                     case .success(let value):
                         let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                         successCompletion?(response)
                         break
                     case .failure(let message):

                         AlertController.alert(title: "", message:  message ?? "")

                         break
                     }
                 }*/
             }
    static func addGiftToWallet(params: [String: Any], loader: Bool = true, successCompletion: ((ResponseData<User>?)-> Void)?){
                 /*\AppNetworking.POST(endPoint: EndPoint.gift_purchase.path, parameters: params, loader: loader) {  (response) in
                     switch response {
                     case .success(let value):
                         let response = Mapper<ResponseData<User>>().map(JSONObject:value)
                         successCompletion?(response)
                         break
                     case .failure(let message):

                         AlertController.alert(title: "", message:  message ?? "")

                         break
                     }
                 }*/
             }
    
    static func updateAppTime(params: [String: Any], successCompletion: ((ResponseData<DataApptimeid>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.user_app_time.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<DataApptimeid>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                //AlertController.alert(title: "", message:  message ?? "")
                
                break
            }
        }*/
    }
    
    static func updateAppCount(params: [String: Any], successCompletion: ((ResponseData<Initial>?)-> Void)?){
        /*\AppNetworking.POST(endPoint: EndPoint.user_app_download.path, parameters: params, loader: false) {  (response) in
            switch response {
            case .success(let value):
                let response = Mapper<ResponseData<Initial>>().map(JSONObject:value)
                successCompletion?(response)
                break
            case .failure(let message):
                //AlertController.alert(title: "", message:  message ?? "")
                
                break
            }
        }*/
    }
    
}
