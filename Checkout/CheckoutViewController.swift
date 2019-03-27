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
    case success
    
    /// Merchant failed to auth the transaction.
    case failure
}


public protocol CheckoutViewControllerDelegate: class {
    func checkoutViewController(_ controller: CheckoutViewController, authorizedPayment payment: CheckoutPayment)
    func checkoutViewController(_ controller: CheckoutViewController, failedWithError error: NSError)
}

open class CheckoutViewController: UIViewController, CheckoutPaymentFieldDelegate {
    
    open var request: CheckoutRequest!
    open weak var delegate: CheckoutViewControllerDelegate?
    
    /// Logo image to be shown in a header view
    open var logoImage: UIImage?
    
    /// Title to be shown in a header view
    open var titleText: String?
    open var subtitleText: String?
    
    open var backgroundColor = UIColor(red: 0.306, green: 0.573, blue: 0.875, alpha: 1)
    open var titleColor = UIColor.white
    
    
    
    var oldKeyboardRect = CGRect.zero
    
    open var headerView: CheckoutHeaderView!
    open var paymentFieldView: CheckoutPaymentFieldView!
    open var paymentButton: CheckoutPaymentButton!
    
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Checkout.shared.publicKey == nil) {
            Checkout.shared.fetchPublicKey({ (publicKey, error) -> Void in
                if (error != nil) {
                    self.dismiss(animated: true, completion: { () -> Void in
                        let alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    })
                    
                }
            })
        }
        
        
        //self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.white
        
        let isDarkBg = backgroundColor.isDark()
        titleColor = (isDarkBg) ? UIColor.white : UIColor.darkText
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = backgroundColor.darkerColor(0.10)
        self.navigationController?.navigationBar.barStyle = (isDarkBg) ? .black : .default
        self.setNeedsStatusBarAppearanceUpdate()
        
        
        
        self.navigationController?.navigationBar.tintColor = titleColor
        
        
        var isModal: Bool {
            return self.presentingViewController?.presentedViewController == self
                || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
                || self.tabBarController?.presentingViewController is UITabBarController
        }
        
        if (isModal) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CheckoutViewController.dismissMe))
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
        
        
        headerView.isHidden = (self.view.bounds.height < 500)
        if headerView.isHidden {
            self.navigationItem.title = self.titleText
        }
        
        
        //headerV.frame.origin.y = 64
        
        paymentFieldView.delegate = self
        
        let formattedPrice = Checkout.shared.formatPrice(request.amount, currency: request.currency)
        let title = "Pay \(formattedPrice)"
        paymentButton.setTitle(title, for: UIControlState())
        
        paymentButton.isEnabled = false
        //togglePayButton()
        
        paymentButton.addTarget(self, action: #selector(CheckoutViewController.payButtonPressed), for: .touchUpInside)
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(CheckoutViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CheckoutViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let endAlpha:CGFloat = self.paymentButton.isEnabled ? 1.0 : 0.5
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.paymentButton.alpha = endAlpha
            }, completion: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewWillLayoutSubviews() {
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
    
    func relayoutViewsWithKeyboard(_ keyboardRect: CGRect, animationDuration: Float) {
        var keyboardRect = keyboardRect
        if (oldKeyboardRect == keyboardRect) {
            return
        }
        
        let viewSize = self.view.bounds
        let padding:CGFloat = 10
        let btnHeight = paymentButton.frame.size.height
        if (keyboardRect.origin.y >= viewSize.height - btnHeight) { keyboardRect = CGRect.zero }
        oldKeyboardRect = keyboardRect
        
        
        if (!headerView.isHidden) {
            if (keyboardRect.origin.y > 0) {
                var kbdHeight = keyboardRect.size.height
                
                if (UIDevice.current.userInterfaceIdiom == .pad && kbdHeight > 200) {
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
    
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo,
            let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue else {
                return
        }
        
        relayoutViewsWithKeyboard(self.view.convert(keyboardRect, from: nil), animationDuration: duration)
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo,
            let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue else {
                return
        }
        
        relayoutViewsWithKeyboard(self.view.convert(keyboardRect, from: nil), animationDuration: duration)
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return (backgroundColor.isDark()) ? .lightContent : .default;
    }
    
    @objc open func dismissMe() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func togglePayButton() {
        //        let startAlpha = self.paymentButton.enabled ? 1.0 : 0.5
        let endAlpha:CGFloat = self.paymentButton.isEnabled ? 1.0 : 0.5
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.paymentButton.alpha = endAlpha
        }) 
    }
    
    open func paymentFieldChangedValidity(_ valid: Bool) {
        self.paymentButton.isEnabled = self.paymentFieldView.valid
        togglePayButton()
    }
    
        
    @objc open func payButtonPressed() {
        
    }
    
}
