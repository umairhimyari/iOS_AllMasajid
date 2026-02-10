//
//  FanInformationVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 12/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import Alamofire

class FanInformationVC: UIViewController {
    
    var recMasjidID = ""
    var recName = ""
    var recPhone = ""
    var recEmail = ""
    var recAddress = ""
    
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var contactLBL: UIButton!
    @IBOutlet weak var emailLBL: UIButton!
    
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var taxNoTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var amountTF: UITextField!
    
    @IBOutlet weak var noteTV: UITextView!
    
    @IBOutlet weak var payment1BTN: UIButton!
    @IBOutlet weak var payment2BTN: UIButton!
    @IBOutlet weak var payment3BTN: UIButton!
    @IBOutlet weak var payment4BTN: UIButton!
    @IBOutlet weak var payment5BTN: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var continueBtnView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func amountPressed(_ sender: UIButton) {
        
        neutralBtnColors()
        
        if sender.tag == 1{
            amountTF.text = "10"
            amountTF.isEnabled = false
        }else if sender.tag == 2{
            amountTF.text = "50"
            amountTF.isEnabled = false
        }else if sender.tag == 3{
            amountTF.text = "200"
            amountTF.isEnabled = false
        }else if sender.tag == 4{
            amountTF.text = "500"
            amountTF.isEnabled = false
        }else if sender.tag == 5{
            amountTF.text = ""
            amountTF.isEnabled = true
        }
        
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = #colorLiteral(red: 0.4321206212, green: 0.6121876836, blue: 0.8075518012, alpha: 1)
        
    }
}

extension FanInformationVC: ThreeDotProtocol {
    
    func refreshBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "feedaneed"
        vc.titleStr = "Feed A Need"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension FanInformationVC {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func handleContinueBtnTap(_ sender: UITapGestureRecognizer? = nil) {
        if amountTF.text == "" {
            HUD.flash(.label("Please enter payment details to continue"), delay: 0.8)
        }else if fullNameTF.text! == "" ||
                    taxNoTF.text! == "" ||
                    emailTF.text! == "" ||
                    phoneTF.text! == "" {
            HUD.flash(.label("Please enter your complete details to continue"), delay: 0.8)
        }else{
            networkHitSubmit()
        }
    }
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleContinueBtnTap(_:)))
        continueBtnView.addGestureRecognizer(tap2)
        
        titleLBL.text = recName == "" ? "-" : recName
        addressLBL.text = recAddress == "" ? "-" : recAddress
        contactLBL.setTitle(recPhone == "" ? "-" : recPhone, for: .normal)
        emailLBL.setTitle(recEmail == "" ? "-" : recEmail, for: .normal)
        
        noteTV.delegate = self
        noteTV.text = "Note"
        noteTV.textColor = UIColor.lightGray
    }
    
    func neutralBtnColors(){
        
        payment1BTN.setTitleColor(.darkGray, for: .normal)
        payment1BTN.backgroundColor = #colorLiteral(red: 0.8194566369, green: 0.8192892671, blue: 0.8399093747, alpha: 1)
        payment2BTN.setTitleColor(.darkGray, for: .normal)
        payment2BTN.backgroundColor = #colorLiteral(red: 0.8194566369, green: 0.8192892671, blue: 0.8399093747, alpha: 1)
        payment3BTN.setTitleColor(.darkGray, for: .normal)
        payment3BTN.backgroundColor = #colorLiteral(red: 0.8194566369, green: 0.8192892671, blue: 0.8399093747, alpha: 1)
        payment4BTN.setTitleColor(.darkGray, for: .normal)
        payment4BTN.backgroundColor = #colorLiteral(red: 0.8194566369, green: 0.8192892671, blue: 0.8399093747, alpha: 1)
        payment5BTN.setTitleColor(.darkGray, for: .normal)
        payment5BTN.backgroundColor = #colorLiteral(red: 0.8194566369, green: 0.8192892671, blue: 0.8399093747, alpha: 1)
    }
}

extension FanInformationVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note"
            textView.textColor = UIColor.lightGray
        }
    }
}


extension FanInformationVC {
    
    func networkHitSubmit(){
        
        HUD.show(.progress)
        
        let noteTxt = noteTV.text == "Note" ? "" : noteTV.text ?? ""
                
        let parameters = ["masajid_id": "\(recMasjidID)",
                          "name": "\(fullNameTF.text!)",
                          "email": "\(emailTF.text!)",
                          "contact_no": "\(phoneTF.text!)",
                          "amount": "\(amountTF.text!)",
                          "description": "\(noteTxt)",
                          "ntn": "\(taxNoTF.text!)"
        ]
        
        print(parameters)
//        var headers: HTTPHeaders = [:]
//
//        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
//            headers = ["Authorization": "Bearer \(myToken)"]
//        }
        
        APIRequestUtil.FanSendInformation(parameters: parameters, headers: httpHeaders, completion: APIRequestSubmitCompleted)
    }
    
    fileprivate func APIRequestSubmitCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            
            HUD.hide()
            
            HUD.flash(.success, delay: 0.8){ finished in
                self.navigationController?.popViewController(animated: true)
            }
            
        }else{
            HUD.hide()
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
