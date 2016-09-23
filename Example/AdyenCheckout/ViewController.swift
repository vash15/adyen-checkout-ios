//
//  ViewController.swift
//  CheckoutExample
//
//  Created by Taras Kalapun on 11/10/15.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit
import AdyenCheckout

class ViewController: UITableViewController, CheckoutViewControllerDelegate {

    let items = [
        [
            "mode": "modal",
            "title": "Nike",
            "amount": 5.99,
            "currency": "USD",
            "img": "NikeLogo",
            "color": UIColor(red: 0.306, green: 0.573, blue: 0.875, alpha: 1)
        ],
        [
            "mode": "modal",
            "title": "Nespresso",
            "amount": 0.99,
            "currency": "EUR",
            "img": "NespressoLogo",
            "color": UIColor(red: 0.267, green: 0.267, blue: 0.267, alpha: 1)
        ],
        [
            "mode": "modal",
            "title": "AirBnb",
            "amount": 1999.99,
            "currency": "CAD",
            "img": "AirbnbLogo",
            "color": UIColor(red: 1, green: 0.353, blue: 0.373, alpha: 1)
        ],
        [
            "mode": "modal",
            "title": "Pink!",
            "amount": 4.99,
            "currency": "EUR",
            "color": UIColor(red: 1, green: 0.624, blue: 0.824, alpha: 1)
        ],
        [
            "mode": "modal",
            "showCardholder": false,
            "title": "No Cardholder field",
            "amount": 1.99,
            "currency": "GBP",
            "img": "NikeLogo",
        ],
        [
            "mode": "modal",
            "title": "AUD",
            "amount": 4.99,
            "currency": "AUD",
            "color": UIColor.darkGray
        ],
//        [
//            "mode": "push",
//            "title": "Adyen checkout",
//            "img": "",
//            "color": UIColor.blueColor()
//        ]
    ]

    func delay(_ delay: Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        Checkout.shared.publicKey = "10001|8D26B36C0BBA9CE4D17BA0DB20AF19563A82849A8BCEB03A5B3" +
//        "FAE597865AF9E552D23E680015AC996CA15E1690D3A20E98E6408BB456130FBEAD9E4F1DE5102C483" +
//        "E389483D7D51F34A5E61CBF77DDD3E5894F744D6C49B36271ECDE7E473622683090471B50FADE6EA5" +
//        "D72FCD44AA753AAD7145C82D2C8F204A4612DF8A5168F0836ACD87D78C1B1C1EBE34D64FA75FB2098" +
//            "2BDA4163DA7FC6CA4A5532394E8174340C2A7BC7E53C2B3041C9D2BC6B0A0EE8A6CE888895AA5ACD0" +
//        "8F900CBD0C348B9818B3169D7E77EEFCE556A3C8AAC77094320B8C000E036020516FD54DC4BAF9CF2221" +
//        "5236A76C42DC3AAC97FE72D3273FB6AC64D80E1905AED55908A79"

        Checkout.shared.useTestBackend = true
        Checkout.shared.token = "8714279602311541"

        delay(0.5) {
            self.tableView(self.tableView,
                           didSelectRowAt: IndexPath(row: 0, section: 0))
        }
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell?.accessoryType = .disclosureIndicator
        }

        let item = items[(indexPath as NSIndexPath).row]

        if let title = item["title"] as? String {
            cell?.textLabel?.text = title
        } else {
            cell?.textLabel?.text = ""
        }

        if let amount = item["amount"] as? Double, let currency = item["currency"] as? String {
            cell?.detailTextLabel?.text = Checkout.shared.formatPrice(amount, currency: currency)
        } else {
            cell?.detailTextLabel?.text = ""
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[(indexPath as NSIndexPath).row]

        let request = CheckoutRequest()
        if let amount = item["amount"] as? Double {
            request.amount = amount
        }
        if let currency = item["currency"] as? String {
            request.currency = currency
        }
        if let title = item["title"] as? String {
            request.reference = "Ref: " + title
        }

        let vc = CheckoutCardViewController(checkoutRequest: request)
        vc.delegate = self

        if let title = item["title"] as? String {
            vc.titleText = title
        }

        if let color = item["color"] as? UIColor {
            vc.backgroundColor = color
        }

        if let imageName = item["img"] as? String {
            vc.logoImage = UIImage(named: imageName)
        }

        if let showCardholder = item["showCardholder"] as? Bool {
            vc.showCardholderNameField = showCardholder
        }


        if let mode = item["mode"] as? String {
            if mode == "modal" {
                let nc = UINavigationController(rootViewController: vc)
                nc.modalPresentationStyle = .formSheet
                self.present(nc, animated: true, completion: nil)
            } else if mode == "push" {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    // Custom method to send payment to merchant server
    func sendPayment(_ payment: CheckoutPayment,
                     completionHandler handler: @escaping (_ psp: String?, NSError?) -> Void) {
        var d = [String: AnyObject]()

        d["reference"]   = payment.reference as AnyObject?
        d["amount"]      = payment.amount as AnyObject?
        d["currency"]    = payment.currency as AnyObject?
        d["paymentData"] = payment.paymentData as AnyObject?

        do {
            let JSON = try JSONSerialization.data(withJSONObject: d, options: [])
            let requestUrlString = "https://merchant-pay.parseapp.com/payment"
            let request = NSMutableURLRequest(url: URL(string: requestUrlString)!)
            request.httpMethod = "POST"
            request.httpBody = JSON
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            NSURLConnection.sendAsynchronousRequest(request as URLRequest,
                                                    queue: OperationQueue.main) {
                                                        (resp, data, error) -> Void in
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                    if let psp = jsonResult?["pspReference"] as? String {
                        handler(psp, error as? NSError)
                    } else if let message = jsonResult?["message"] as? String {
                        handler(nil,
                                NSError(domain: "com.Adyen.Checkout",
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: message]))
                    } else {
                        handler(nil, error as NSError?)
                    }
                } catch let error as NSError {
                    handler(nil, error)
                }
            }
        } catch let error as NSError {
            handler(nil, error)
        }
    }

    func checkoutViewController(_ controller: CheckoutViewController,
                                authorizedPayment payment: CheckoutPayment) {
        sendPayment(payment) { (psp, error) -> Void in
            controller.dismiss(animated: true, completion: nil)
            if error != nil {
                let alert = UIAlertView(title: "Error",
                                        message: error!.localizedDescription,
                                        delegate: nil,
                                        cancelButtonTitle: "OK")
                alert.show()
            } else {
                let alert = UIAlertView(title: "Success!",
                                        message: "PSP: \(psp!)",
                                        delegate: nil,
                                        cancelButtonTitle: "OK")
                alert.show()
            }
        }

    }

    func checkoutViewController(_ controller: CheckoutViewController,
                                failedWithError error: NSError) {
        controller.dismiss(animated: true) {
            let alert = UIAlertView(title: "Error",
                                    message: error.localizedDescription,
                                    delegate: nil,
                                    cancelButtonTitle: "OK")
            alert.show()
        }
    }

}
