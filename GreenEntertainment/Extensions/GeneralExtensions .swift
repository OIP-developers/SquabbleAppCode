//
//  GeneralExtensions.swift
//  Template
//
//  Created by apple on 19/11/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()


//MARK:- NSMutable data extension
extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

extension Data {
    var toBytes: [UInt8] {
        return [UInt8](self)
    }
}

extension Array where Element == UInt8 {
    var toData: Data {
        return Data(self)
    }
}

extension UIImageView {
	
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        // check for cache
        if let cachedImage = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    self.image = UIImage.init(named: "placeholder")
                    return
            }
            DispatchQueue.main.async() { () -> Void in
                imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
}

class PaddingLabel: UILabel {

   @IBInspectable var topInset: CGFloat = 5.0
   @IBInspectable var bottomInset: CGFloat = 5.0
   @IBInspectable var leftInset: CGFloat = 5.0
   @IBInspectable var rightInset: CGFloat = 5.0

   override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
   }

   override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}


// MARK:- NSUserDefaults Extensions >>>>>>>>>>>>>>>>>>>>>>
extension UserDefaults {
    
    func colorForKey(_ key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(_ color: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }
}

//MARK:- UIImage Extensions>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
extension UIImage {
    func maskWithColor(_ color: UIColor) -> UIImage? {
    let maskImage = self.cgImage
    let width = self.size.width
    let height = self.size.height
    let bounds = CGRect(x: 0, y: 0, width: width, height: height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) //needs rawValue of bitmapInfo
    bitmapContext!.clip(to: bounds, mask: maskImage!)
    bitmapContext!.setFillColor(color.cgColor)
    bitmapContext!.fill(bounds)//is it nil?
    if let cImage = bitmapContext!.makeImage() {
        let coloredImage = UIImage(cgImage: cImage)
        return coloredImage
    } else {
        return nil
    }
    }
}
extension UIColor{
	
	class func  RGB(r:CGFloat,g:CGFloat,b:CGFloat, alpha:CGFloat) -> UIColor{
		
		return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
	}
}

extension UISearchBar {
    func removeBackgroundImageView(){
        if let view:UIView = self.subviews.first {
            for curr in view.subviews {
                guard let searchBarBackgroundClass = NSClassFromString("UISearchBarBackground") else {
                    return
                }
                if curr.isKind(of:searchBarBackgroundClass){
                    if let imageView = curr as? UIImageView{
                        imageView.removeFromSuperview()
                        break
                    }
                }
            }
        }
    }
}

// MARK:- Array Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Array {
    func contains<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

// MARK:- Dictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
extension Dictionary {
	func merge(dict: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
		var mutableCopy = self
		for (key, value) in dict {
			// If both dictionaries have a value for same key, the value of the other dictionary is used.
			mutableCopy[key] = value
		}
		return mutableCopy
	}
}
extension Dictionary {
    mutating func unionInPlace(
        _ dictionary: Dictionary<Key, Value>) {
            for (key, value) in dictionary {
                self[key] = value
            }
    }
    
    mutating func unionInPlace<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key,Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
    
    func validatedValue(_ key: Key, expected: AnyObject) -> AnyObject {
        
        // checking if in case object is nil

        if let object = self[key] as? AnyObject{
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if (object.isKind(of: expected.classForCoder) == false) {
                //logInfo("case // checking if object is of desired class....not")
                
                return expected
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    //logInfo("null string")
                    return "" as AnyObject
                }
            }
            
            return object
        }
        else {

            if expected is String || expected as! String == "" {
             return "" as AnyObject
            }
            
            return expected
        }
    }
   
}

