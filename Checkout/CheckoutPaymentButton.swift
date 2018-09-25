//
//  CheckoutPaymentButton.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit


open class CheckoutPaymentButton: UIButton {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    open func commonInit() {
        
        if (self.frame.size.height == 0) {
            self.frame.size.height = 44
        }
        
        self.layer.cornerRadius = 3
        self.backgroundColor = UIColor.adyGreenColor
        self.setTitleColor(UIColor.white, for: UIControlState())
        
        //let title = "Pay " + currencySymbol() + " " + String(self.amount)
        //btn.setTitle(title, forState: .Normal)

        self.addSubview(activityIndicator)
        stopAnimating()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.frame.size.height == 0) {
            self.frame.size.height = 44
        }
        
        var currentW = self.frame.size.width
        
        
        if (currentW == 0 && self.frame.origin.x == 0) {
            let padding:CGFloat = 14
            self.frame.origin.x = padding
        }
        
        guard let maxW = self.superview?.bounds.size.width else {
            return
        }
        
        if (currentW == 0) {
            self.frame.size.width = maxW - (self.frame.origin.x * 2)
        }
        
        currentW = self.frame.size.width
        
        activityIndicator.center = CGPoint(x: currentW/2, y: self.frame.size.height/2)
        
        
    }
    
    open func startAnimating() {
        titleLabel?.layer.opacity = 0.0;
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    open func stopAnimating() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        titleLabel?.layer.opacity = 1.0;
    }
    
}
