//
//  CheckoutCardUI.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

open class CardNumberField: CheckoutTextField {
    var card = CardType.Unknown {
        didSet {
            resetCard()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .numberPad
        self.placeholder = "Card number"
        
        
        let pIV = self.placeholderImageView
        
        pIV.layer.borderColor = UIColor.adyTextGreyColor.cgColor
        
        pIV.layer.borderWidth = 1
        pIV.layer.cornerRadius = 2
        resetCard()
    }
    func resetCard() {
        let img = _bundleImage(card.imageName)
        UIView.transition(with: self.placeholderImageView, duration: 0.2, options: .transitionCrossDissolve, animations: { () -> Void in
            self.placeholderImageView.image = img
            }, completion: nil)
    }
}

open class CardExpirationField: CheckoutTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .numberPad
        self.placeholder = "MM/YY"
        
        let img = _bundleImage("expiration_date")
        self.placeholderImageView.clipsToBounds = false
        self.placeholderImageView.image = img
        
        // Nice thingie - adding a current date on top of image
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        
        let dayLabel = UILabel(frame: CGRect(x: 4, y: 4, width: self.placeholderImageView.bounds.size.width, height: 20))
        dayLabel.backgroundColor = UIColor.clear
        dayLabel.textAlignment = .center
        dayLabel.textColor = UIColor.adyTextGreyColor
        dayLabel.font = UIFont.systemFont(ofSize: 10)
        if let day = components.day {
            dayLabel.text = String(day)
        }
        self.placeholderImageView.addSubview(dayLabel)
    }
}

open class CardCvcField: CheckoutTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .numberPad
        self.placeholder = "CVC"
        self.isSecureTextEntry = true
        
        let img = _bundleImage("cvc_code")
        self.placeholderImageView.clipsToBounds = false
        self.placeholderImageView.image = img
        //self.placeholderImageView.backgroundColor = UIColor.redColor()
    }
}

open class CardNameField: CheckoutTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .asciiCapable
        self.autocorrectionType = .no
        self.placeholder = "Card holder name"
        
        let img = _bundleImage("cardholder")
        self.placeholderImageView.clipsToBounds = false
        self.placeholderImageView.image = img
    }
}

open class CardPaymentField: CheckoutPaymentFieldView, UITextFieldDelegate {
    
    
    open var showNameField = true
    
    let sidePadding:CGFloat = 8;
    let fieldPadding:CGFloat = 2;
    let fieldHeight:CGFloat = 44;
    
    open let numberField = CardNumberField(frame: CGRect.zero)
    open let expirationField = CardExpirationField(frame: CGRect.zero)
    open let cvcField = CardCvcField(frame: CGRect.zero)
    open let nameField = CardNameField(frame: CGRect.zero)
    
    let topLine = UIView(frame: CGRect.zero)
    let middleLine = UIView(frame: CGRect.zero)
    let middleLine2 = UIView(frame: CGRect.zero)
    let splitLine = UIView(frame: CGRect.zero)
    let bottomLine = UIView(frame: CGRect.zero)
    
    
    
    convenience init() {
        self.init(frame: CGRect.zero)
        //        self.translatesAutoresizingMaskIntoConstraints = true
        let height = fieldPadding + fieldHeight + fieldPadding + fieldHeight + fieldPadding + fieldHeight + fieldPadding
        let frame = CGRect(x: 0, y: 0, width: 320, height: height)
        self.frame = frame;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        numberField.delegate = self
        expirationField.delegate = self
        cvcField.delegate = self
        
        self.addSubview(numberField)
        self.addSubview(expirationField)
        self.addSubview(cvcField)
        
        self.addSubview(topLine)
        self.addSubview(middleLine)
        
        self.addSubview(bottomLine)
        self.addSubview(splitLine)
        
        //        if (showNameField) {
        self.addSubview(nameField)
        self.addSubview(middleLine2)
        //        }
        
        let borderColor = UIColor.adyGreyColor
        for bv in [topLine, middleLine, middleLine2, bottomLine, splitLine] {
            bv.backgroundColor = borderColor
        }
        
        self.layoutSubviews()
    }
    
