//
//  AppUtility.swift
//  SimpleMerchantApp
//
//  Created by apple on 19/11/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import EventKit
import Kingfisher
import FirebaseDynamicLinks
import Branch



// MARK: - Short Terms
//var shared: SceneDelegate?


let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

@available(iOS 13.0, *)

//let SCENEDELEGATE = UIScene.delegate as! SceneDelegate
let KAppWhiteColor = UIColor.white
let KAppDarkGrayColor = RGBA(38, g: 50, b: 56, a: 1)
let KAppTabSelectedColor = RGBA(72, g: 36, b: 124, a: 1)
let KAppPlaceholderColor = UIColor.white
let kColorDarkBlue = RGBA(20, g: 113, b: 132, a: 1)
let KAppLightBlueTextColor = RGBA(122, g: 206, b: 220, a: 1)
let kAppBackgroundColor = RGBA( 70, g: 159, b: 220, a: 1)
let kAppNavBackgroundColor = RGBA( 32, g: 150, b: 214, a: 1)
let KAppTextBlueColor = RGBA(0, g: 150, b: 214, a: 1)
let KAppNavTitleTextColor = RGBA(0, g: 150, b: 214, a: 1)
let KAppGrayColor = RGBA(162, g: 162, b: 162, a: 1.0)
let KAppRedColor = RGBA(235, g: 36, b: 43, a: 1.0)
let KAppBlackColor = RGBA(9, g: 9, b: 9, a: 1.0)
let KAppLightGreyBackgroundColor = RGBA(224,g:225,b: 228,a:1)
let blackGradientColors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//let blackOverlayColors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.4),UIColor(red: 0, green: 0, blue: 0, alpha: 0),UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)]      //[RGBA(0,g:0,b: 0,a:0.5), RGBA(0,g:0,b: 0,a:0),RGBA(0,g:0,b: 0,a:1)]





//224, 225, 228
let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
let showLog = true
let Window_Width = UIScreen.main.bounds.size.width
let Window_Height = UIScreen.main.bounds.size.height

// MARK: - Helper functions


//func getRoundRect(_ obj : UIButton){
//    obj.layer.cornerRadius = obj.frame.size.height/2
//    obj.layer.borderColor = KAppWhiteColor.cgColor
//    obj.layer.borderWidth = obj.frame.size.width/2
//    obj.clipsToBounds = true
//}
//
//func getRoundImage(_ obj : UIImageView){
//    obj.layer.cornerRadius = obj.frame.size.height/2
//    obj.layer.borderColor = KAppWhiteColor.cgColor
//    obj.layer.borderWidth = 5
//    obj.layer.masksToBounds = true
//}

func getTextWithBadge(name: String, image: UIImage,imageAddtionalSize:CGFloat = 0) -> NSAttributedString {
      let attachment = NSTextAttachment()
               // attachment.image = UIImage(named: imageName)
                attachment.image = image
             
                let imageOffsetY:CGFloat = -3.0;
                attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 20 + imageAddtionalSize, height: 20 + imageAddtionalSize)
                let attachmentString = NSAttributedString(attachment: attachment)
                let myString = NSMutableAttributedString(string: "\(name) ")
                myString.append(attachmentString)
                return myString
  }

func getTextWithTokenImage(startString : String = "", price : String, imageAddtionalSize:CGFloat = 0, imageName: String = "ic_dollar", imageOffsetY: CGFloat = -3.0) -> NSAttributedString {
    let attachment = NSTextAttachment()
    attachment.image = UIImage(named: imageName)
  //  let imageOffsetY:CGFloat = -3.0;
    attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width + imageAddtionalSize, height: attachment.image!.size.height + imageAddtionalSize)
    let attachmentString = NSAttributedString(attachment: attachment)
    let myString = NSMutableAttributedString(string: startString)
    myString.append(attachmentString)
    myString.append(NSAttributedString(string: price))
    return myString
}

func getTextWithSquabbleImage(startString : String = "", price : String, imageAddtionalSize:CGFloat = 0, imageName: String = "ic_squab" ) -> NSAttributedString {
   let attachment = NSTextAttachment()
   attachment.image = UIImage(named: imageName)
   let imageOffsetY:CGFloat = -1.0;
   attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width + imageAddtionalSize, height: attachment.image!.size.height + imageAddtionalSize)
   let attachmentString = NSAttributedString(attachment: attachment)
   let myString = NSMutableAttributedString(string: startString)
  
   myString.append(NSAttributedString(string: price))
    myString.append(attachmentString)
   return myString
}

