//
//  CheckoutPayment.swift
//  Pods
//
//  Created by Taras Kalapun on 12/4/15.
//
//

import Foundation

/// The `CheckoutPayment` class represents the result of authorizing a payment request. It contains payment information, encrypted in the `paymentData`.
public class CheckoutPayment : NSObject {
    
    /// The payment amount
    private(set) public var amount: Double
    
    /// The three-letter ISO 4217 currency code.
    private(set) public var currency: String
    
    /// Merchant reference
    private(set) public var reference: String
    
    /// Base64 encoded encrypted payment data.  Ready for transmission via
    /// merchant's e-commerce backend to payment processor's gateway.
    private(set) public var paymentData: String
    
    public init(request: CheckoutRequest, encryptedData: String) {
        amount = request.amount
        currency = request.currency
        reference = request.reference
        paymentData = encryptedData
    }
}