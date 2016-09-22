//
//  CheckoutPaymentField.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

open class CheckoutTextField: UITextField {
    
    open var valid = false
    let placeholderImageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 32, height: 20))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.placeholderImageView.clipsToBounds = true
        self.placeholderImageView.contentMode = .center
        
        self.leftViewMode = .always
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 32+14, height: 20))
        placeholderView.addSubview(self.placeholderImageView)
        self.leftView = placeholderView;
        //self.font = UIFont.boldSystemFontOfSize(16)
        
        
        //self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience required public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
}

@objc
public protocol CheckoutPaymentFieldDelegate {
    func paymentFieldChangedValidity(_ valid: Bool)
//    optional func paymentFieldChangedValue(field: CheckoutTextField, valid: Bool)
}

open class CheckoutPaymentFieldView: UIControl {
    open var delegate: CheckoutPaymentFieldDelegate?
    open var valid = false
    
    open func paymentData() -> PaymentData {
        fatalError("Subclass should implement")
    }

}
