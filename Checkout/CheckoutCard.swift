//
//  CheckoutCard.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

/// Supported card types
public enum CardType: String {
    
    /// MARK: Cards
    
    /// Unknown card type
    case Unknown
    
    /// Amex card type
    case Amex
    
    /// Visa card type
    case Visa
    
    /// MasterCard card type
    case MasterCard
    
    /// Diners card type
    case Diners
    
    /// Discover card type
    case Discover
    
    /// JCB card type
    case JCB
    
    /// Elo card type
    case Elo
    
    /// Hipercard card type
    case Hipercard
    
    /// UnionPay card type
    case UnionPay
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]
    
    /// MARK: Utility functions
    
    var imageName : String {
        let type = self.rawValue.lowercased()
        return "card_" + type
    }
    

    
    /// Returns RegEx matching string for current card
    public var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189|2[2-7][0-9]{4})[0-9]{5,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
        case .Hipercard:
            return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
            return ""
        }
    }
}


/// A Card `PaymentData` object
open class CardPaymentData: PaymentData {
    /// Card number
    var number: String
    
    /// Card CVC
    var cvc: String
    
    /// Expiration Date MMYY
    var expirationDate: String
    
    /// Card holder name, optional
    var name: String?
    
    public init(number: String, cvc: String, expirationDate: String, name: String?) {
        self.number = number
        self.cvc = cvc
        self.expirationDate = expirationDate
        self.name = name
    }
    
    open func serialize() throws -> String {
        var d = [String: String]()
        d["number"] = number.numberOnly()
        d["cvc"] = cvc.numberOnly()
        
        let (_, _, month, year) = CardValidation.checkExpirationDate(expirationDate)
        
        d["expiryMonth"] = month
        d["expiryYear"] = year
        
        
        if (name != nil) {
            d["holderName"] = name
        }
        
        d["generationtime"] = generationTime()
        
        
        do {
            let JSON = try JSONSerialization.data(withJSONObject: d, options: [])
            let data = try Checkout.shared.encryptData(JSON)
            return data
        }
        catch let error as NSError {
            throw error
        }
        
    }
    
    func generationTime() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return df.string(from: Date())
    }

}


open class CardValidation {
    
    
    static func matchesRegex(_ regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    
    open static func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.characters.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    
    open static func checkCardNumber(_ input: String) -> (type: CardType, formatted: String, valid: Bool) {
        let numberOnly = input.numberOnly()
        
        var type: CardType = .Unknown
        var formatted = ""
        var valid = false
        
        for card in CardType.allCards {
            if (matchesRegex(card.regex, text: numberOnly)) {
                type = card
                break
            }
        }
        
        valid = luhnCheck(numberOnly)
        
        // If card number length is more than 8 and we are still not able to determine its type and treated that card as Unknown but luhncheck algorithm always gives wrong value and treat as valid checksum. Make it forcefully invalid based on this check so field can be highlighted red.
        
        if(numberOnly.characters.count >= 8 && type.rawValue == "Unknown" && valid)
        {
            valid = false
        }
        
        var formatted4 = ""
        for character in numberOnly.characters {
            if formatted4.characters.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        
        formatted += formatted4 // the rest
        
        return (type, formatted, valid)
    }
    
    open static func checkExpirationDate(_ input: String, split: Bool = true) -> (formatted: String, valid: Bool, month: String, year: String) {
        let suffix = (split) ? " / " : ""
        
        let numberOnly = input.numberOnly()
        var formatted = numberOnly
        var valid = false
        var month = 0
        var year = 0
        
        let yearPrefix = "20"
        
        switch numberOnly.characters.count {
        case 0: break
        case 1:
            month = Int(numberOnly)!
            if month > 1 {
                formatted = "0" + numberOnly + suffix
            }
            
        case 2:
            month = Int(numberOnly)!
            formatted = numberOnly + suffix
        case 3:
            month = Int(numberOnly[0...1])!
            formatted = numberOnly[0...1] + suffix + numberOnly[2]
        case 4:
            month = Int(numberOnly[0...1])!
            year = Int(yearPrefix + numberOnly[2...3])!
            formatted = numberOnly[0...1] + suffix + numberOnly[2...3]
        default:
            break
        }
        
        let validMonth = (month >= 1 && month <= 12) ? true : false
        //valid = validMonth
        
        if (month > 12) {
            formatted = ""
        }
        
        if year > 0 {
            let date = Date()
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.month, .year], from: date)
            let currentYear = components.year
            let currentMonth = components.month
            
            // year already has "20"+ here
            if (year == currentYear! && month < currentMonth!) {
                valid = false
            } else if (year == currentYear! && validMonth && month >= currentMonth!) {
                valid = true
            } else if (year > currentYear! && validMonth) {
                valid = true
            } else {
                valid = false
            }
        }
        
        return (formatted, valid, String(month), String(year))
    }
    
}

extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
}
