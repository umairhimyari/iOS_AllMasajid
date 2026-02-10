//
//  ForgetPasswordVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 29/04/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON

class ForgetPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if emailTextField.text! == "" {
            HUD.flash(.label("Please Enter Valid Email"), delay: 0.7)
        }else{
            if emailTextField.text!.isValidEmail(){
                networkHit()
            }else{
                HUD.flash(.label("Please Enter Valid Email"), delay: 0.7)
            }
        }
    }
}

extension ForgetPasswordVC{

    func networkHit(){
        HUD.show(.progress)
        // Trim whitespace from email before sending
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let parameters = ["email": email]
        APIRequestUtil.ForgetPassword(parameters: parameters, completion: APIRequestCompleted)
    }

    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)

            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error"{
                let error = json["error"].stringValue
                HUD.flash(.labeledError(title: "Error", subtitle: error), delay: 1.5)
            } else if firstResponseKey == "message"{
                let message = json["message"].stringValue
                // Show the actual server message if available, otherwise show default
                let displayMessage = message.isEmpty ? "We have sent password reset instructions to your email. Please check your inbox and spam folder." : message
                HUD.flash(.labeledSuccess(title: "Success", subtitle: displayMessage), delay: 2.0){ finished in
                    self.navigationController?.popViewController(animated: true)
                }
            } else if firstResponseKey == "success" {
                // Handle alternative success response format
                HUD.flash(.labeledSuccess(title: "Success", subtitle: "Password reset email sent. Please check your inbox and spam folder."), delay: 2.0){ finished in
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                // Unknown response format - show generic message
                HUD.flash(.labeledError(title: "Error", subtitle: "Unexpected response. Please try again."), delay: 1.5)
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please check your internet connection and try again."), delay: 1.5)
        }
    }
}
