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


open class Checkout {
    
    /// Use test Adyen Backend. Default: false
    open var useTestBackend = false
    
    /// Token to fetch the PublicKey
    open var token: String?
    
    /// Public Key (will be fetched by token)
    open var publicKey: String?
    
    
    open static let version = "1.0.0"
    
    open static let shared = Checkout()
    
    fileprivate init (){}

    /**
     Fetches the Public encryption key from Adyen backend
     
     - parameter completion: A closure that will provide the `publicKey` or `error`
     */
    open func fetchPublicKey(_ completion: @escaping ((_ publicKey: String?, _ error: NSError?) -> Void)) {
        if (token == nil) {
            completion(nil, NSError(domain: AdyenCheckoutErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "Token is not set"]))
            return
        }
        
        let host = (useTestBackend) ? "test" : "live"
        let url = "https://\(host).adyen.com/hpp/cse/\(token!)/json.shtml"

        let request = URLRequest(url: URL(string: url)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (resp, data, error) -> Void in
            if let error = error {
                completion(nil, error as? NSError)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                if let key = (jsonResult as? [String: AnyObject])?["publicKey"] as? String {
                    self.publicKey = key
                    completion(key, nil)
                } else {
                    completion(nil, NSError(domain: AdyenCheckoutErrorDomain, code: 400, userInfo: [NSLocalizedDescriptionKey: "Public key cannot be fetched"]))
                }
            }
            catch let error as NSError {
                completion(nil, error)
            }
        }
    }
    
    /**
     Encrypts the PaymentData object and returns the encrypted data in the callback
     
     - parameter data: A `NSData` object
     - returns: String
     - throws: `NSError` of type `AdyenCheckoutErrorDomain`
     */
    open func encryptData(_ data: Data) throws -> String {
        
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
    open func formatPrice(_ price: Double, currency: String) -> String {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currency]))
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        
        // US$ -> $
        if (currency == "USD") {
            formatter.currencySymbol = "$"
        }
        
        return formatter.string(from: NSNumber(value: price))! // "123,44 €"
    }
    
}

// MARK - Extentions

extension String {
    
//    subscript (i: Int) -> Character {
//        return self[self.characters.index(self.startIndex, offsetBy: i)]
//    }
//    
//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }
//    
//    subscript (r: Range<Int>) -> String {
//        return substring(with: (characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound)))
//    }
//    
    func numberOnly() -> String {
        return self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}
