//
//  Wallet.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 15/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class Wallet: NSObject {
    
    var accountNumber: String?
    var routingNumber: String?
    var swiftCode: String?
    var accountHolderName: String?
    var bankName: String?
    
    override init() {
        
    }

}

class Account: Mappable {
    var payment_id: String?
    var payment_method: String?
    var transaction_type: String?
    var payment_status: String?
    var payment_date: String?
    var credit_debit: String?
    var user_id: String?
    var receiver_id: String?
    var transaction_id: String?
    var donation_message: String?
    var amount: String?
    var created_at: String?
    var updated_at: String?
    var status: String?
    var username: String?
    var user_profile_image: String?
    var receiver_profile_image: String?
    var receiver_username: String?
    var withdraw_status: String?
    var transactions = [Account]()
    var date: String?
    var created_timestamp: String?
    var donation_message_decoded: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        payment_id <- map["payment_id"]
        payment_method <- map["payment_method"]
        transaction_type <- map["transaction_type"]
        payment_status <- map["payment_status"]
        payment_date <- map["payment_date"]
        credit_debit <- map["credit_debit"]
        user_id <- map["user_id"]
        receiver_id <- map["receiver_id"]
        transaction_id <- map["transaction_id"]
        donation_message <- map["donation_message"]
        amount <- map["amount"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        username <- map["username"]
        user_profile_image <- map["user_profile_image"]
        receiver_profile_image <- map["receiver_profile_image"]
        receiver_username <- map["receiver_username"]
        withdraw_status <- map["withdraw_status"]
        created_timestamp <- map["created_timestamp"]
        donation_message_decoded <- map["donation_message_decoded"]
        
        self.date = getReadableDateWithYear(timeStamp: self.created_timestamp ?? "")

    }
    
       
}

class ClientSecret: Mappable {
    
    
    var publishableKey : String?
    var clientSecret : String?
    var ephemeralKey : String?
    
    init() {
       
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        
        clientSecret <- map["client_secret"]
        publishableKey <- map["publishableKey"]
        ephemeralKey <- map["empheralKey"]//need key check
    }
}


class Bank: Mappable {
    
    
    var bank_name : String?
    var account_holder_name : String?
    var last4 : String?
    var currency : String?
    var country : String?
    var routing_number : String?
    var customer : String?
    var id : String?
    var status: Bool?
    var account_number: String?
    var swift_code: String?
    var user_bank_details_id: String?
    var brand: String?
    
    init() {
       
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        
        bank_name <- map["bank_business_name"]
        account_holder_name <- map["account_holder_name"]
        last4 <- map["last4"]
        currency <- map["currency"]
        country <- map["country"]
        routing_number <- map["routing_number"]
        customer <- map["customer"]
        id <- map["id"]
        account_number <- map["account_number"]
        swift_code <- map["swift_code"]
        user_bank_details_id <- map["user_bank_details_id"]
       
    }
}

class BankInfo: Mappable {
    
    var brand = ""
    var dynamic_last4: String?
    var name: String?
    var last4: String?
    var bank_name: String?
    
    init() {
       
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        
        brand <- map["brand"]
        dynamic_last4 <- map["dynamic_last4"]
        last4 <- map["last4"]
        name <- map["name"]
        bank_name <- map["bank_name"]
       
    }
}


