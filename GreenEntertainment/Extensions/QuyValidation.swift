//
//  QuyValidation.swift
//
//
//  Created by MacMini-iOS on 01/05/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import Foundation

enum QuyValid {
    case success
    case failure(String)
}

//MARK: - Regular Expressions
internal struct QuyRegexExpresssions {
    
    static let EmailRegex = "[A-Z0-9a-z._%+-]{1,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    static let PasswordRegex = "^(?=.*[A-Za-z_@./#&+-])(?=.*\\d)[A-Za-z \\d]{6,24}$" //Min 6 and Max 24 characters, at least one letter and one number
    static let PhoneRegex = "[0-9.+]{6,14}"
    static let alphabeticRegex = "^[a-zA-Z\u{3000}\u{3400}-\u{4DBF}\u{4E00}-\u{9FFF}]*$"
    static let nameRegex = "^[a-zA-Z\u{3000}\u{3400}-\u{4DBF}\u{4E00}-\u{9FFF}0-9_ !@#$&()\\-`.+,/\"]*$"
    static let numberOnly = "^[0-9]+$"
}

class QuyValidation: NSObject {
    static let shared = QuyValidation()
}


//extension QuyValidation {
//
//    func validateLoginDetails( email: String, password: String ) -> QuyValid {
//        
//        if (email).isEmpty {
//            return errorMsg(ValidationMessage.EmptyEmail.rawValue.localize())
//
//        } else if !self.isValidEmail(email) {
//            return errorMsg(ValidationMessage.InvalidEmail.rawValue.localize())
//
//        } else if (password).isEmpty {
//            return errorMsg(ValidationMessage.EmptyPassword.rawValue.localize())
//
//        } else if password.count < 8 {
//            return errorMsg(ValidationMessage.InvalidPassword.rawValue.localize())
//
//        }
//
//        return .success
//    }
//
//    func validateRegistrationDetails( object: User, isSocial: Bool ) -> QuyValid {
//
//        if (object.first_name ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyFirstName.rawValue.localize())
//
//        } else if !self.isValidName(object.first_name ?? "") {
//            return errorMsg(ValidationMessage.InvalidFirstName.rawValue.localize())
//
//        } else if (object.last_name ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyLastName.rawValue.localize())
//
//        } else if !self.isValidName(object.last_name ?? "") {
//            return errorMsg(ValidationMessage.InvalidLastName.rawValue.localize())
//
//        } else if (object.email ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyEmail.rawValue.localize())
//
//        } else if !self.isValidEmail(object.email ?? "") {
//            return errorMsg(ValidationMessage.InvalidEmail.rawValue.localize())
//
//        } else if (object.password ?? "").isEmpty && !isSocial {
//            return errorMsg(ValidationMessage.EmptyPassword.rawValue.localize())
//
//        } else if (object.password ?? "").count < 8 && !isSocial {
//            return errorMsg(ValidationMessage.InvalidPassword.rawValue.localize())
//
//        } else if (object.confirm_password ?? "").isEmpty  && !isSocial {
//            return errorMsg(ValidationMessage.InvalidConfirmPassword.rawValue.localize())
//
//        } else if (object.confirm_password ?? "") != (object.password ?? "") && !isSocial {
//            return errorMsg(ValidationMessage.InvalidConfirmPassword.rawValue.localize())
//
//        } else if !(object.isAgreeToTnC ?? false) {
//            return errorMsg(ValidationMessage.AcceptTermsAndCondition.rawValue.localize())
//        }
//
//        return .success
//    }
//
//    func validateEditProfileDetails( object: User ) -> QuyValid {
//
//        if (object.first_name ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyFirstName.rawValue.localize())
//
//        } else if !self.isValidName(object.first_name ?? "") {
//            return errorMsg(ValidationMessage.InvalidFirstName.rawValue.localize())
//
//        } else if (object.last_name ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyLastName.rawValue.localize())
//
//        } else if !self.isValidName(object.last_name ?? "") {
//            return errorMsg(ValidationMessage.InvalidLastName.rawValue.localize())
//
//        } else if (object.industry_name ?? "").isEmpty {
//            return errorMsg(ValidationMessage.SelectIndustry.rawValue.localize())
//
//        } else if (object.email ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyEmail.rawValue.localize())
//
//        } else if (object.mobile_number_country_code ?? "").isEmpty {
//            return errorMsg(ValidationMessage.SelectCountryCode.rawValue.localize())
//
//        } else if (object.phone_number ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyPhoneNumber.rawValue.localize())
//
//        } else if !self.isValidEmail(object.email ?? "") {
//            return errorMsg(ValidationMessage.InvalidEmail.rawValue.localize())
//
//        }
//
//        return .success
//    }
//
//    func validateForgotPassword( email: String ) -> QuyValid {
//
//        if (email).isEmpty {
//            return errorMsg(ValidationMessage.EmptyEmail.rawValue.localize())
//
//        } else if !self.isValidEmail(email) {
//            return errorMsg(ValidationMessage.InvalidEmail.rawValue.localize())
//
//        }
//
//        return .success
//    }
//
//    func validateVerificationCode( code: String ) -> QuyValid {
//
//        if (code).isEmpty {
//            return errorMsg(ValidationMessage.EnterCode.rawValue.localize())
//
//        }
//
//        return .success
//    }
//
//    func validateResetPassword( object: User ) -> QuyValid {
//
//        if (object.password ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyPassword.rawValue.localize())
//
//        } else if (object.password ?? "").count < 8 {
//            return errorMsg(ValidationMessage.InvalidPassword.rawValue.localize())
//
//        } else if (object.confirm_password ?? "").isEmpty {
//            return errorMsg(ValidationMessage.EmptyConfirmPassword.rawValue.localize())
//
//        } else if (object.confirm_password ?? "") != (object.password ?? "") {
//            return errorMsg(ValidationMessage.InvalidConfirmPassword.rawValue.localize())
//
//        }
//        return .success
//
//    }
//
//
//}


extension QuyValidation {
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", QuyRegexExpresssions.EmailRegex)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhone(_ testStr:String) -> Bool {
        if !testStr.isEmpty {
            if testStr.count < 4 && !testStr.isEmpty{
                return false
            }
            else{
                
                let phoneTest = NSPredicate(format:"SELF MATCHES %@", QuyRegexExpresssions.PhoneRegex)
                return phoneTest.evaluate(with: testStr)
            }
        }else{
            return true
        }
    }
    
    func isValidPasswd(_ testStr:String) -> Bool {
        if testStr.isEqual(testStr.trimmingCharacters(in: .whitespaces)) {
            let passwdTest = NSPredicate(format:"SELF MATCHES %@", QuyRegexExpresssions.PasswordRegex)
            if passwdTest.evaluate(with: testStr) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func isValidName(_ testStr:String) -> Bool {
        let nameTest = NSPredicate(format:"SELF MATCHES %@", QuyRegexExpresssions.alphabeticRegex)
        return nameTest.evaluate(with: testStr)
    }
    
    func containsNumberOnly(_ text: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "1234567890")
        let characterSet = CharacterSet(charactersIn: text)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func errorMsg(_ str : String) -> QuyValid {
        return .failure(str)
    }
    
}
