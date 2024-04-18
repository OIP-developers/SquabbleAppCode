
//  Alerts.swift

//
//  Created by Sierra 4 on 14/07/17.
//  Copyright © 2017 com.example. All rights reserved.


import UIKit
import SwiftMessages

typealias AlertBlock = (_ success: AlertTag) -> ()

enum Alert : String{
    case success = "Success"
    case oops = "Alert"
    case login = "Login Successfull"
    case ok = "Ok"
    case cancel = "Cancel"
    case error = "Error"
    case warning = "Warning"
}

enum Type{
    case success
    case warning
    case error
    case info
}

enum AlertTag {
    case done
    case yes
    case no
}

enum Gender {
    case male
    case female
}

class Alerts: NSObject {
    

    
    static let shared = Alerts()
    
    //MARK: - Show Alert
    func show(alert title : Alert , message : String , type : Type){

        var alertConfig = SwiftMessages.defaultConfig
        alertConfig.presentationStyle = .bottom
        alertConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        alertConfig.duration = .seconds(seconds: 4.0)
        
        let alertView = MessageView.viewFromNib(layout: .messageView)
        alertView.button?.isHidden = true
        alertView.configureDropShadow()
      //  alertView.titleLabel?.font = Fonts.Myriad.semibold.font(.large)
        alertView.bodyLabel?.text = message
//        alertView.bodyLabel?.font = Fonts.Myriad.regular.font(.medium)
        alertView.configureContent(title: title.rawValue, body: message)
        
        switch type {
        case .error:
            alertView.configureTheme(.error)
        case .info:
            alertView.configureTheme(.info)
            alertView.backgroundView.backgroundColor = .black
        case .success:
            alertView.configureTheme(.success)
            alertView.backgroundView.backgroundColor = UIColor.sucessColor()
        case .warning:
            alertView.configureTheme(.warning)
            alertView.backgroundView.backgroundColor = .black
            //alertView.backgroundView.backgroundColor = .themeRedColor()
        }
        
        alertView.titleLabel?.textColor = UIColor.white
        alertView.bodyLabel?.textColor = UIColor.white
        
        SwiftMessages.show(config: alertConfig, view: alertView)
      
    }
}

//func noDataLabel(tableView: UITableView , labelText:String) {
//
//    let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//    noDataLabel.text    = labelText
//    noDataLabel.textColor = UIColor.darkGray
//    noDataLabel.textAlignment    = .center
//    noDataLabel.font = UIFont.init(name: "\(Fonts.Myriad.regular.font(.medium))", size: 19.0)
//    tableView.backgroundView = noDataLabel
//
//}

extension UIColor{
//    class func sucessColor() -> UIColor?{
//        return UIColor(red:40.0/255.0, green:179.0/255.0, blue:227.0/255.0, alpha:1)
//    }
    
    class func sucessColor() -> UIColor?{
        return UIColor.black
    }

}

class Logs {
    
    open class func show(fileName:String = #file,
                         functionName: String = #function,
                         isLogTrue : Bool = false,
                         message: String) {
        let file = URL(fileURLWithPath: fileName).lastPathComponent
        if isLogTrue{
            NSLog("\n 🍏 👉🏻 \(file) - \(functionName) , Message: \(message)\n", 0)
        }
#if DEBUG
        print("\n 🍏 👉🏻 \(file) - \(functionName) , Message: \(message)\n")
#endif
    }
}
