//
//  CheckoutCardViewController.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

public class CheckoutCardViewController: CheckoutViewController {
    
    public var showCardholderNameField = true
    
    override public init(checkoutRequest request: CheckoutRequest) {
        super.init(checkoutRequest: request)
        paymentFieldView = CardPaymentField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let pfv = (paymentFieldView as! CardPaymentField)
        pfv.showNameField = showCardholderNameField
    }
    
    public override func payButtonPressed() {
        
        paymentButton.startAnimating()
        
        let card = paymentFieldView.paymentData()
        //Checkout.shared.fetchPublickKey { (publicKey, error) -> Void in
            //Checkout.shared.publicKey = publicKey
            
        
        //}
        
        
        do {
            let paymentData = try card.serialize()
            let payment = CheckoutPayment(request: self.request, encryptedData: paymentData)
            delegate?.checkoutViewController(self, authorizedPayment: payment)
        }
        catch let error as NSError {
            delegate?.checkoutViewController(self, failedWithError: error)

        }
        
        
    }
}