func getTextWithGiftImage(startString : String = "", price : String,lastString: String, imageAddtionalSize:CGFloat = 0, imageName: String = "ic_squab" ) -> NSAttributedString {
   let attachment = NSTextAttachment()
   attachment.image = UIImage(named: imageName)
   let imageOffsetY:CGFloat = -1.0;
   attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width + imageAddtionalSize, height: attachment.image!.size.height + imageAddtionalSize)
   let attachmentString = NSAttributedString(attachment: attachment)
   let myString = NSMutableAttributedString(string: startString)
  let lastString = NSMutableAttributedString(string: lastString)
   myString.append(NSAttributedString(string: price))
    myString.append(attachmentString)
    myString.append(lastString)

   return myString
}


func getViewWithTag(_ tag:NSInteger, view:UIView) -> UIView {
    return view.viewWithTag(tag)!
}

func showAlertWith(title:String, message:String, for controller:UIViewController){
    //  let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    let alert = getAlertController(title: title, message: message)
    alert.addAction(UIAlertAction.init(title:"OK", style: .default, handler: nil))
    alert.modalPresentationStyle = .fullScreen
    controller.present(alert, animated: true, completion: nil)
}
func getFontSemiBold(size:CGFloat)->UIFont{
    return  UIFont.init(name: "ProximaNovaSoft-Semibold", size: size)!
}
func getFontBold(size:CGFloat)->UIFont{
    return  UIFont.init(name: "ProximaNovaSoft-Bold", size: size)!
}
func getFontMedium(size:CGFloat)->UIFont{
    return  UIFont.init(name: "ProximaNovaSoft-Medium", size: size)!
}
func getFontRegular(size:CGFloat)->UIFont{
    return  UIFont.init(name: "ProximaNovaSoft-Regular", size: size)!
}
func getAlertController(title : String, message : String) ->  UIAlertController {
    let alertVc = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    alertVc.view.tintColor = kColorDarkBlue
    let attrs:[NSAttributedString.Key:Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): getFontMedium(size: 20),NSAttributedString.Key.foregroundColor : kColorDarkBlue]
    let hogen = NSMutableAttributedString.init(string: title, attributes: attrs)
    alertVc.setValue(hogen,forKey: "attributedTitle")
    
    let attrsM :[NSAttributedString.Key:Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): getFontRegular(size: 16),NSAttributedString.Key.foregroundColor : KAppDarkGrayColor]
    let hogenMessage = NSMutableAttributedString.init(string: message, attributes: attrsM)
    alertVc.setValue(hogenMessage,forKey: "attributedMessage")
    
    return alertVc
    
}

 func isInternetConnectionAvailable()->Bool{
    var isConnection = false
    let reachability = try! Reachability()

    reachability.whenReachable = { reachability in
        if reachability.connection == .wifi {
            print("Reachable via WiFi")
            isConnection = true
        } else {
            isConnection = true
            print("Reachable via Cellular")
        }
    }
    reachability.whenUnreachable = { _ in
        isConnection = false
        print("Not reachable")
    }
    return isConnection
  }

func validPhoneNumberForLogin(_ number: String?) -> Bool {
          let regex = "^[0-9]*$"
          return number?.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
   }

//func openGoogleMap(strSource:String, strDestination:String){
//    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//
////        UIApplication.shared.openURL(URL(string:
////            "comgooglemaps://?saddr=\(strSource)&daddr=\(strDestination)&center=\(strSource)&directionsmode=driving")!)
//        UIApplication.shared.open(URL(string:
//            "comgooglemaps://?saddr=\(strSource)&daddr=\(strDestination)&center=\(strSource)&directionsmode=driving")!, options: ["":""], completionHandler: nil)
//    } else {
//        AlertController.alert(title: "Warning", message: "Please install google map application.", buttons: ["OK"]) { (action, index) in }
//    }
//}


func dialNumber(number : String) {
    
    if let url = URL(string: "tel://\(number)"),
        UIApplication.shared.canOpenURL(url) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    } else {
        // add error message here
    }
}