// MARK:- NSDictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension NSDictionary {
    
    func objectForKeyNotNull(_ key:AnyObject, expected:AnyObject?) -> AnyObject {
        
        // checking if in case object is nil
        if let object = self.object(forKey: key) {
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if ((object as AnyObject).isKind(of: (expected?.classForCoder)!) == false) {
                
                //logInfo("case // checking if object is of desired class....not")
                
                return expected!
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    
                    //logInfo("null string")
                    
                    return "" as AnyObject
                }
            }
            return object as AnyObject
            
        } else {
            
            if expected is String || expected as! String == "" {
                return "" as AnyObject
            }
            
            return expected!
        }
    }
    
    func objectForKeyNotNull(_ key:AnyObject) -> AnyObject {
        
        let object = self.object(forKey: key)
        
        if object is NSNull {
            return "" as AnyObject
        }
        
        if (object == nil) {
            return "" as AnyObject
        }
        
        if object is NSString {
            if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                return "" as AnyObject
            }
        }
        return object! as AnyObject
    }
    
    func objectForKeyNotNullExpectedObj(_ key:AnyObject, expectedObj:AnyObject) -> AnyObject {
        
        let object = self.object(forKey: key)
        
        if object is NSNull {
            return expectedObj
        }
        
        if (object == nil) {
            return expectedObj
        }
        
        if (((object as AnyObject).isKind(of: expectedObj.classForCoder)) == false) {
            return expectedObj
        }
        
        return object! as AnyObject
    }
}

// MARK:- UIView Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

/*
@IBDesignable
extension UIView {
    
        @IBInspectable var borderWidth: CGFloat {
            get {
                return layer.borderWidth
            }
            set {
                layer.borderWidth = newValue
            }
        }
//        
//        @IBInspectable var borderColor: UIColor? {
//        get {
//            return layer.borderColor as? UIColor
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
//    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    
    func shadow(_ color:UIColor) {
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
    
    func setNormalRoundedShadow(_ color:UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
    }
    
    func setBorder(_ color:UIColor, borderWidth:CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
    func vibrate() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.02
        animation.repeatCount = 2
        animation.speed = 0.5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 2.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 2.0, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    func shake() {
        self.transform = CGAffineTransform(translationX: 5, y: 5)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    func setTapperTriangleShape(_ color:UIColor) {
        // Build a triangular path
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0,y: 0))
        path.addLine(to: CGPoint(x: 40,y: 40))
        path.addLine(to: CGPoint(x: 0,y: 100))
        path.addLine(to: CGPoint(x: 0,y: 0))
        
        // Create a CAShapeLayer with this triangular path
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        
        // Mask the view's layer with this shape
        self.layer.mask = mask
        
        self.backgroundColor = color
        
        // Transform the view for tapper shape
        self.transform = CGAffineTransform(rotationAngle: CGFloat(270) * CGFloat(M_PI_2) / 180.0)
    }
}

*/



extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
          
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
           let layoutManager = NSLayoutManager()
           let textContainer = NSTextContainer(size: CGSize.zero)
           let textStorage = NSTextStorage(attributedString: label.attributedText!)

           // Configure layoutManager and textStorage
           layoutManager.addTextContainer(textContainer)
           textStorage.addLayoutManager(layoutManager)

           // Configure textContainer
           textContainer.lineFragmentPadding = 0.0
           textContainer.lineBreakMode = label.lineBreakMode
           textContainer.maximumNumberOfLines = label.numberOfLines
           let labelSize = label.bounds.size
           textContainer.size = labelSize

           // Find the tapped character location and compare it to the specified range
          let locationOfTouchInLabel = self.location(in: label)
        
           
        
           let textBoundingBox = layoutManager.usedRect(for: textContainer)
           //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                                 //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
           let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

           //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                           // locationOfTouchInLabel.y - textContainerOffset.y);
           let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
           let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
           return NSLocationInRange(indexOfCharacter, targetRange)
       }
}


// MARK:- UISlider Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UISlider {
    @IBInspectable var thumbImage: UIImage {
        get {
            return self.thumbImage(for: UIControl.State())!
        }
        set {
            self.setThumbImage(newValue, for: UIControl.State())
        }
    }
}


// MARK:- NSURL Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension URL {
    
    func isValid() -> Bool {
        if UIApplication.shared.canOpenURL(self) == true {
            return true
        } else {
            return false
        }
    }
    /// Adds the scheme prefix to a copy of the receiver.
    func convertToRedirectURL(scheme: String) -> URL? {
        var components = URLComponents.init(url: self, resolvingAgainstBaseURL: false)
        let schemeCopy = components?.scheme ?? ""
        components?.scheme = schemeCopy + scheme
        return components?.url
    }
    
    /// Removes the scheme prefix from a copy of the receiver.
    func convertFromRedirectURL(prefix: String) -> URL? {
        guard var comps = URLComponents(url: self, resolvingAgainstBaseURL: false) else {return nil}
        guard let scheme = comps.scheme else {return nil}
        comps.scheme = scheme.replacingOccurrences(of: prefix, with: "")
        return comps.url
    }
}

