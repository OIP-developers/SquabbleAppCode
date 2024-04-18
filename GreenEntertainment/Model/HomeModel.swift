//
//  HomeModel.swift
//  GreenEntertainment
//
//  Created by Sunil Joshi on 29/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import ObjectMapper


class HomeModel: Mappable {
    var challenge_id : String?
    var hashtag : String?
    @Capitalized var title : String?
    @Capitalized var user = "joshi"
    var price : String?
    var challenge_type : String?
    var start_timestamp: String?
    var end_timestamp : String?
    //    "created_at: "2020-06-10 09:44:09",
    //    "updated_at": "2020-06-18 10:44:34",
    var status : String?
    var challenge_video = [RewardsModel]()
    var no_of_participants: String?
    var check_if_participated : String?
    var video_id : Int?
    
    var timeLeft: Int = 0
    var startTime: Int = 0
    var endTime: Int = 0

    var is_participate_time: String?
    
    var challlenge_started_state = false
    var challenge_end_state = false
    var is_challenge_started = false
    var is_challenge_ended = false
    var isPrimeTime: String?
    
    //get challengeList
    
    
    init() {
    }
    
    required init?(map: Map){
    }
    func mapping(map: Map){
        
        challenge_id <- map["challenge_id"]
        hashtag <- map["hashtag"]
        title <- map["title"]
        price <- map["price"]
        challenge_type <- map["challenge_type"]
        start_timestamp <- map["start_timestamp"]
        end_timestamp <- map["end_timestamp"]
        status <- map["status"]
        no_of_participants <- map["no_of_participants"]
        check_if_participated <- map["check_if_participated"]
        video_id <- map["video_id"]
        challenge_video <- map["challenge_video"]
        is_participate_time <- map["is_participate_time"]
        isPrimeTime <- map["is_prime_time"]
        // convert Date to TimeInterval (typealias for Double)
        let timeInterval = Date().timeIntervalSince1970

        timeLeft = (Int("\(end_timestamp ?? "0")") ?? 0) - (Int(timeInterval) )
        if (Int(timeInterval)) > (Int("\(start_timestamp ?? "0")") ?? 0) {
            startTime = 0
        }else {
            let localDate =  Double(start_timestamp ?? "")?.getDateStringFromUTC(format: "EEEE dd MMMM yyyy HH:mm") ?? ""
//            let loc = UTCToLocal(object: (Int("\(start_timestamp ?? "0")") ?? 0))
         //   print("timestamp: \(start_timestamp) :-\(localDate)")
        //    print("timeInterval: \(timeInterval)")

            
           // startTime = Int(localDate) ?? 0 - (Int(timeInterval))
          //  print("startTime::-\(startTime)")
            
            startTime = (Int("\(start_timestamp ?? "0")") ?? 0) - (Int(timeInterval) )
        }
        
        if (Int("\(end_timestamp ?? "0")") ?? 0) < (Int(timeInterval) ) {
            timeLeft = 0
        }
        
        self.handleEventDateTime()

    }
    
    func handleEventDateTime() {
        let start_date = Date().getDate(timestamp: start_timestamp ?? "") ?? Date()
        let end_date = Date().getDate(timestamp: end_timestamp ?? "") ?? Date()
        is_challenge_started = start_date.isGreaterThanDate(dateToCompare: Date())
        is_challenge_ended = end_date.isGreaterThanDate(dateToCompare: Date())
    }
    
//    func UTCToLocal(object:Int) -> String {
//            let date = Date(timeIntervalSince1970: TimeInterval(object))
////            let dateFormatter = DateFormatter()
////            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
////            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
////            let utcDate = dateFormatter.date(from: date)// create   date from string
//
//            // change to a readable time format and change to local time zone
//           // dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
//         //   dateFormatter.dateFormat = "HH:mm"
//
//        dateFormatter.timeZone = TimeZone.current
//        var timeStamp = dateFormatter.string(from: date)
//
//        let dateFormatterr = DateFormatter()
//         dateFormatterr.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//
//         if let myDate = dateFormatter.date(from: timeStamp) {
//
//            let timeSt = myDate.timeIntervalSince1970
//            timeStamp = "\(timeSt)"
//               // let somedateString = dateFormatter.string(from: myDate)
//               // let goodDate = dateFormatter.stringFromDate(date)
//
//                return "\(timeSt)"
//         }
//
//            print("date:-\(date)")
//            print("time",timeStamp)
//    //        object.scheduleTime = timeStamp
//            return timeStamp
//
//
////        date:-2021-01-08 15:30:00 +0000
////        time 2021-01-08T21:00:00
////        tttt:-2021-01-08T21:00:00
//        }
    

}

@propertyWrapper class Capitalized{
    var wrappedValue : String? {
        didSet { wrappedValue?.capitalized }
    }
    
    init(wrappedValue:String?) {
        self.wrappedValue = wrappedValue?.capitalized
    }
}



extension Double {
    func getDateStringFromUTC(format: String = "dd MMM, yyyy", locale: String = "en_US") -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)

//        if let language = UserDefaults.standard.value(forKey: languageKey) as? String {
//            dateFormatter.locale = Locale(identifier: language)
//        }
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = format
        
        let df = DateFormatter()
        df.dateFormat = "EEEE dd MMMM yyyy HH:mm"
        let fDate = df.date(from: dateFormatter.string(from: date))
       // print("Date::--\(fDate))")

        let timeStamp = fDate?.timeIntervalSince1970
        let intTime = Int(timeStamp ?? 0.0)
       // print("UTC Timestamp::--\(intTime)")

     //   print("UTC::--\(dateFormatter.string(from: date)))")
        
       // Thursday 07 January 2021 07:30)
       // Thursday 07 January 2021 21:00)

        return "\(intTime)"
    }
}