//for show no data label
func noDataLabel(tableView: UITableView , labelText:String) {
    let noDataLabel = UILabel()
    noDataLabel.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
    noDataLabel.text    = labelText
    noDataLabel.textColor = UIColor.darkGray
    noDataLabel.textAlignment    = .center
    tableView.backgroundView = noDataLabel
}



func noDataLabelForDashboard(tableView: UITableView , labelText:String) {
    let noDataLabel = UILabel(frame: CGRect(x: 0, y: tableView.frame.height / 2 + 35 , width: tableView.bounds.size.width, height: 45.0))
    noDataLabel.text    = labelText
    noDataLabel.textColor = UIColor.darkGray
    noDataLabel.textAlignment    = .center
    noDataLabel.tag = 100
    
    let subViews = tableView.subviews
    for subview in subViews {
        subview.removeFromSuperview()
    }
    
    //tableView.backgroundView = noDataLabel
    tableView.addSubview(noDataLabel)
}

func chatListEmptyText(status:Bool,tableView:UITableView){
    if (status){
        tableView.setEmptyTextScreen(status: true, titleImage: "no_messages", title: "No Messages, yet.", subTitle: "No message in your inbox, yet!Start chatting with volunteers around you.", isSubTitleNeeded: true)
    }else{
        tableView.setEmptyTextScreen(status: false, titleImage: "no_messages", title: "No Messages, yet.", subTitle: "No message in your inbox, yet!Start chatting with volunteers around you.", isSubTitleNeeded: true)
        
    }
}

func currentTopViewController() -> UIViewController {
    var topVC: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
    while ((topVC?.presentedViewController) != nil) {
        topVC = topVC?.presentedViewController
    }
    return topVC!
}


func voteFormatPoints(num: Double) ->String{
    let thousandNum = num/1000
    let millionNum = num/1000000
    if num >= 1000 && num < 1000000{
        if(floor(thousandNum) == thousandNum){
            return("\(Int(thousandNum))K")
        }
        return("\(Int(thousandNum))K")
        // return("\(thousandNum.roundToPlaces(1))k")
    }
    if num > 1000000{
        if(floor(millionNum) == millionNum){
            return("\(Int(millionNum))M")
        }
        return("\(Int(millionNum))M")
        // return ("\(millionNum.roundToPlaces(1))M")
    }
    else{
        if(floor(num) == num){
            return ("\(Int(num))")
        }
        return ("\(num)")
    }
    
}


// custom log
func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    if (showLog) {
        print("\(function): \(line): \(message)")
    }
}

func presentAlert(_ titleStr : String?,msgStr : String?,controller : AnyObject?){
    DispatchQueue.main.async(execute: {
        let alert=UIAlertController(title: titleStr, message: msgStr, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil));
        
        //event handler with closure
        controller!.present(alert, animated: true, completion: nil);
    })
}

func getDateFromString(strDate: String) -> String {
    
    let fromDate = Date.init(timeIntervalSince1970: (Double(strDate)!))
    //let date = Date()
    let timePeriodFormatter = DateFormatter()
    timePeriodFormatter.dateFormat = "hh:mm a"
    
    var dateString :String = ""
    
    let timeString = timePeriodFormatter.string(from: fromDate)
    let calendar = NSCalendar.current
    if calendar.isDateInYesterday(fromDate) {
        dateString = "Yesterday"
    }else if calendar.isDateInToday(fromDate) {
        dateString = "Today"
    }else if calendar.isDateInTomorrow(fromDate) {
        dateString = "Tomorrow"
    }else {
        
        let datePeriodFormatter = DateFormatter()
        datePeriodFormatter.dateFormat = "MMM dd YYYY"
        dateString = datePeriodFormatter.string(from: fromDate)
        
    }
    return String.init(format: "%@, %@", dateString,timeString)
}
func getShortDateFromString(strDate: String) -> String {
    
    let fromDate = Date.init(timeIntervalSince1970: (Double(strDate)!))
    //let date = Date()
    let timePeriodFormatter = DateFormatter()
    timePeriodFormatter.dateFormat = "hh:mm a"
    
    var dateString :String = ""
    
    let timeString = timePeriodFormatter.string(from: fromDate)
    let calendar = NSCalendar.current
    if calendar.isDateInYesterday(fromDate) {
        dateString = "Yesterday"
    }else if calendar.isDateInToday(fromDate) {
        dateString = "Today"
    }else if calendar.isDateInTomorrow(fromDate) {
        dateString = "Tomorrow"
    }else {
        
        let datePeriodFormatter = DateFormatter()
        datePeriodFormatter.dateFormat = "MMM dd YYYY"
        dateString = datePeriodFormatter.string(from: fromDate)
        
    }
    return String.init(format: "%@, %@", dateString,timeString)
}
func getNameFromDay(dayPass : String) ->  String {
    var dayName = ""
    if dayPass == "0" {
        dayName = "Sunday"
    } else if (dayPass == "1")  {
        dayName = "Monday"
    } else if (dayPass == "2")  {
        dayName = "Tuesday"
    } else if (dayPass == "3")  {
        dayName = "Wednesday"
    } else if (dayPass == "4")  {
        dayName = "Thursday"
    } else if (dayPass == "5")  {
        dayName = "Friday"
    } else if (dayPass == "6")  {
        dayName = "Saturday"
    }
    return dayName
}

