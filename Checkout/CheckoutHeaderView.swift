//
//  CheckoutHeaderView.swift
//  Checkout
//
//  Created by Taras Kalapun on 11/25/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

public class CheckoutHeaderView: UIView {
    
    public var logoImage: UIImage? // default is nil
    public var titleText: String?
    public var subtitleText: String?
    public var textColor = UIColor?()
    
    let imageView = UIImageView()
    public let titleLabel = UILabel()
    public let detailLabel = UILabel()
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    public func commonInit() {
        
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        titleLabel.textColor = textColor
        titleLabel.font = UIFont.boldSystemFontOfSize(20)
        //titleLabel.textAlignment = .Center
        titleLabel.text = self.titleText
        //titleLabel.backgroundColor = UIColor.redColor()
        self.addSubview(titleLabel)
        
        detailLabel.textColor = textColor
        detailLabel.font = UIFont.systemFontOfSize(14)
        //detailLabel.textAlignment = .Center
        detailLabel.text = self.subtitleText
        //detailLabel.backgroundColor = UIColor.greenColor()
        self.addSubview(detailLabel)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if (textColor == nil) {
            var isDarkBg = false
            if (self.backgroundColor != nil) {
                isDarkBg = backgroundColor!.isDark()
            }
            textColor = (isDarkBg) ? UIColor.whiteColor() : UIColor.darkTextColor()
        }
        
        titleLabel.textColor = textColor
        detailLabel.textColor = textColor
        
        // Set values
        
        if (logoImage != nil) {
            imageView.image = logoImage
        }
        
        if (titleText != nil) {
            titleLabel.text = titleText
        }
        
        if (subtitleText != nil) {
            detailLabel.text = subtitleText
        }
        
        // Set frame
        
        if (self.frame.size.height == 0) {
            self.frame.size.height = 100
        }
        
        guard let maxW = self.superview?.bounds.size.width else {
            return
        }
        
        //let vPadding: CGFloat = 5 //(self.view.bounds.height < 600) ? 5 : 10
        let padding: CGFloat = 30
        
        var imgSize = CGSize(width: 100, height: 80)
        if (self.frame.size.height - 16 < imgSize.height) {
            imgSize.height = self.frame.size.height - 16
        }
        
        let topY: CGFloat = (self.frame.size.height - imgSize.height) / 2
        
        var frame = CGRect.zero
        frame.origin.x = padding
        frame.origin.y = topY
        frame.size.width = maxW - padding * 2
        
        imageView.frame.origin = frame.origin
        imageView.frame.size = imgSize
        
        let textX = (imageView.image == nil) ? padding : imageView.frame.origin.x + imgSize.width + padding
        
        frame.origin.x = textX
        frame.origin.y += 20
        frame.size.width -= imgSize.width
        
        frame.size.height = 22
        titleLabel.frame = frame
        
        frame.origin.y += frame.size.height
        frame.size.height = 16
        detailLabel.frame = frame
        
        self.frame.size.width = maxW
        
        //imageView.backgroundColor = UIColor.redColor()
    }
}