// MARK:- NSDate Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Date {
    
    func getFormatedDateString() -> (Int,Int,Int,Int) {
          
        //  var dateString = ""
          let days = self.days(from: Date())
          let hours = self.hours(from: Date())
          let minutes = self.minutes(from: Date())
          let seconds = self.seconds(from: Date())

//          if days > 0 {
//              dateString = days
//          } else if hours >= 1 {
//              dateString = "\(hours) \(StaticStrings.hours.localized)"
//          } else if minutes >= 1 {
//              dateString = "\(minutes) \(StaticStrings.minutes.localized)"
//          } else if seconds >= 0 {
//              dateString = "\(seconds) \(StaticStrings.seconds.localized)"
//          }
        return (days,hours,minutes,seconds)
      }
    
    func timestamp() -> String {
			
		let time =	"\(self.timeIntervalSince1970)"
		let times = time.components(separatedBy: ".") as Array<String>
			return "\(times.first ?? "0")"
    }
    
    func getDate(timestamp: String) -> Date? {
        if let time = Double(timestamp) {
            let date = Date(timeIntervalSince1970: time)
            return date.toLocalTime()
        }
        return nil
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    
    static func equalsToCurrentDate(date: Date) -> Bool {
        let dateString = date.getFormattedDate(format: "dd-MM-yyyy")
        let currentDateString = Date().getFormattedDate(format: "dd-MM-yyyy")
        return dateString == currentDateString
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }

    func isGreaterThanEqualTo(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending || self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isLess = true
        }
        
        //Return Result
        return isLess
    }

    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
      
    func getFormattedDate(format: String = "MMMM, yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
//    func dateString() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = DATE_FORMAT_SMALL //this your string date format
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
//
//        return dateFormatter.string(from: self)
//    }
//
    func dateStringFromDate(_ format:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func timeStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: self)
    }
    
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

// Usage

/*
 let date1 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 let date2 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 8, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 
 let years = date2.yearsFrom(date1)     // 0
 let months = date2.monthsFrom(date1)   // 9
 let weeks = date2.weeksFrom(date1)     // 39
 let days = date2.daysFrom(date1)       // 273
 let hours = date2.hoursFrom(date1)     // 6,553
 let minutes = date2.minutesFrom(date1) // 393,180
 let seconds = date2.secondsFrom(date1) // 23,590,800
 
 let timeOffset = date2.offsetFrom(date1) // "9M"
 
 let date3 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 let date4 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 
 let timeOffset2 = date4.offsetFrom(date3) // "1y"
 
 let timeOffset3 = NSDate().offsetFrom(date3) // "54m"
 */

// MARK:- UIViewController Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UINavigationController {
    
    func popBack(_ nb: Int) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < nb else {
            self.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
            return
        }
    }
    
    /// pop back to specific viewcontroller
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        var viewControllers: [UIViewController] = self.viewControllers
        viewControllers = viewControllers.reversed()
        for currentViewController in viewControllers {
            if currentViewController .isKind(of: toControllerType) {
                self.popToViewController(currentViewController, animated: true)
                break
            }
        }
    }
    
}
extension UIViewController {
    
    func backViewController() -> UIViewController? {
        if let stack = self.navigationController?.viewControllers {
            for count in 0...stack.count - 1 {
                if(stack[count] == self) {
                  // logInfo("viewController     \(stack[count-1])")

                    return stack[count-1]
                }
            }
        }
        return nil
    }
}

// MARK:- Int/Float/Double Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)d" as NSString, self) as String
    }
}

extension Double {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
	
		/// Rounds the double to decimal places value
		func rounded(toPlaces places:Int) -> Double {
			let divisor = pow(10.0, Double(places))
			return (self * divisor).rounded() / divisor
	}
}