func getCurrentFormatDateOrder(strDate : String) -> String {
    if !strDate.isEmpty {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateForm = dateFormatter.date(from: strDate)
        
        if dateForm == nil {
            return ""
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss a"
            let dateString = dateFormatter.string(from: dateForm!)
            return dateString
        }
    }else {
        return ""
    }
}


func currentDateTime() -> String {
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM, HH:mm"
    return dateFormatter.string(from: currentDate)
}



func getCurrentFormatDateOrderTime(strDate : String) -> String {
    if !strDate.isEmpty {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateForm = dateFormatter.date(from: strDate)
        
        if dateForm == nil {
            return ""
        } else {
            
            //            let dateAsString = "13:15"
            //            let dateFormatter = DateFormatter()
            //            dateFormatter.dateFormat = "HH:mm"
            //
            //            let date = dateFormatter.date(from: dateAsString)
            //            dateFormatter.dateFormat = "h:mm a"
            //            let Date12 = dateFormatter.string(from: date!)
            
            
            dateFormatter.dateFormat = "h:mm a"
            let dateString = dateFormatter.string(from: dateForm!)
            return dateString
        }
    }else {
        return ""
    }
}





func getDesiredDateTimeStringFromGivenString(strPassString:String ,fromFormat:String, toFormat:String) -> String {
    
    if !strPassString.isEmpty {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        let dateForm = dateFormatter.date(from: strPassString)
        
        if dateForm == nil {
            return ""
        } else {
            
            dateFormatter.dateFormat = toFormat
            let dateString = dateFormatter.string(from: dateForm!)
            return dateString
        }
    }else {
        return ""
    }
}


func getDateFromModalString(strPassString:String ,fromFormat:String) -> Date {
    
    if !strPassString.isEmpty {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        let dateForm = dateFormatter.date(from: strPassString)
        
        if dateForm == nil {
            return Date()
        } else {
            return dateForm!
        }
    }else{
        return Date()
    }
    
}

