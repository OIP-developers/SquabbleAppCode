//
//  Constants.swift
//  GreenEntertainment
//
//  Created by Quytech on 11/19/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import UIKit
import RxSwift

enum AlertMessages: String {
    case sessionExpired = "Sorry, your account has been logged in other device! Please login again to continue."
    
    func getLocalizedValue() -> String {
        return NSLocalizedString(self.rawValue, comment: self.rawValue)
    }
}

struct UserDefaultsKey{
    
    static let deviceTokenn       = "deviceTokenn"
    static let IS_LOGIN           = "is_login"
    static let USER_ID            = "userId"
    static let USER_CONTACTS      = "userContacts"
    static let isNotificationOn   = "isNotificationOn"
    static let deviceId           = "deviceId"
    static let facebookId         = "facebookId"
    static let callingCode        = "callingCode"
    static let isBackUpOn         = "isBackUpOn"
    static let loggedInUserInfo   = "loggedInUserInfo"
    static let signupInfo         = "signupInfo"
    static let device_token_ios_voip    = "device_token_ios_voip"

}


enum ValidationMessage: String{
    case EmptyName = "Please enter name"
    case EmptyPhoneNumber = "Please enter phone number"
    case ValidPhoneNumber = "Please enter valid phone number"
    case EmptyAddress = "Please enter address"
    case EmptyDOB = "Please enter dob"
    case InvalidName = "Please enter valid name."
    case kMessage = "The password must be 8 to 16 characters long and having at least one uppercase letter, one lowercase letter, one number and one special character."

    case EmptyUsername = "Please enter username."
    case InvalidUsername = "Please enter valid username."
    case EmptyEmail = "Please enter email."
    case InvalidEmail = "Please enter valid email." // --
    case EmptyPassword = "Please enter password."
    case EmptyOldPassword = "Please enter old password."
    case EmptyNewPassword = "Please enter new password."
    case EmptyAge = "Please select date of birth."
    case InvalidAge = "Please enter valid age."
    
    case EmptyConfirmPassword = "Please enter confirm password."
    case InvalidConfirmPassword = "Password and confirm password does not match."
    case InvalidPassword = "Password length should be at least 8 characters."
    case InvalidPasswordEnter = "Please enter valid password."
    case InvalidNewPassword = "New password length should be at least 8 characters."
    case EmptyEmailOrPhone = "Please enter email/ mobile number."
    case InvalidMobileNumber = "Please enter valid phone number."
    case EmptyOTP = "Enter OTP." // --
    case EmptyZipCode = "Please enter zip code."
    case InvalidZipCode = "Please enter valid zip code."
    case EmptyFirstName = "Please enter first name."
    case InvalidFirstName = "Please enter valid first name."
    case EmptyLastName = "Please enter last name."
    case EmptyGender = "Please enter your gender."
    case InvalidGender = "Please enter valid gender."

    case InvalidLastName = "Please enter valid last name."
    case AcceptTermsAndCondition = "Please accept terms and conditions."
    case SelectCountryCode = "Please select country code."
    case EnterCode = "Please enter code."
    
    case EmptyAccountNumber = "Please enter account number."
    case InvalidAccountNumber = "Please enter valid account number."
    case EmptyBankName = "Please enter bank name."
    case InvalidBankName = "Please enter valid bank name."
    case EmptyRoutingNumber = "Please enter routing number."
    case EmptySwiftCode = "Please enter swift code."
    case InvalidSwiftCode = "Please enter valid swift code."
    case EmptyDonateAmount = "Please enter amount to donate."
    case MinimumVideoLimit = "Video should be minimum of 5 seconds."
    case EmptyAmount = "Please enter amount."
    case ValidAmount = "Please enter valid amount."
    case MinimumAmount = "Please enter amount greater than 0."
    case RequestedFollow = "has not accepted your request yet."
    case FollowMessage = "Follow this account to message."
    case ShareMessage = "Follow this account to share video."
    case FollowTitleMessage = "This account is private."

    
   // case LoginAlert = "You are not registered with Sizzle. Please, login or register yourself for use sizzle completely."
    
    case LoginAlert = "Login or register now, to get all the Squabble features."
    case videoUploadCountAlert = "You can not upload more than 20 videos. Please remove some videos from profile."
    

//    func getLocalizedValue() -> String
//        return self.rawValue.localize()
//       }
}



class Constants: NSObject {
    
    //CollectioViewCell Identifiers
    static  let kTutorialCollectionViewCellIdentifier = "TutorialCollectionViewCell"
    static let kAgreeTermsAndConditions = "I agree to Terms and Conditions"
    static let kTermsAndCondition =  "Terms and Conditions"
    static let kForgotPassword = "Forgot Password?"
    static let kVerificationCode = "Verification Code"
    static let kChallengeTerms = "I have read the complete list of rules in the Terms and Conditions"
    
