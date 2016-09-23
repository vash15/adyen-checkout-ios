Pod::Spec.new do |s|
  s.name             = "AdyenCheckout"
  s.version          = "0.0.4"
  s.summary          = "Adyen Checkout is a native library for accepting payments in-app."
  s.description      = "Adyen Checkout is a native library written in Swift for accepting payments in-app."

  s.homepage         = "https://github.com/Adyen/adyen-checkout-ios"
  s.license          = 'MIT'
  s.author           = { "Adyen" => "support@adyen.com" }
  s.source           = { :git => "https://github.com/Adyen/adyen-checkout-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Checkout/**/*'

  s.resources 	= ['Checkout.xcassets']

end