extension Float {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

extension AVURLAsset {
    func exportVideo(presetName: String = AVAssetExportPresetHighestQuality, outputFileType: AVFileType = .mp4, fileExtension: String = "mp4", then completion: @escaping (URL?) -> Void)
    {
        let filename = url.deletingPathExtension().appendingPathExtension(fileExtension).lastPathComponent
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        if let session = AVAssetExportSession(asset: self, presetName: presetName) {
            session.outputURL = outputURL
            session.outputFileType = outputFileType
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: duration)
            session.timeRange = range
            session.shouldOptimizeForNetworkUse = true
            session.exportAsynchronously {
                switch session.status {
                    case .completed:
                        completion(outputURL)
                    case .cancelled:
                        debugPrint("Video export cancelled.")
                        completion(nil)
                    case .failed:
                        let errorMessage = session.error?.localizedDescription ?? "n/a"
                        debugPrint("Video export failed with error: \(errorMessage)")
                        completion(nil)
                    default:
                        break
                }
            }
        } else {
            completion(nil)
        }
    }
}

//extension Character {
//    func isEmoji() -> Bool {
//        let primary:UInt32 = 0x8BC34AFF
//        return Character(_:UnicodeScalar(primary)!) <= self && self <= Character(_:UnicodeScalar (0x1f77f ))
//            || Character(UnicodeScalar(0x8BC34AFF as UInt32)!) <= self && self <= Character(UnicodeScalar(0x26ff))
//    }
//}

//extension String {
//    func stringByRemovingEmoji() -> String {
//        return String(filter(self, {c in !c.isEmoji()}))
//    }
//}

// MARK:- UIImageView Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIImageView {
    
    /*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Changing icon color according to theme <<<<<<<<<<<<<<<<<<<<<<<<*/
    func setColor(_ color:UIColor) {
        
        if let image = self.image {
            var s = image.size // CGSize
            s.height *= image.scale
            s.width *= image.scale
            
            UIGraphicsBeginImageContext(s)
            
            var contextRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: s)
            
            // Retrieve source image and begin image context
            let itemImageSize = s //CGSize
            
            let xVal = (contextRect.size.width - itemImageSize.width)/2
            let yVal = (contextRect.size.height - itemImageSize.height)
            
            //let itemImagePosition = CGPoint(x: ceilf(xFloatVal), y: ceilf(yVal)) //CGPoint
            
            let itemImagePosition = CGPoint(x: xVal, y: yVal) //CGPoint
            
            UIGraphicsBeginImageContext(contextRect.size)
            
            let c = UIGraphicsGetCurrentContext() //CGContextRef
            
            // Setup shadow
            // Setup transparency layer and clip to mask
            c!.beginTransparencyLayer(auxiliaryInfo: nil)
            c!.scaleBy(x: 1.0, y: -1.0)
            
            //CGContextRotateCTM(c, M_1_PI)
            
            c!.clip(to: CGRect(x: itemImagePosition.x, y: -itemImagePosition.y, width: itemImageSize.width, height: -itemImageSize.height), mask: image.cgImage!)
            
            // Fill and end the transparency layer
            let colorSpace = color.cgColor.colorSpace //CGColorSpaceRef
            let model = colorSpace!.model //CGColorSpaceModel
            
            let colors = color.cgColor.components
            
            if (model == .monochrome) {
                c!.setFillColor(red: (colors?[0])!, green: (colors?[0])!, blue: (colors?[0])!, alpha: (colors?[1])!)
            } else {
                c!.setFillColor(red: (colors?[0])!, green: (colors?[1])!, blue: (colors?[2])!, alpha: (colors?[3])!)
            }
            
            contextRect.size.height = -contextRect.size.height
            contextRect.size.height -= 15
            c!.fill(contextRect)
            c!.endTransparencyLayer()
            
            let img = UIGraphicsGetImageFromCurrentImageContext() //UIImage
            
            let img2 = UIImage(cgImage: img!.cgImage!, scale: image.scale, orientation: image.imageOrientation)
            
            UIGraphicsEndImageContext()
            
            self.image = img2
            
        } else {
            print("Unable to chage color of image. Image not found")
        }
    }
    
