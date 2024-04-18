//
//  UIWindowExtensions.swift
//  FansKick
//
//  Created by FansKick-Raj on 11/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

extension UIWindow {
    
    static var currentController: UIViewController? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.window?.currentController
    }
    
    var currentController: UIViewController? {
        if let vc = self.rootViewController {
            return getCurrentController(vc: vc)
        }
        return nil
    }
    
    func getCurrentController(vc: UIViewController) -> UIViewController {
        
        if let pc = vc.presentedViewController {
            return getCurrentController(vc: pc)
        }/* else if let slidePanel = vc as? MASliderViewController {
            
            return getCurrentController(vc: slidePanel.centerViewController!)
            
        }*/ else if let nc = vc as? UINavigationController {
            if nc.viewControllers.count > 0 {
                return getCurrentController(vc: nc.viewControllers.last!)
            } else {
                return nc
            }
        }
        
        else {
            return vc
        }
    }
    
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
//    public func topMostController()->UIViewController? {
//        
//        var topController = rootViewController
//        
//        while let presentedController = topController?.presentedViewController {
//            topController = presentedController
//        }
//        
//        return topController
//    }
//    
//    /** @return Returns the topViewController in stack of topMostController.    */
//    public func currentViewController()->UIViewController? {
//        
//        var currentViewController = topMostController()
//        
//        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
//            currentViewController = (currentViewController as! UINavigationController).topViewController
//        }
//        
//        return currentViewController
//    }
}
