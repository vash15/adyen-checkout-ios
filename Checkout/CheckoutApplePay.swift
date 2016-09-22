//
//  CheckoutApplePay.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation
import PassKit

/// A Card `PaymentData` object
open class ApplePayPaymentData: PaymentData {
    
    /// ApplePay payment
    var payment: PKPayment!

    
    open func serialize() -> String {

        
        return ""
    }
}