func getReadableShortTime(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getReadableTime(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getReadableTimeWith24HourDateFormat(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter.string(from: date)
    }
    return ""
}






func getReadableDate(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getReadableDateWithYear(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getStringFromDate(date: String) -> String?{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
   
    if let myDate = dateFormatter.date(from: date) {
        dateFormatter.dateFormat = "dd MMM, YYYY"
           let somedateString = dateFormatter.string(from: myDate)
          // let goodDate = dateFormatter.stringFromDate(date)
           
           return somedateString
    }
 return ""
}

 func getReadableDateForAge(date: Date, format: String = "yyyy/MM/dd") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format//"dd MMM YYYY"
    return dateFormatter.string(from: date)
}


func getReadableDateWithYearAndTime(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM,yyyy,hh:mm a"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getReadableDateWithTime(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, hh:mm a"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getReadableDateForAge(timeStamp: String) -> String? {
    if let timeDouble = Double(timeStamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    return ""
}

func getReadableDateForAge(timeStamp: Double) -> String? {
   // if let timeDouble = timeStamp {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, YYYY"
        return dateFormatter.string(from: date)
   // }
    return ""
}

 func getDateFromTimeStamp(timeStamp : Double, format : String) -> String {
       
       let date = Date(timeIntervalSince1970: timeStamp)
       let dayTimePeriodFormatter = DateFormatter()
       dayTimePeriodFormatter.dateFormat = format
       dayTimePeriodFormatter.timeZone = TimeZone.current
       let dateString = dayTimePeriodFormatter.string(from: date)
       return dateString
   }



func getDateFromTimestamp(timestamp: String) -> Date{
    if let timeDouble = Double(timestamp){
        let date = Date(timeIntervalSince1970: timeDouble)
        return date
    }
    return Date()
}

//MARK:- NO DATA FOUND
func noDataFound(message : String,tableView: UITableView,tag: Int){
    let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.tag = tag
        noDataLabel.text          = message
        noDataLabel.textColor     = UIColor.white
        noDataLabel.textAlignment = .center
        tableView.backgroundView  = noDataLabel
        tableView.separatorStyle  = .none
}

//MARK:- NO DATA FOUND
func noDataFoundForCollectionView(message : String,collectionView: UICollectionView,tag: Int){
    let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        noDataLabel.tag = tag
        noDataLabel.text          = message
        noDataLabel.textColor     = UIColor.white
        noDataLabel.textAlignment = .center
        collectionView.backgroundView  = noDataLabel
}

//MARK:- NO DATA FOUND LABEL FOR VC
func noDataFound(message : String,viewController: UIViewController,tag: Int){
    let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        noDataLabel.tag = tag
        noDataLabel.text          = message
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
    viewController.view.addSubview(noDataLabel)
}

func getDateForInfoFromTimeStamp(strDate: String) -> String {
    
    let fromDate = Date.init(timeIntervalSince1970: (Double(strDate)!))
    
    var dateString :String = ""
    var formattedDateString : String = ""
    var prefixString : String = ""
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd"
    dateString = dateFormatter.string(from: fromDate)
    
    if(dateString == "01"  || dateString == "21" || dateString == "31"){
        prefixString = "st"
        
    } else if (dateString ==  "02" || dateString == "22"){
        prefixString = "nd"
        
    } else if (dateString == "03" || dateString == "23"){
        prefixString = "rd"
        
    }else{
        prefixString = "th"
    }
    
    let dateCompleteFormatter = DateFormatter()
    dateCompleteFormatter.dateFormat = String.init(format:"dd'%@' MMM, YYYY" , prefixString)
    formattedDateString = dateCompleteFormatter.string(from: fromDate)
    return formattedDateString
}

func getTimeFromString(strDate: String) -> String {
    
    let fromDate = Date.init(timeIntervalSince1970: (Double(strDate)!))
    let timePeriodFormatter = DateFormatter()
    timePeriodFormatter.dateFormat = "hh:mm a"
    let timeString = timePeriodFormatter.string(from: fromDate)
    return timeString
}

func getTimeFromDate(strDate: Date) -> String {
    
    let timePeriodFormatter = DateFormatter()
    timePeriodFormatter.dateFormat = "hh:mm a"
    let timeString = timePeriodFormatter.string(from: strDate)
    return timeString
}



func getAddressFromLatLon(selectedLatitude: Double, withLongitude selectedLongitude: Double) {
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    let ceo: CLGeocoder = CLGeocoder()
    center.latitude = selectedLatitude
    center.longitude = selectedLongitude
    var addressString : String = ""
    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    
    ceo.reverseGeocodeLocation(loc, completionHandler:
        {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                }
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                }
            }
    })
}

func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
    DispatchQueue.global(qos: .background).async { () -> Void in
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                eventStore.requestAccess(to: .event, completion: { (granted, error) in
                    if (granted) && (error == nil) {
                        let event = EKEvent(eventStore: eventStore)
                        event.title = title
                        event.startDate = startDate
                        event.endDate = endDate
                        event.notes = description
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        do {
                            try eventStore.save(event, span: .thisEvent)
                        } catch let e as NSError {
                            completion?(false, e)
                            return
                        }
                        completion?(true, nil)
                    } else {
                        completion?(false, error as NSError?)
                    }
                })
            })
        } else {
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = title
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = description
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let e as NSError {
                        completion?(false, e)
                        return
                    }
                    completion?(true, nil)
                } else {
                    completion?(false, error as NSError?)
                }
            })
        }
        
    }
}

