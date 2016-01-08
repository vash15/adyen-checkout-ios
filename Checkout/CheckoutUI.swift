//
//  CheckoutUI.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/10/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

func _bundleImage(name: String) -> UIImage? {
    let imgPrefix = "ady_"
    let path = imgPrefix + name
    let bundle = NSBundle(forClass: Checkout.self)
    
    let img = UIImage(named: path, inBundle: bundle, compatibleWithTraitCollection: nil)
    return img
}



extension UIColor {
    
    class var adyTextGreyColor:UIColor { return UIColor(hex: "878787") }
    class var adyGreyColor:UIColor { return UIColor(hex: "DADCDF") }
    class var adyGreenColor:UIColor { return UIColor(hex: "25b72e") }
    
    convenience init(hex: String) {
        let hex = hex.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /**
     Returns a lighter color by the provided percentage
     
     :param: lighting percent percentage
     :returns: lighter UIColor
     */
    func lighterColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 + percent));
    }
    
    /**
     Returns a darker color by the provided percentage
     
     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darkerColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 - percent));
    }
    
    /**
     Return a modified color using the brightness factor provided
     
     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
    
    func isDark() -> Bool {
        var red:CGFloat = 0.0, green:CGFloat = 0.0, blue:CGFloat = 0.0, alpha:CGFloat = 0.0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let colorBrightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        
        return (colorBrightness < 0.6)
    }
}
