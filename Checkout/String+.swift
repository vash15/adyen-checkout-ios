//
//  String+.swift
//  AdyenCheckout
//
//  Created by BELLUCO Michele Giorgio on 02/10/18.
//

import Foundation

// Ref: https://stackoverflow.com/a/31744226/1155718
extension String {
    func localized(lang:String? = nil, tableName:String? = nil) ->String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: tableName, bundle: bundle!, value: "", comment: "")
    }
}
