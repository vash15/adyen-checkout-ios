//
//  CheckoutPaymentField.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

public class CheckoutTextField: UITextField {
    
    public var valid = false
    let placeholderImageView = UIImageView(frame: CGRectMake(5, 0, 32, 20))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        self.placeholderImageView.clipsToBounds = true
        self.placeholderImageView.contentMode = .Center
        
        self.leftViewMode = .Always
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
    func paymentFieldChangedValidity(valid: Bool)
//    optional func paymentFieldChangedValue(field: CheckoutTextField, valid: Bool)
}

public class CheckoutPaymentFieldView: UIControl {
    public var delegate: CheckoutPaymentFieldDelegate?
    public var valid = false
    
    public func paymentData() -> PaymentData {
        fatalError("Subclass should implement")
    }

}