//
//  RegistrationViewController.swift
//  AllMasajid
//
//  Created by 12345 on 9/18/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import SwiftValidator
import SwiftyJSON
import PKHUD
import Alamofire

class RegistrationViewController: UIViewController,ValidationDelegate,UITextFieldDelegate  {

    let validator = Validator()
    var activeField: UITextField?

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        let str = UserDefaults.standard.object(forKey: "currentDate")
        self.lblDate.text = "\(str ?? "")"
        btnCheckBox.setImage(UIImage(named: "checked"), for: .selected)
        btnCheckBox.setImage(UIImage(named: "unchecked"), for: .normal)
        
        self.hideKeyboardWhenTappedAround()
        
        HUD.allowsInteraction = false
        HUD.dimsBackground = true
        validator.registerField(txtEmail, rules: [RequiredRule(message: "Email*")])
        validator.registerField(txtPassword, rules: [RequiredRule(message: "Password*")])
        validator.registerField(txtFirstName, rules: [RequiredRule(message: "First Name*")])
        validator.registerField(txtLastName, rules: [RequiredRule(message: "Last Name*")])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func acceptTerms(_ sender: UIButton) {
         btnCheckBox.isSelected = !btnCheckBox.isSelected
    }
    
    @IBAction func registerUser(_ sender: UIButton) {
        HUD.show(.progress)
        validator.validate(self)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termConditionsPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadWebViewScreen()
        vc.screenReceived = 2
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func validationSuccessful() {
        HUD.hide()
        txtEmail.layer.borderColor = UIColor.lightGray.cgColor
        txtPassword.layer.borderColor = UIColor.lightGray.cgColor
        txtFirstName.layer.borderColor = UIColor.lightGray.cgColor
        txtLastName.layer.borderColor = UIColor.lightGray.cgColor
        
        if btnCheckBox.isSelected == true{
            if txtEmail.text!.isValidEmail(){
                networkHit()
            }else{
                HUD.flash(.label("Please Enter Valid Email-Address"), delay: 0.6)
            }
        }else{
            HUD.flash(.label("Please Accept Terms & Conditions To Continue"), delay: 0.6)
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                //field.layer.borderWidth = 1.0
                field.text = ""
                field.attributedPlaceholder = NSAttributedString(string: error.errorMessage,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
        }
        
        HUD.hide()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension RegistrationViewController {
    
    func networkHit(){
        
        let parameters = ["email" : txtEmail.text!, "password":txtPassword.text!, "first_name":txtFirstName.text!, "last_name":txtLastName.text!, "token":"6333444771123"]
    
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false

        APIRequestUtil.Register(headers: ["devicetoken": myFirebaseToken, "platform": "ios"], parameters: parameters, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error"{
                
                let error = json["error"].stringValue
                HUD.flash(.labeledError(title: "Error", subtitle: error), delay: 0.7)
                
            }else if firstResponseKey == "success"{
                
                let success = json["success"]
                let token = success["token"].stringValue
                
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                
                UserDefaults.standard.set(txtEmail.text!, forKey: "userEmail")
                userEmail = txtEmail.text!
                
                let vc = UIStoryboard().LoadLandingScreen()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.6)
        }
    }
}

extension RegistrationViewController{

    @objc func keyboardWillShow(notification: NSNotification) {
                
        verticalScrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        verticalScrollView.contentInset = contentInsets
        verticalScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                verticalScrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        verticalScrollView.contentInset = contentInsets
        verticalScrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        if activeField?.layer.borderColor == UIColor.red.cgColor{
            if activeField == txtEmail{
                txtEmail.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if activeField == txtPassword{
                txtPassword.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeField = nil
    }
}

