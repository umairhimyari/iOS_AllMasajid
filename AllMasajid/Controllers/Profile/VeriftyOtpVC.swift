//
//  VeriftyOtpVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 27/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class VeriftyOtpVC: UIViewController {
    
    var emailPhoneCheck = 0 // 1 = Phone, 2 = Email

    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var otpTF: UITextField!
    @IBOutlet weak var otpView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didntReceiveOTPPressed(_ sender: UIButton) {
        networkHit()
    }
    
    @IBAction func continuePressed(_ sender: UIButton) {
        if otpTF.text != ""{
            networkHitVerify()
        }else{
            HUD.flash(.label("Please Enter OTP First"), delay: 0.6)
        }
    }
    
    func setupInitials(){
        otpView.cornerRadius = 25
        continueBtn.cornerRadius = 20
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {

        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension VeriftyOtpVC{
    
    func networkHit(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
        if emailPhoneCheck == 1 {
            APIRequestUtil.VerifyMobileOTP(headers: httpHeaders, completion: APIRequestCompleted)
        }else if emailPhoneCheck == 2 {
            APIRequestUtil.VerifyEmailOTP(headers: httpHeaders, completion: APIRequestCompleted)
        }
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key
            if firstResponseKey == "message"{
                let message = json["message"].stringValue
                HUD.flash(.labeledSuccess(title: "Message", subtitle: message), delay: 0.7)
            }else if firstResponseKey == "error"{
                let error = json["error"].stringValue
                HUD.flash(.labeledSuccess(title: "Error", subtitle: error), delay: 0.7)
            }
            /*
            let status_code = json["status_code"].intValue
            if status_code == 0{
                HUD.flash(.labeledError(title: "Message", subtitle: "Something Went Wrong"), delay: 0.6)

            }else if status_code == 1{
                HUD.flash(.labeledSuccess(title: "Success", subtitle: "OTP Sent"), delay: 0.6)
            }
            */
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.7)
        }
    }
}

extension VeriftyOtpVC{
    
    func networkHitVerify(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
        var type = ""
        if emailPhoneCheck == 1{
            type = "phone"
        }else if emailPhoneCheck == 2{
            type = "email"
        }
        
        APIRequestUtil.VerifyOTP(code: otpTF.text!, type: type, headers: httpHeaders, completion: APIRequestVerifyCompleted)
    }
    
    fileprivate func APIRequestVerifyCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key
            if firstResponseKey == "message"{
//                let message = json["message"].stringValue
                HUD.flash(.success, delay: 0.6){finished in
                    self.navigationController?.popViewController(animated: true)
                }
            }else if firstResponseKey == "error"{
                let error = json["error"].stringValue
                HUD.flash(.labeledSuccess(title: "Error", subtitle: error), delay: 0.7)
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