//    func normalLoad(urlString:String?) {
//        
//        guard let urlStr = urlString else {
//            self.image = UIImage(named: "placeholder")!
//            
//            return
//        }
//        
//        if let url = URL(string: urlStr) {
//            
//            self.sd_setShowActivityIndicatorView(true)
//            self.sd_setIndicatorStyle(.whiteLarge)
//            
//            self.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")!)
//        } else {
//            self.image = UIImage(named: "placeholder")!
//        }
//    }
    
    
   
}

//MARK:- Date Extension
extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return years(from: date)   > 1 ? "\(years(from: date)) years ago" : "\(years(from: date)) year ago"  }
        if months(from: date)  > 0 { return months(from: date)  > 1 ? "\(months(from: date)) months ago" : "\(months(from: date)) month ago" }
        if weeks(from: date)   > 0 { return weeks(from: date)   > 1 ? "\(weeks(from: date)) weeks ago" : "\(weeks(from: date)) week ago"  }
        if days(from: date)    > 0 { return days(from: date)    > 1 ? "\(days(from: date)) days ago"  : "\(days(from: date)) day ago"  }
        if hours(from: date)   > 0 { return hours(from: date)   > 1 ? "\(hours(from: date)) hours ago" : "\(hours(from: date)) hour ago"  }
        if minutes(from: date) > 0 { return minutes(from: date) > 1 ? "\(minutes(from: date)) mins ago" : "\(minutes(from: date)) min ago" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) secs ago" }
        return ""
    }
}


extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}



public extension UITextField {
    
    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func makeUnderlineInvisible() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func makeUnderLineRed() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.red.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
   
        @IBInspectable var padding_left: CGFloat {
            get {
              //  LF.log("WARNING no getter for UITextField.padding_left")
                return 0
            }
            set (f) {
                layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
            }
    }

}

extension UIImage {
    
    func resizeImage(image: UIImage) -> UIImage {
        
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = 200.0
        let maxWidth: Float = 300.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x:0.0, y:0.0, width:CGFloat(actualWidth), height:CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img!.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
    }
    
    func compressImage(compressionQuality: CGFloat, image: UIImage) -> UIImage {
        let imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))!
        return UIImage(data: imageData) ?? UIImage()
    }
}

extension UIButton {
	func centerTextAndImage(spacing: CGFloat) {
		let insetAmount = spacing / 2
        let factor: CGFloat =  1
    
		self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount*factor, bottom: 0, right: insetAmount*factor)
		self.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount*factor, bottom: 0, right: -insetAmount*factor)
		self.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
		
	}
    
    
//    func normalLoad(urlString:String?) {
//        guard let urlStr = urlString else {
//            self.setImage(UIImage(named: "placeholder")!, for: .normal)
//            return
//        }
//        if let url = URL(string: urlStr) {
//            //self.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")!, options: .refreshCached)
//            self.sd_setImage(with: url, for: .normal, completed: nil)
//        } else {
//            self.setImage(UIImage(named: "placeholder")!, for: .normal)
//        }
//    }
    
}


extension UITextField {
    func setTexFieldProperty(keyboardType: UIKeyboardType, returnType: UIReturnKeyType, autoCaptalise: UITextAutocapitalizationType, isSecure: Bool  ) {
        self.keyboardType = keyboardType
        self.returnKeyType = returnType
        self.autocapitalizationType = autoCaptalise
        self.isSecureTextEntry = isSecure
       }
}

extension UITableView {
    func setEmptyTextScreen(status: Bool, titleImage : String, title : String, subTitle: String, isSubTitleNeeded:Bool) {
          DispatchQueue.main.async {
              let view = self.loadNiB()
              
              view.titleImageView.image = UIImage(named: titleImage)
              view.titleLable.text = title
              
              view.subtitleLabel.isHidden = !isSubTitleNeeded
              if isSubTitleNeeded {
                  view.subtitleLabel.text = subTitle
              }
                            
              if status {
                  self.backgroundView = view
              }else {
                  self.backgroundView = UIView()
              }
              super.layoutIfNeeded()
          }
          
      }
      
      func loadNiB() -> NoDataFoundView {
          let infoWindow = NoDataFoundView.instanceFromNib() as! NoDataFoundView
          return infoWindow
      }
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970)
    }
}


extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            print("Error converting HTML to NSAttributedString:", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                   length: self.upperBound.encodedOffset -
                    self.lowerBound.encodedOffset)
    }
}