func presentAlertWithOptions(_ title: String, message: String,controller : AnyObject, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert, buttons: buttons, tapBlock: tapBlock)
    controller.present(alert, animated: true, completion: nil)
    return alert
}

func delay(delay: Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func getHint(element:AnyObject) -> IndexPath {
    let accessibilityString :String = (element.accessibilityLabel as? String)!
    let accessibilityArray : Array<String> = accessibilityString.components(separatedBy: ",")
    return (accessibilityArray.count == 2) ? IndexPath(row: Int(accessibilityArray.first!)!, section: Int(accessibilityArray.last!)!) : IndexPath(row: Int(-1), section: Int(-1))
}

func convertImageToBase64(image: UIImage) -> String {
    let imageData = image.pngData()!
    return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
}



func getDateFromString(dateString : String) -> Date {
    
    if !dateString.isEmpty {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.date(from: dateString)!
    }
    
    return Date()
}

private extension UIAlertController {
    
    convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) {
        self.init(title: title, message: message, preferredStyle:preferredStyle)
        var buttonIndex = 0
        for buttonTitle in buttons {
            let action = UIAlertAction(title: buttonTitle, preferredStyle: .default, buttonIndex: buttonIndex, tapBlock: tapBlock)
            buttonIndex += 1
            self.addAction(action)
        }
    }
}

private extension UIAlertAction {
    convenience init(title: String?, preferredStyle: UIAlertAction.Style, buttonIndex:Int, tapBlock:((UIAlertAction,Int) -> Void)?) {
        
        
        self.init(title: title, style: preferredStyle) {
            (action:UIAlertAction) in
            if let block = tapBlock {
                block(action,buttonIndex)
            }
        }
    }
}

class AppUtility: NSObject {
    
