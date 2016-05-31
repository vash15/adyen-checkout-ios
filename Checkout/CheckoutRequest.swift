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
public class CheckoutRequest : NSObject {
    
    /// The payment amount
    public var amount = 0.00
    
    /// The three-letter ISO 4217 currency code.
    public var currency = "USD"
    
    /// Merchant reference
    public var reference: String = ""
}