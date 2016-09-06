//
//  Checkout.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/10/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

public let AdyenCheckoutErrorDomain = "com.adyen.checkout"


public protocol PaymentData {
    func serialize() throws -> String
}


public class Checkout {
    
    /// Use test Adyen Backend. Default: false
    public var useTestBackend = false
    
    /// Token to fetch the PublicKey
    public var token: String?
    
    /// Public Key (will be fetched by token)
    public var publicKey: String?
    
    
    public static let version = "1.0.0"
    
    public static let shared = Checkout()
    
    private init (){}

    /**
     Fetches the Public encryption key from Adyen backend
     
     - parameter completion: A closure that will provide the `publicKey` or `error`
     */
    public func fetchPublickKey(completion: ((publicKey: String?, error: NSError?) -> Void)) {
        if (token == nil) {
            completion(publicKey: nil, error: NSError(domain: AdyenCheckoutErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "Token is not set"]))
            return
        }
        
        let host = (useTestBackend) ? "test" : "live"
        let url = "https://\(host).adyen.com/hpp/cse/\(token!)/json.shtml"

        let request = NSURLRequest(URL: NSURL(string: url)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (resp, data, error) -> Void in
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if let key = jsonResult["publicKey"] as? String {
                    self.publicKey = key
                    completion(publicKey: key, error: nil)
                } else {
                    completion(publicKey: nil, error: NSError(domain: AdyenCheckoutErrorDomain, code: 400, userInfo: [NSLocalizedDescriptionKey: "Public key cannot be fetched"]))
                }
            }
            catch let error as NSError {
                completion(publicKey: nil, error: error)
            }
        }
    }
    
    /**
     Encrypts the PaymentData object and returns the encrypted data in the callback
     
     - parameter data: A `NSData` object
     - returns: String
     - throws: `NSError` of type `AdyenCheckoutErrorDomain`
     */
    public func encryptData(data: NSData) throws -> String {
        
        if (publicKey == nil) {
            throw NSError(domain: AdyenCheckoutErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "Public key not set"])
        }
        
        guard let enc = ADYCryptor.encrypt(data, keyInHex: publicKey!) else {
            throw NSError(domain: AdyenCheckoutErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Encryption error"])
        }
        
        return enc
    }
    
    /**
     Formats the price and currency according to locale. 
     Outputs formatted string.
     
     - parameter price: Price (5.99)
     - parameter currency: A currency identifier (EUR)
     */
    public func formatPrice(price: Double, currency: String) -> String {
        let locale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCurrencyCode: currency]))
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = locale
        
        // US$ -> $
        if (currency == "USD") {
            formatter.currencySymbol = "$"
        }
        
        return formatter.stringFromNumber(price)! // "123,44 €"
    }
    
}

//MARK - Extentions

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
    
    func numberOnly() -> String {
        return self.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch)
    }
}