    class  func leftBarButton(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControl.State())
        button.addTarget(controller, action: #selector(leftBarButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    class  func rightBarButton(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControl.State())
        button.addTarget(controller, action: #selector(rightBarButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    class  func rightBarButtonTwo(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControl.State())
        button.addTarget(controller, action: #selector(rightBarButtonTwoAction(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    
    func getChatTimeForDate(_ strDate:String?) -> String {
        if let strDate = strDate {
            let unixTimeStamp = Double(strDate)
            let date = Date(timeIntervalSince1970: unixTimeStamp!)
            
            let formatter = DateFormatter()
            formatter.locale = NSLocale.current
            formatter.dateFormat =  "h:mm a"
            return formatter.string(from: date)
        }
        return ""
    }
    
        func getCreatedDate(_ date:String?) -> String {
            
            if let date = date, date.count > 0 {
                
                let unixTimeStamp = Double(date)
                let date = Date(timeIntervalSince1970: unixTimeStamp!)
                
                let formatter = DateFormatter()
    //            formatter.timeZone = TimeZone(abbreviation: "GMT")
                formatter.locale = NSLocale.current
                formatter.dateFormat =  "MM/dd/yyyy"
                return formatter.string(from: date)
            }
            return ""
        }
    
    
    @objc   func leftBarButtonAction(_ button : UIButton) {
        
    }
    
    @objc   func rightBarButtonAction(_ button : UIButton) {
        
    }
    @objc   func rightBarButtonTwoAction(_ button : UIButton) {
        
    }
    
    
    static func createDynamicLinkWithFirebase(_ courseId:String, _ courseTitle:String, _ courseImage:String , superViewController:UIViewController,username: String) {

           guard let link = URL(string:"https://www.squabblewin.page.link/videoID=" + courseId) else {
               return
           }

           let dynamicLinksDomain = "https://squabblewin.page.link"
           let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomain)

           linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.green.squabble")
           linkBuilder?.iOSParameters?.appStoreID = "1561097344"
           linkBuilder?.iOSParameters?.minimumAppVersion = "1.0"

           linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.green.squabble")
           linkBuilder?.androidParameters?.minimumVersion = 1

           linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
           linkBuilder?.socialMetaTagParameters?.title = "Vote for \(username) on Squabble!"
           linkBuilder?.socialMetaTagParameters?.descriptionText = "It is more than a game."  //courseTitle
         //  if courseImage.count > 0 {
            if let encoded = courseImage.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
              //  linkBuilder?.socialMetaTagParameters?.imageURL = URL.init(string:encoded)
                linkBuilder?.socialMetaTagParameters?.imageURL = URL.init(string:courseImage)
            }

       //    }

//       let longUrl = linkBuilder?.url
//        let activityViewController = UIActivityViewController(activityItems: [longUrl], applicationActivities: nil)
//        superViewController.present(activityViewController, animated: true) {
//        }


           linkBuilder?.shorten(completion: { (url, warnings, error) in

               guard let url = url else { return }
               print("The short URL is: \(url)")
//            let text = "Vote for \(username) on Squabble!\nIt’s more than a game"
//            let shareAll = [text , url] as [Any]


               let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
               superViewController.present(activityViewController, animated: true) {
               }

           })

       }
    //Ratnesh
     static func createDynamicLinkWith(_ courseId:String, _ courseTitle:String, _ courseImage:String , superViewController:UIViewController,username: String) {
               
               let buo = BranchUniversalObject.init(canonicalIdentifier: "content/12345")
               buo.title = "Vote for \(username) on Squabble!"
               buo.contentDescription = "It is more than a game."
               buo.imageUrl = courseImage
               buo.publiclyIndex = true
               buo.locallyIndex = true
               buo.contentMetadata.customMetadata["key1"] = "value1"
        
        let lp: BranchLinkProperties = BranchLinkProperties()


        lp.addControlParam("video_id", withValue: courseId)
//        lp.addControlParam("look_at", withValue: "this")
//        lp.addControlParam("nav_to", withValue: "over here")
//        lp.addControlParam("random", withValue: UUID.init().uuidString)
        
                buo.getShortUrl(with: lp) { url, error in
                print(url ?? "")
                     guard let url = url else { return }
                                      print("The short URL is: \(url)")
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                      superViewController.present(activityViewController, animated: true) {
                                      }
                    
               }
        
        
//               linkBuilder?.shorten(completion: { (url, warnings, error) in
//
//                   guard let url = url else { return }
//                   print("The short URL is: \(url)")
//    //            let text = "Vote for \(username) on Squabble!\nIt’s more than a game"
//    //            let shareAll = [text , url] as [Any]
//
//
//                   let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//                   superViewController.present(activityViewController, animated: true) {
//                   }
//
//               })
               
           }
    
    
    
    //
    // http://squabble-challenge.app.link/LJzd3OTttcb
    
}


//MARK:- HexCode to UIColor
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
   
}



//

extension UIImageView {

//MARK: - Set Image from URL
func setImageFromUrl(_ url :String?, placeholder: UIImage? = UIImage()) {

    kf.indicatorType = .activity
    guard let urlTemp = URL(string: (url ?? "")) else {
        self.image = placeholder ;
        return
    }

    kf.setImage(with: urlTemp, placeholder: placeholder, options: nil, progressBlock: nil) { (error) in

        if(error != nil){
            self.kf.setImage(with: URL(string: url ?? ""), placeholder: UIImage(named: ""), options: nil)
        }else{
            print("not able to load image")
        }
    }
}
}


class Utility {

static func getDateFromTimeStamp(timeStamp : String, format : String) -> String {
    let timeStam = Double(timeStamp) ?? 0.0
    let date = Date(timeIntervalSince1970: timeStam)
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = format
    
    let dateString = dayTimePeriodFormatter.string(from: date)
    return dateString
}

static func getTodayDateIsSimilar(format : String, otherDate : String) -> Bool {
    
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = format
    let dateString = dayTimePeriodFormatter.string(from: Date())
    return dateString == otherDate
}
    
    static func getTime(_ createdAt: Int) -> String {
           let timeInterval = Int(createdAt)
           let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
           return date.getElapsedInterval()
       }
}


extension Date {
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hour ago" :
                "\(hour)" + " " + "hours ago"
        }  else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute)" + " " + "min ago" :
                "\(minute)" + " " + "mins ago"
        }  else if let second = interval.second, second > 0 {
            return second == 1 ? "\(second)" + " " + "sec ago" :
                "\(second)" + " " + "secs ago"
        } else {
            return "now"
        }
    }
}
