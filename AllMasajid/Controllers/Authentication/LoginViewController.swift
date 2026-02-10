//
//  LoginViewController.swift
//  Hawksavvy
//
//  Created by 12345 on 9/17/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import SwiftValidator
import PKHUD
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController,ValidationDelegate,UITextFieldDelegate {
    
    var rememberMe = true
    
    let validator = Validator()
    var activeField: UITextField?
    //let manager = APIManager()

    @IBOutlet var footerView: UIView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        
        self.hideKeyboardWhenTappedAround()
        
        HUD.allowsInteraction = false
        HUD.dimsBackground = true
        validator.registerField(txtEmail, rules: [RequiredRule(message: "Email is required"),EmailRule(message: "Please enter valid email address")])
        validator.registerField(txtPassword, rules: [RequiredRule(message: "Password is required")])
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
   
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
   
        let vc = UIStoryboard().LoadRegisterScreen()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        HUD.show(.progress)
        validator.validate(self)
    }
    
    func validationSuccessful() {
        HUD.hide()
        txtEmail.layer.borderColor = UIColor.lightGray.cgColor
        txtPassword.layer.borderColor = UIColor.lightGray.cgColor
        
        networkHit()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
               // field.layer.borderWidth = 1.0
                field.text = ""
                field.attributedPlaceholder = NSAttributedString(string: error.errorMessage,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
        }
    
        HUD.hide()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadForgetPasswordScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func toggleRemeberMe(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            rememberMe = false
            btnCheckBox.setImage(UIImage(named: "unchecked"), for: .normal)
        }else{
            sender.tag = 0
            rememberMe = true
            btnCheckBox.setImage(UIImage(named: "checked"), for: .normal)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}


extension LoginViewController {
    
    func networkHit(){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false

        let parameters = ["email" : txtEmail.text!, "password":txtPassword.text!]
        APIRequestUtil.Login(headers: ["devicetoken": myFirebaseToken, "platform": "ios"] ,parameters: parameters, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "success"{
                let success = json["success"]
                let token = success["token"].stringValue
                
                if rememberMe{
                    UserDefaults.standard.set(true, forKey: "rememberMe")
                }else{
                    UserDefaults.standard.set(false, forKey: "rememberMe")
                }
                
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(txtEmail.text!, forKey: "userEmail")
                userEmail = txtEmail.text!
                
                let vc = UIStoryboard().LoadLandingScreen()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                HUD.flash(.labeledError(title: "Error", subtitle: "Invalid Login Details"), delay: 0.8)
            }
                        
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.8)
        }
    }
}
