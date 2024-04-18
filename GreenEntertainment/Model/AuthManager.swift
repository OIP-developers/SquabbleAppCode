//
//  AuthManager.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

enum SingletonKeys : String {
    case user = "future_now_auth"
    case deviceToken = "device_token"
    case socialLogin = "social_login"
    case faceid_password = "faceid_password"
    case faceid_email = "faceid_email"
    case faceid_temp_email = "faceid_temp_email"
    case faceid_temp_password = "faceid_temp_password"
    case fcmToken = "fcmToken"
    case deviceID = "deviceID"

}

class AuthManager: NSObject{
    
    static let shared = AuthManager()
    
    var hasEventId = false
    var eventId:String?
    
    var loggedInUser : User? {
        get{
            guard let data = UserDefaults.standard.value(forKey: SingletonKeys.user.rawValue) else{
                let mappedModel = Mapper<User>().map(JSON: [:] as! [String : Any])
                return mappedModel
            }
            let mappedModel = Mapper<User>().map(JSON: data as! [String : Any])
            return mappedModel
        }
        set{
            if let value = newValue {
                UserDefaults.standard.set(value.toJSON(), forKey: SingletonKeys.user.rawValue)
                
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.user.rawValue)
            }
        }
    }
    
    var fcmToken: String? {
       get{
            return UserDefaults.standard.value(forKey: SingletonKeys.fcmToken.rawValue) as? String
        }
        set{
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SingletonKeys.fcmToken.rawValue)
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.fcmToken.rawValue)
            }
        }
    }
    
    var deviceID: String? {
         get{
               return UserDefaults.standard.value(forKey: SingletonKeys.deviceID.rawValue) as? String
           }
           set{
               if let value = newValue {
                   UserDefaults.standard.set(value, forKey: SingletonKeys.deviceID.rawValue)
               }else{
                   UserDefaults.standard.removeObject(forKey: SingletonKeys.deviceID.rawValue)
               }
           }
       }
    
    
    var deviceToken: String? {
        get{
            return UserDefaults.standard.value(forKey: SingletonKeys.deviceToken.rawValue) as? String
        }
        set{
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SingletonKeys.deviceToken.rawValue)
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.deviceToken.rawValue)
            }
        }
    }
    
    var faceid_email: String? {
        get{
            return UserDefaults.standard.value(forKey: SingletonKeys.faceid_email.rawValue) as? String
        }
        set{
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SingletonKeys.faceid_email.rawValue)
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.faceid_email.rawValue)
            }
        }
    }
    
    var faceid_temp_email: String? {
        get{
            return UserDefaults.standard.value(forKey: SingletonKeys.faceid_temp_email.rawValue) as? String
        }
        set{
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SingletonKeys.faceid_temp_email.rawValue)
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.faceid_temp_email.rawValue)
            }
        }
    }
    
    var faceid_password: String? {
        get {
            return UserDefaults.standard.value(forKey: SingletonKeys.faceid_password.rawValue) as? String
        }
        set{
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SingletonKeys.faceid_password.rawValue)
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.faceid_password.rawValue)
            }
        }
    }
    
    var faceid_temp_password: String? {
           get {
               return UserDefaults.standard.value(forKey: SingletonKeys.faceid_temp_password.rawValue) as? String
           }
           set {
               if let value = newValue {
                   UserDefaults.standard.set(value, forKey: SingletonKeys.faceid_temp_password.rawValue)
               }else{
                   UserDefaults.standard.removeObject(forKey: SingletonKeys.faceid_temp_password.rawValue)
               }
           }
       }
    
    var isSocial: Bool? {
        get {
            return UserDefaults.standard.value(forKey: SingletonKeys.socialLogin.rawValue) as? Bool
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SingletonKeys.socialLogin.rawValue)
            }else{
                UserDefaults.standard.removeObject(forKey: SingletonKeys.socialLogin.rawValue)
            }
        }
    }
    
}

