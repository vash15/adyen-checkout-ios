//
//  CheckoutViewController.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

public enum CheckoutAuthorizationStatus : Int {
    
    /// Merchant auth'd (or expects to auth) the transaction successfully.
    case Success
    
    /// Merchant failed to auth the transaction.
    case Failure
}


public protocol CheckoutViewControllerDelegate: class {
    func checkoutViewController(controller: CheckoutViewController, authorizedPayment payment: CheckoutPayment)
    func checkoutViewController(controller: CheckoutViewController, failedWithError error: NSError)
}

public class CheckoutViewController: UIViewController, CheckoutPaymentFieldDelegate {
    
    public var request: CheckoutRequest!
    public weak var delegate: CheckoutViewControllerDelegate?
    
    /// Logo image to be shown in a header view
    public var logoImage: UIImage?
    
    /// Title to be shown in a header view
    public var titleText: String?
    public var subtitleText: String?
    
    public var backgroundColor = UIColor(red: 0.306, green: 0.573, blue: 0.875, alpha: 1)
    public var titleColor = UIColor.whiteColor()
    
    
    
    var oldKeyboardRect = CGRect.zero
    
    public var headerView: CheckoutHeaderView!
    public var paymentFieldView: CheckoutPaymentFieldView!
    public var paymentButton: CheckoutPaymentButton!
    
    /// Initializes and returns a newly created view controller for the supplied payment request.
    /// It is your responsibility to present and dismiss the view controller using the
    /// appropriate means for the given device idiom.
    public init(checkoutRequest request: CheckoutRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Checkout.shared.publicKey == nil) {
            Checkout.shared.fetchPublickKey({ (publicKey, error) -> Void in
                if (error != nil) {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        let alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    })
                    
                }
            })
        }
        
        
        //self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.whiteColor()
        
        let isDarkBg = backgroundColor.isDark()
        titleColor = (isDarkBg) ? UIColor.whiteColor() : UIColor.darkTextColor()
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = backgroundColor.darkerColor(0.10)
        self.navigationController?.navigationBar.barStyle = (isDarkBg) ? .Black : .Default
        self.setNeedsStatusBarAppearanceUpdate()
        
        
        
        self.navigationController?.navigationBar.tintColor = titleColor
        
        
        var isModal: Bool {
            return self.presentingViewController?.presentedViewController == self
                || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
                || self.tabBarController?.presentingViewController is UITabBarController
        }
        
        if (isModal) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(CheckoutViewController.dismiss))
        }
        
        //if (!headerView) { headerView = CheckoutHeaderView() }
        
        if (paymentButton == nil) {
            paymentButton = CheckoutPaymentButton()
        }
        
        if (paymentFieldView == nil) {
            paymentFieldView = CheckoutPaymentFieldView()
        }
        
        if (headerView == nil) {
            headerView = CheckoutHeaderView()
        }
        
        self.view.addSubview(headerView)
        self.view.addSubview(paymentFieldView)
        self.view.addSubview(paymentButton)
        
        
        headerView.hidden = (self.view.bounds.height < 500)
        if headerView.hidden {
            self.navigationItem.title = self.titleText
        }
        
        
        //headerV.frame.origin.y = 64
        
        paymentFieldView.delegate = self
        
        let formattedPrice = Checkout.shared.formatPrice(request.amount, currency: request.currency)
        let title = "Pay \(formattedPrice)"
        paymentButton.setTitle(title, forState: .Normal)
        
        paymentButton.enabled = false
        //togglePayButton()
        
        paymentButton.addTarget(self, action: #selector(CheckoutViewController.payButtonPressed), forControlEvents: .TouchUpInside)
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CheckoutViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CheckoutViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let endAlpha:CGFloat = self.paymentButton.enabled ? 1.0 : 0.5
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.paymentButton.alpha = endAlpha
            }, completion: nil)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func viewWillLayoutSubviews() {
        headerView.logoImage = logoImage
        headerView.titleText = titleText
        headerView.subtitleText = (subtitleText != nil) ? subtitleText : request.reference
        headerView.backgroundColor = backgroundColor
        
        super.viewWillLayoutSubviews()
        
        //let topSpace:CGFloat = (self.navigationController != nil) ? 60 : 0
        
        var frame = CGRect.zero
        
        let showHeader = (self.view.bounds.height > 500)
        
        if showHeader {
            //            let headerV = headerView()
            //            self.view.addSubview(headerV)
            frame = headerView.frame
        } else {
            self.navigationItem.title = self.titleText
        }
        
        paymentFieldView.frame.origin.y = frame.origin.y + frame.size.height
        initialViewsLayout()
    }
    
    func initialViewsLayout() {
        let freeSpaceY = paymentFieldView.frame.origin.y + paymentFieldView.frame.size.height
        let btnY = freeSpaceY + 10
        paymentButton.frame.origin.y = btnY
    }
    
    func relayoutViewsWithKeyboard(var keyboardRect: CGRect, animationDuration: Float) {
        if (oldKeyboardRect == keyboardRect) {
            return
        }
        
        let viewSize = self.view.bounds
        let padding:CGFloat = 10
        let btnHeight = paymentButton.frame.size.height
        if (keyboardRect.origin.y >= viewSize.height - btnHeight) { keyboardRect = CGRect.zero }
        oldKeyboardRect = keyboardRect
        
        
        if (!headerView.hidden) {
            if (keyboardRect.origin.y > 0) {
                var kbdHeight = keyboardRect.size.height
                
                if (UIDevice.currentDevice().userInterfaceIdiom == .Pad && kbdHeight > 200) {
                    kbdHeight = 200
                }
                
                headerView.frame.size.height = viewSize.height - paymentFieldView.frame.size.height - kbdHeight - btnHeight - padding * 2
                paymentFieldView.frame.origin.y = headerView.frame.size.height
                paymentButton.frame.origin.y = paymentFieldView.frame.origin.y + paymentFieldView.frame.size.height + padding
                return
            }
            
        }
        
        
        
        
        let freeSpaceY = paymentFieldView.frame.origin.y + paymentFieldView.frame.size.height
        let btnY = (keyboardRect.origin.y == 0) ? freeSpaceY + padding : keyboardRect.origin.y - padding - btnHeight
        
        paymentButton.frame.origin.y = btnY
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue else {
                return
        }
        
        relayoutViewsWithKeyboard(self.view.convertRect(keyboardRect, fromView: nil), animationDuration: duration)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue else {
                return
        }
        
        relayoutViewsWithKeyboard(self.view.convertRect(keyboardRect, fromView: nil), animationDuration: duration)
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return (backgroundColor.isDark()) ? .LightContent : .Default;
    }
    
    public func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func togglePayButton() {
        //        let startAlpha = self.paymentButton.enabled ? 1.0 : 0.5
        let endAlpha:CGFloat = self.paymentButton.enabled ? 1.0 : 0.5
        UIView.animateWithDuration(0.4) { () -> Void in
            self.paymentButton.alpha = endAlpha
        }
    }
    
    public func paymentFieldChangedValidity(valid: Bool) {
        self.paymentButton.enabled = self.paymentFieldView.valid
        togglePayButton()
    }
    
        
    public func payButtonPressed() {
        
    }
    
}
