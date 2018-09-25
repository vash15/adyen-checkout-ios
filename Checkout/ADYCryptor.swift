//
//  ADYEncrypt.swift
//  Pods
//
//  Created by Taras Kalapun on 12/2/15.
//
//

import Foundation
import Security
//import CommonCrypto

open class ADYCryptor {
    static let prefix = "adyenan0_1_1"
    static let separator = "$"
    static let ivLength = 12
    
    static let key256Length = 32 //kCCKeySizeAES256
    
    /**
     *  Encrypts the data with AES-CBC using generated AES256 session key and IV (12).
     *  Encrypts the session key with RSA using public key (using Keychain)
     *
     *  - parameter data:     data to be encrypted
     *  - parameter keyInHex: Public key in Hex with format "Exponent|Modulus"
     *
     *  - returns: Fully composed message in format:
     *    - a prefix
     *    - a separator
     *    - RSA encrypted AES key, base64 encoded
     *    - a separator
     *    - a Payload of iv and cipherText, base64 encoded
     *
     */
    open class func encrypt(_ data: Data, keyInHex: String) -> String? {
        
        let key = secureRandomData(key256Length)
        let iv = secureRandomData(ivLength)
        
        guard let cipherText = aesEncrypt(data, key: key, iv: iv) else {
            return nil
        }
        
        guard let encryptedKey = rsaEncrypt(key, keyInHex: keyInHex) else {
            return nil
        }
        
        // format of the fully composed message:
        // - a prefix
        // - a separator
        // - RSA encrypted AES key, base64 encoded
        // - a separator
        // - a Payload of iv and cipherText, base64 encoded
        let payload = NSMutableData();
        payload.append(iv)
        payload.append(cipherText)
        
        
        //NSString *result = nil;
        
        let fullPrefix = (prefix.characters.count == 0) ? "" : "\(prefix)\(separator)"
        
        let encryptedKeyB64 = encryptedKey.base64EncodedString(options: [])
        let payloadB64 = payload.base64EncodedString(options: [])
        
        let result = "\(fullPrefix)\(encryptedKeyB64)\(separator)\(payloadB64)"
        return result;
    }
    
    open class func secureRandomData(_ length: Int) -> Data {
        var keyData = Data(count: length)
        let _ = keyData.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, mutableBytes)
        }
        
        return keyData
    }
    
    open class func aesEncrypt(_ data: Data, key: Data
        , iv: Data) -> Data? {
        return TKAESCCMCryptor.encrypt(data, withKey: key, iv: iv)

    }
    
    open class func rsaEncrypt(_ data: Data, keyInHex: String) -> Data? {
        return TKRSACryptor.encrypt(data, withKeyInHex: keyInHex)
    }
    
   
}


extension String {

    var hexadecimal: Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else {
            return nil
        }
        
        return data
    }
    
    init?(hexadecimal string: String) {
        guard let data = string.hexadecimal else { return nil }
        
        self.init(data: data, encoding: .utf8)
    }
    
    var hexadecimalString: String? {
        return data(using: .utf8)?.hexadecimal
    }
}

extension Data {
    
    /// Create hexadecimal string representation of `Data` object.
    ///
    /// - returns: `String` representation of this `Data` object.
    
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }.joined(separator: "")
    }
}
