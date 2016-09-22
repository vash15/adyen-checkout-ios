//
//  CheckoutRequest.swift
//  Pods
//
//  Created by Taras Kalapun on 12/4/15.
//
//

import Foundation

/**
 The `CheckoutRequest` class encapsulates a request for payment, including information about amount, currency and reference.
 */
open class CheckoutRequest : NSObject {
    
    /// The payment amount
    open var amount = 0.00
    
    /// The three-letter ISO 4217 currency code.
    open var currency = "USD"
    
    /// Merchant reference
    open var reference: String = ""
}
