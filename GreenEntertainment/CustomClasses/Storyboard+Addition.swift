//
//  Storyboard+Addition.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 04/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static var auth: UIStoryboard {
        return UIStoryboard(name: "Auth", bundle: nil)
    }
    
    static var home: UIStoryboard {
        return UIStoryboard(name: "Home", bundle: nil)
    }
    
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static var wallet: UIStoryboard {
        return UIStoryboard(name: "Wallet", bundle: nil)
    }
    
    static var settings: UIStoryboard {
        return UIStoryboard(name: "Setting", bundle: nil)
    }
    
    static var profile: UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    static var tabbar: UIStoryboard {
        return UIStoryboard(name: "Tabbar", bundle: nil)
    }
    
    static var challenge: UIStoryboard {
        return UIStoryboard(name: "Challenge", bundle: nil)
    }
    
    static var message: UIStoryboard {
        return UIStoryboard(name: "Message", bundle: nil)
    }
    
    static var video: UIStoryboard {
        return UIStoryboard(name: "Video", bundle: nil)
    }
    
    public func get<T:UIViewController>(_ identifier: T.Type) -> T? {
        let storyboardID = String(describing: identifier)
        guard let viewController = instantiateViewController(withIdentifier: storyboardID) as? T else {
            return nil
        }
        return viewController
    }
    
}






