Pod::Spec.new do |s|
  s.name             = "AdyenCheckout"
  s.version          = "0.0.1"
  s.summary          = "Adyen Checkout is a native library for accepting payments in-app."
  s.description      = "Adyen Checkout is a native library written in Swift for accepting payments in-app."

  s.homepage         = "https://github.com/Adyen/AdyenCheckout-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Taras Kalapun" => "t.kalapun@gmail.com" }
  s.source           = { :git => "https://github.com/Adyen/AdyenCheckout-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/Adyen'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Checkout/**/*'

  s.resources 	= ['Checkout.xcassets']

end
