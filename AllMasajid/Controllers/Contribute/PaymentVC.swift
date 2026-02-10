//
//  PaymentVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 24/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
//import Stripe

class PaymentVC: UIViewController {

//    lazy var cardTextField: STPPaymentCardTextField = {
//        let cardTextField = STPPaymentCardTextField()
//        cardTextField.postalCodePlaceholder = "postal"
//        return cardTextField
//    }()
//    lazy var payButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.layer.cornerRadius = 5
//        button.backgroundColor = .systemBlue
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
//        button.setTitle("Pay", for: .normal)
//        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
//        return button
//    }()

//    var paymentIntentClientSecret: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
//        stackView.axis = .vertical
//        stackView.spacing = 20
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
//            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
//            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2),
//        ])
//        startCheckout()
    }
    
//    @objc
//    func pay() {
//        print("Here")
//        guard let paymentIntentClientSecret = paymentIntentClientSecret else {
//            return;
//        }
//        print("Inside")
//        // Collect card details
//        let cardParams = cardTextField.cardParams
//        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
//        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
//        paymentIntentParams.paymentMethodParams = paymentMethodParams
//
//        // Submit the payment
//        let paymentHandler = STPPaymentHandler.shared()
//        paymentHandler.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
//            switch (status) {
//            case .failed:
//                print("Payment failed")
////                self.displayAlert(title: "Payment failed", message: error?.localizedDescription ?? "")
//                break
//            case .canceled:
//                print("Payment canceled")
////                self.displayAlert(title: "Payment canceled", message: error?.localizedDescription ?? "")
//                break
//            case .succeeded:
//                print("Payment succeeded")
////                self.displayAlert(title: "Payment succeeded", message: paymentIntent?.description ?? "", restartDemo: true)
//                break
//            @unknown default:
//                fatalError()
//                break
//            }
//        }
//    }
//    
//
//    func startCheckout() {
//        // Request a PaymentIntent from your server and store its client secret
//        // Click Open on GitHub to see a full implementation
//        paymentIntentClientSecret = Secrets.stripeSecretKey
//    }
    

}

//extension PaymentVC: STPAuthenticationContext {
//    func authenticationPresentingViewController() -> UIViewController {
//        return self
//    }
//}