    static let generalPublisher: PublishSubject<String> = PublishSubject()

    
    static let stripe_Live_ClientId = "ca_HoAwArNpo8ey2riEPNAydDxeUfhZFBGh"
    static let stripe_Test_ClientId = "ca_HoAwiRkdHe9lfkhbhj41H7toQRALBRcj"


    //Alert messages

    
    
    // Keys
    static let kMessage = "message"
    static let kMessageText = "Message"
    static let kTest = "Test"
    static let kData = "data"
    static let Code = "code"
    static let OTP = "otp"
    static let AUTH_TOKEN = "auth_token"
    static let Video_ID = "video_id"
    static let Video_URL = "video_url"
    static let kImage_URL = "image_url"
    static let kVideo_File = "video_file"
    
    static let kSEND_CHAT_MESSAGE = "SEND_CHAT_MESSAGE"
    static let kVIDEO_SHARE = "VIDEO_SHARE"
    static let kVIDEO_VOTE = "VIDEO_VOTE"
    static let kUSER_FOLLOW = "USER_FOLLOW"
    static let kDONATION_RECEIVED = "DONATION_RECEIVED"
    static let kGOT_NEW_BADGE = "GOT_NEW_BADGE"
    static let kDONATION_SENT = "DONATION_SENT"
    static let kMONEY_ADDED_TO_WALLET = "MONEY_ADDED_TO_WALLET"
    static let kWITHDRAW_MONEY_FROM_WALLET = "WITHDRAW_MONEY_FROM_WALLET"
    static let kREWARD_CLAIMED = "REWARD_CLAIMED"
    static let kNEW_CHALLENGE_POSTED = "NEW_CHALLENGE_POSTED"
    static let kWINNER_ANNOUNCEMENT = "WINNER_ANNOUNCEMENT"
    static let kWINNER_NOTIFIED = "WINNER_NOTIFIED"
    static let kMONTHLY_CHALLENGE_VOTING_OPEN = "MONTHLY_CHALLENGE_VOTING_OPEN"
    static let kWEEKLY_CHALLENGE_VOTING_OPEN = "WEEKLY_CHALLENGE_VOTING_OPEN"
    static let kSIZZLE_SHOWCASEHOUR_DAILY = "SIZZLE_SHOWCASEHOUR_DAILY"
    static let kLIVE_STREAMING_ON = "LIVE_STREAMING_ON"
    static let kLIVE_STREAMING_END = "LIVE_STREAMING_END"
    static let kMANUAL_NOTIFICATION = "MANUAL_NOTIFICATION"
    static let kRANDOM_VOTER_PRIZE = "RANDOM_VOTER_PRIZE"
    static let kREFUND_TO_WALLET = "REFUND_TO_WALLET"
    static let kWITHDRAW_MONEY_REQUEST_APPROVED = "WITHDRAW_MONEY_REQUEST_APPROVED"
    static let kSUBMISSION_OPEN = "SUBMISSION_OPEN"
    static let kDAILY_CHALLENGE_VOTING_OPEN = "DAILY_CHALLENGE_VOTING_OPEN"
    static let kACCEPTED_REQUEST = "ACCEPTED_REQUEST"
    static let kUSER_FOLLOW_REQUEST = "USER_FOLLOW_REQUEST"
    static let kVIDEO_TAG = "VIDEO_TAG"
    static let kGIFT_PURCHASED = "GIFT_PURCHASED"

    // Wallet
    static let kBankName = "Bank Name"
    static let kAccountNumber = "Account Number"
    static let kAccountHolderName = "Account Holder's Name"
    static let kRoutingNumber = "Routing Number"
    static let kSwiftCode = "Swift Code"
    static let kUpdateAccount = "Update Bank Account"
    static let kAddAccount = "Add New Bank Account"
    static let kUpdate = "Update"
    static let kProceed = "Proceed"
    
    static let kAPPLE_MERCHANT_ID = "merchant.com.green.squabble"



}
enum Fonts {

enum FontSize : CGFloat {
    case small = 12.0
    case medium = 14.0
    case large = 16.0
    case xLarge = 18.0
    case xXLarge = 20.0
    case xxLarge = 19.0
    case xxLLarge = 22.0
    case xxxLarge = 25.0
    case xXXLarge = 32.0
    case XVLarge = 50.0
}
    
    enum Rubik : String {
           
           case regular    = "Rubik-Regular"
           case medium     = "Rubik-Medium"
           case bold       = "Rubik-Bold"

           func font(_ size : FontSize) -> UIFont {
               return UIFont(name: self.rawValue, size: size.rawValue)!
           }
       }
}

enum ScreenType: String {
    case termsAndCondition  = "Terms and Conditions"
    case aboutus  = "About Us"
}


enum OTPScreenType {
    case forgotPassword
    case verification
    case updateEmail
}

enum CameraScreenType {
    case signup
    case edit
}
