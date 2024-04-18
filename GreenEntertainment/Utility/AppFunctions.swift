//
//  AppFunctions.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Friday14/08/2020.
//  Copyright © 2020 SelfIt. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialSnackbar
import RxSwift
import CoreLocation

//MARK: Globel Variables

var dateNow : Date!

var dispose_Bag = DisposeBag()

var shuffled_indices = [Int]()

func RGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}

//let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
var connectionStarted = false
let disposeBagG = DisposeBag()


//MARK: Pref Strings

let loggeduserId = "loggeduserId"
let userToken = "userToken"
let rowNum = "rowNum"
let likeVal = "likeVal"
let muteVal = "muteVal"
let chalID = "chalID"
var filterKey = ""

var videoToGo = ""
var userToGo = ""

var goneToUser = false
var goneToVideo = false

open class AppFunctions {
    
    //MARK: rx Publishers
    static let generalPublisher: PublishSubject<String> = PublishSubject()

    static let preferences = UserDefaults.standard
    
    //MARK: PREFS
    
    open class func saveChalID(id: String){
        preferences.set(id, forKey: chalID)
        preferences.synchronize()
    }
    open class func getChalID() -> String {
        var row = ""
        if preferences.object(forKey: chalID) == nil {
            Logs.show(message: "NIL getChalID")
        } else {
            row = preferences.string(forKey: chalID)!
        }
        return row
    }
    
    open class func saveUserID(id: String){
        preferences.set(id, forKey: loggeduserId)
        preferences.synchronize()
    }
    open class func getUserID() -> String {
        var row = ""
        if preferences.object(forKey: loggeduserId) == nil {
            Logs.show(message: "NIL getUserID")
        } else {
            row = preferences.string(forKey: loggeduserId)!
        }
        return row
    }
    
    
    open class func saveUserToken(id: String){
        preferences.set(id, forKey: userToken)
        preferences.synchronize()
    }
    open class func getUserToken() -> String {
        var row = ""
        if preferences.object(forKey: userToken) == nil {
            Logs.show(message: "NIL getUserToken")
        } else {
            row = preferences.string(forKey: userToken)!
        }
        return row
    }
    
    open class func saveRow(row: Int){
        preferences.set(row, forKey: rowNum)
        preferences.synchronize()
    }
    open class func getRow() -> Int {
        var row = 0
        if preferences.object(forKey: rowNum) == nil {
            Logs.show(message: "NIL getRow")
        } else {
            row = preferences.integer(forKey: rowNum)
        }
        return row
    }
    
    open class func saveLike(val: [String:Any]){
        preferences.set(val, forKey: likeVal)
        preferences.synchronize()
    }
    open class func getLike() -> [String:Any] {
        var row = [String:Any]()
        if preferences.object(forKey: likeVal) == nil {
            Logs.show(message: "NIL getLike")
        } else {
            row = preferences.dictionary(forKey: likeVal)!//integer(forKey: rowNum)
        }
        return row
    }
    
    open class func saveMute(val: Bool){
        preferences.set(val, forKey: muteVal)
        preferences.synchronize()
    }
    open class func getMute() -> Bool {
        var val = false
        if preferences.object(forKey: muteVal) == nil {
            Logs.show(message: "NIL getMute")
        } else {
            val = preferences.bool(forKey: muteVal)
        }
        return val
    }
    
   
    //MARK: Remove all data
    
    open class func resetDefaults2() {
        if let bundleID = Bundle.main.bundleIdentifier {
            AppFunctions.preferences.removePersistentDomain(forName: bundleID)
        }
    }
    
    open class func removeFromDefaults(key: String) {
        preferences.removeObject(forKey: key)
    }
    
    open class func resetDefaults() {
        let dictionary = preferences.dictionaryRepresentation()
        dictionary.keys.forEach { key in

        }
    }
    
    //MARK: JWT Token Decode
    open class func decode(jwtToken jwt: String) throws -> [String: Any] {
        
        enum DecodeErrors: Error {
            case badToken
            case other
        }
        
        func base64Decode(_ base64: String) throws -> Data {
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded) else {
                throw DecodeErrors.badToken
            }
            return decoded
        }
        
        func decodeJWTPart(_ value: String) throws -> [String: Any] {
            let bodyData = try base64Decode(value)
            let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
            guard let payload = json as? [String: Any] else {
                throw DecodeErrors.other
            }
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return try decodeJWTPart(segments[1])
    }
    
    //MARK: Base 64 Image
    open class func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
    open class func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    
    //MARK: Show SnackBar
    open class func showSnackBar(str: String) {
        let message = MDCSnackbarMessage()
        message.text = str
        MDCSnackbarManager.default.show(message)
    }
    
    //MARK: iPad Check
    open class func isIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else { return false }
    }
    
    //MARK: Others
    
    
    open class func convertDateStringFormat(originalDateString: String) -> String {
        let originalFormat = DateFormatter()
        originalFormat.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = originalFormat.date(from: originalDateString)
        
        let outputFormat = DateFormatter()
        outputFormat.dateFormat = "dd MMM, hh:mm a"
        outputFormat.timeZone = TimeZone(abbreviation: "UTC") // Setting timezone to UTC
        
        if let date = date {
            let newDateString = outputFormat.string(from: date)
            return newDateString // returns "17 Dec, 02:18 PM"
        } else {
            return ""
        }
    }

    
//    open class func colorPlaceholder(tf: UITextField, s: String) {
//        tf.attributedPlaceholder =
//            NSAttributedString(string: s, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexFromString: "E8E8E8"), .font: UIFont(name: "Poppins", size: 18)?.regular as Any])
//    }
//
    open class func calculateElapsedTime(startingPoint : Date, s:String, functionName: String) {
        //startingPointA = startingPoint
        
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        print(df.string(from: dateNow))
        let startingPointA = dateNow
        func stringFromTimeInterval(interval: TimeInterval) -> NSString {
            let ti = NSInteger(interval)
            let ms = Int((interval.truncatingRemainder(dividingBy: 1)) * 1000)
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = (ti / 3600)
            return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        }
        
        Logs.show(message:  "TIME ELAPSED in \(functionName) \(s):  \(stringFromTimeInterval(interval: startingPointA!.timeIntervalSinceNow * -1))")
    }
    
    open class func logoutUser() {
        AppFunctions.resetDefaults()
        //Database.singleton.removeCompletedDB()
        
    }
}
