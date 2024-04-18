//
//  UIDeviceExtension.swift
//  WashApp
//
//  Created by saurabh on 31/03/17.
//  Copyright © 2017 saurabh. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Extension To Get Device Name
//MARK:-

extension UIDevice {
    
    @nonobjc class var device_token_ios_voip:String?{
        get{
            return UserDefaults.objectValue(forKey: UserDefaultsKey.device_token_ios_voip) as? String
        }
        set{
            if let newV = newValue{
                UserDefaults.save(object: newV, withKey: UserDefaultsKey.device_token_ios_voip)
            }
        }
    }
    
    
    @nonobjc class var deviceToken:String?{
        get{
            return UserDefaults.objectValue(forKey: UserDefaultsKey.deviceTokenn) as? String
        }
        set{
            if let newV = newValue{
                UserDefaults.save(object: newV, withKey: UserDefaultsKey.deviceTokenn)
            }
        }
    }
    @nonobjc class var deviceUUID:String{
        
        if let deviceId = UserDefaults.objectValue(forKey: UserDefaultsKey.deviceId) as? String{
            return deviceId
        }
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.save(object: deviceId, withKey: UserDefaultsKey.deviceId)
        return deviceId
    }
    
    @nonobjc class var deviceType:String{
        
        return "2"
    }
    
    @nonobjc class var modelNameMachine: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafeMutablePointer(to: &systemInfo.machine) { ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
    }
    @nonobjc class var modelNameHumanReadable:String{
        if let modelName = self.modelNameMachine{
            
            return modelNameString(modelName)
        }
        return "iPhone"
    }
    
    class private func modelNameString(_ identifier:String)->String{
        
        switch identifier {
            
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
            
        }
    }
    //MARK:- Set Orientation for Device
    class func setDeviceOrientation(_ orientation:UIDeviceOrientation){
        
//        UIApplication.setStatusBarOrientation(orientation)
        self.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}
