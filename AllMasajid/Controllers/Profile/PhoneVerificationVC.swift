//
//  PhoneVerificationVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 27/04/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SafariServices
import SwiftyJSON
import CountryPickerView
import FirebaseAuth

class PhoneVerificationVC: UIViewController {
    
    var phoneNumber = ""
    var phoneCode = "+92"
    
    var passedTime = 0
    var totalTime = 60
    var myFirstTimer : Timer?

    var myVerificationID = ""

    @IBOutlet weak var cpView: CountryPickerView!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var otpTF: UITextField!
    
    @IBOutlet weak var requestOtpBTN: UIButton!
    @IBOutlet weak var timerLBL: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        phoneNumberTF.text = phoneNumber
        phoneNumberTF.isEnabled = false
        setupCountryCode()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {

        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }

    @IBAction func requestOTPPressed(_ sender: UIButton) {
        
        if passedTime == 0 {
            requestOtpBTN.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            requestOtpBTN.setTitle("Resend OTP", for: .normal)
            
            HUD.show(.progress)

            PhoneAuthProvider.provider().verifyPhoneNumber("\(phoneCode)\(phoneNumber)", uiDelegate: nil) { (verificationID, error) in
                HUD.hide()
                if let error = error {

                    print(error.localizedDescription)
                    HUD.flash(.label("Invalid Entry, Please Try Again"), delay: 1.0)
                    return
                }
                self.myFirstTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startWaitTimer), userInfo: nil, repeats: true)
                HUD.flash(.labeledSuccess(title: "Success", subtitle: "OTP sent to phone number"), delay: 1.0)
                self.myVerificationID = verificationID ?? ""
                print("Success: \(String(describing: verificationID))")
            }
        }
    }
    
    @IBAction func verifyOtpPressed(_ sender: UIButton) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: myVerificationID,
                                                                 verificationCode: otpTF.text!)
        HUD.show(.progress)
        Auth.auth().signIn(with: credential) { (authData, error) in
            HUD.hide()
            if error != nil {
                HUD.flash(.label("Network Error, Please Try Again Later"), delay: 1.0)
                print(error.debugDescription)
            }else{
                self.networkHitVerify()
                print("Auth success \(String(describing: authData?.user.phoneNumber))")
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PhoneVerificationVC: CountryPickerViewDataSource, CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        phoneCode = country.phoneCode
    }
    
    func setupCountryCode(){
        cpView.delegate = self
        cpView.dataSource = self
        cpView.font =  UIFont.systemFont(ofSize: 14)
        cpView.textColor = .white
        cpView.setCountryByPhoneCode("+92")
        cpView.flagSpacingInView = 2
    }
}


extension PhoneVerificationVC{
    
    func networkHitVerify(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
//        print(headers)
        APIRequestUtil.VerifyCodeOTP(parameters: ["status": "1", "contact": phoneNumber], headers: httpHeaders, completion: APIRequestVerifyCompleted)
    }
    
    fileprivate func APIRequestVerifyCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let message = json["message"].stringValue
            HUD.flash(.label(message), delay: 1.0) { finished in
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension PhoneVerificationVC {
    
    @objc func startWaitTimer(){

        if passedTime >= totalTime {
            DispatchQueue.main.async {
                self.stopWaitTimer()
            }
        }else{
            passedTime = passedTime + 1
            timerLBL.text = "\(totalTime - passedTime):00"
        }
    }
    
    func stopWaitTimer() {
        if myFirstTimer != nil {
            self.myFirstTimer?.invalidate()
            self.myFirstTimer = nil
            requestOtpBTN.backgroundColor = #colorLiteral(red: 0, green: 0.5254901961, blue: 0.8862745098, alpha: 1)
            timerLBL.text = "60:00"
            passedTime = 0
        }
    }
}
