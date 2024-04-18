//
//  UserDefaultsExtension.swift
//  WashApp
//
//  Created by saurabh on 31/03/17.
//  Copyright © 2017 saurabh. All rights reserved.
//

import Foundation
import UIKit

//MARK:-
extension UserDefaults {
    
    //MARK:
    //MARK:Remove object from user defaults
    class func remove(_ key:String?){
        
        if(key != nil){
            UserDefaults.standard.removeObject(forKey: key!)
            UserDefaults.standard.synchronize()
        }
    }
    //MARK:
    //MARK:Get value from user defaults
    class func objectValue(forKey key:String?)-> Any?{
        
        if(key != nil){
        return UserDefaults.standard.object(forKey: key!) as Any
        }
        return nil
    }
    //MARK:
    //MARK:User defaults insertion/retrive/removal
    class func save(object:Any?, withKey key:String?){
        
        if(key != nil && object != nil){
            
        UserDefaults.standard.set(object!, forKey: key!)
        UserDefaults.standard.synchronize()
            
        }
    }
 
}

