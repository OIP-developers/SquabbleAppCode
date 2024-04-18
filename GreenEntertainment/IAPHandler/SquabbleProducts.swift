//
//  SquabbleProducts.swift
//  GreenEntertainment
//
//  Created by Prempriya on 12/04/21.
//  Copyright © 2021 Quytech. All rights reserved.
//

import Foundation

class SquabbleProducts {
    
    static let instance = SquabbleProducts()

    private var store = IAPHelper(productIds: [])
    
    func initiateProducts(identifier: Set<ProductIdentifier>) {
        self.store = IAPHelper(productIds: identifier)
    }
    
    class func storeInstance() -> IAPHelper {
        return SquabbleProducts.instance.store
    }
}
