//
//  CheckoutPayment.swift
//  Pods
//
//  Created by Taras Kalapun on 12/4/15.
//
//

import Foundation

/// The `CheckoutPayment` class represents the result of authorizing a payment request. It contains payment information, encrypted in the `paymentData`.
open class CheckoutPayment : NSObject {
    
    /// The payment amount
    fileprivate(set) open var amount: Double
    
    /// The three-letter ISO 4217 currency code.
    fileprivate(set) open var currency: String
    
    /// Merchant reference
    fileprivate(set) open var reference: String
    
    /// Base64 encoded encrypted payment data.  Ready for transmission via
    /// merchant's e-commerce backend to payment processor's gateway.
    fileprivate(set) open var paymentData: String
    
    public init(request: CheckoutRequest, encryptedData: String) {
        amount = request.amount
        currency = request.currency
        reference = request.reference
        paymentData = encryptedData
    }
}