    open override func paymentData() -> PaymentData {
        // Consider if this method should validate inputs and be able to throw
        
        let number = numberField.text ?? ""
        let cvc = cvcField.text ?? ""
        let expirationDate = expirationField.text ?? ""
        let name = nameField.text
        
        let card = CardPaymentData(number: number, cvc: cvc, expirationDate: expirationDate, name: name)
        return card
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func layoutSubviews() {
        guard let sView = self.superview else { return }
        
        //    public override func willMoveToSuperview(newSuperview: UIView?) {
        
        
        let sFrame = sView.bounds
        
        
        //let maxHeight = padding + fieldHeight + padding + fieldHeight + padding
        let maxWidth = sFrame.size.width
        let borderThickness: CGFloat = 1
        
        var newFrame = self.frame
        newFrame.size.width = maxWidth
        
        self.frame = newFrame //CGRect(x: oldFrame., y: 80, width: maxWidth, height: maxHeight)
        
        var bFrame = CGRect(x: 0, y: 0, width: maxWidth, height: borderThickness)
        topLine.frame = bFrame
        
        var frame = CGRect(x: sidePadding, y: fieldPadding, width: maxWidth, height: fieldHeight)
        frame.size.width -= sidePadding*2
        
        if (showNameField) {
            nameField.isHidden = false
            middleLine2.isHidden = false
            
            nameField.frame = frame
            
            bFrame.origin.y = frame.origin.y + frame.size.height + fieldPadding / 2
            middleLine2.frame = bFrame
            
            frame.origin.y += frame.size.height + fieldPadding
        } else {
            nameField.isHidden = true
            middleLine2.isHidden = true
        }
        
        numberField.frame = frame
        
        bFrame.origin.y = frame.origin.y + frame.size.height + fieldPadding / 2
        middleLine.frame = bFrame
        
        frame.origin.y += frame.size.height + fieldPadding
        frame.size.width = maxWidth/2 - sidePadding - sidePadding/2
        expirationField.frame = frame
        
        frame.origin.x += frame.size.width - 10 //+ fieldPadding
        cvcField.frame = frame
        
        bFrame.origin.y = frame.origin.y + frame.size.height + fieldPadding / 2
        bottomLine.frame = bFrame
        
        splitLine.frame = CGRect(x: expirationField.frame.origin.x + expirationField.frame.size.width, y: middleLine.frame.origin.y, width: borderThickness, height: bottomLine.frame.origin.y - middleLine.frame.origin.y)
        
        var totalHeight = fieldPadding + fieldHeight + fieldPadding + fieldHeight + fieldPadding
        
        if (showNameField) {
            totalHeight += fieldHeight + fieldPadding
            self.nameField.becomeFirstResponder()
        } else {
            self.numberField.becomeFirstResponder()
        }
        
        self.frame.size.height = totalHeight
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let numberOnly = newString.numberOnly()
        
        let isDeleating = (string.characters.count == 0 && range.length == 1)
        
        if textField == self.numberField {
            let (type, formatted, valid) = CardValidation.checkCardNumber(numberOnly)
            
            self.numberField.valid = valid
            self.numberField.card = type
            textField.text = formatted
            //textField.textColor = (valid) ? UIColor.blackColor() : UIColor.redColor()
            
            self.valid = (self.numberField.valid && self.expirationField.valid && self.cvcField.valid)
            
            //            delegate?.fieldChangedValue(self.numberField, valid: valid)
            delegate?.paymentFieldChangedValidity(valid)
        } else if textField == self.expirationField {
            
            let (formatted, valid, _, _) = CardValidation.checkExpirationDate(newString, split: !isDeleating)
            
            self.expirationField.valid = valid
            
            if (numberOnly.characters.count <= 4) {
                textField.text = formatted
            }
            
            self.valid = (self.numberField.valid && self.expirationField.valid && self.cvcField.valid)
            
            //delegate?.fieldChangedValue(self.expirationField, valid: valid)
            delegate?.paymentFieldChangedValidity(valid)
        }
        else if textField == self.cvcField
        {
            self.cvcField.valid = (numberOnly.characters.count >= 3)
            
            if (newString.characters.count <= 4)
            {
                textField.text = newString
                
                self.valid = (self.numberField.valid && self.expirationField.valid && self.cvcField.valid)
                delegate?.paymentFieldChangedValidity(valid)
            }
            
        }
        
        return false
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.numberField) {
            textField.textColor = UIColor.darkText
        }
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == self.numberField && textField.text != nil) {
            let (_, _, valid) = CardValidation.checkCardNumber(textField.text!)
            textField.textColor = (valid) ? UIColor.darkText : UIColor.red
        } else if (textField == self.expirationField && textField.text != nil) {
            let (_, valid, _, _) = CardValidation.checkExpirationDate(textField.text!, split: true)
            textField.textColor = (valid) ? UIColor.darkText : UIColor.red
        }
    }
    
}
