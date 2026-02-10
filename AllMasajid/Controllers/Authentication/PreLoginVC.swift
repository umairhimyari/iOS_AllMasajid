//
//  PreLoginVC.swift
//  AllMasajid
//
//  Created by MacBook Pro  on 17/07/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON

//MARK: - Login Types
enum LoginActionType: String, Codable {
    case Google = "google"
    case Facebook = "facebook"
    case Apple = "apple"
}

class PreLoginVC: BaseVC {

    var actionType: LoginActionType?
    
    var appleAccount = AppleAccount()
    var googleAccount = GoogleAccount()
    var facebookAccount = FacebookAccount()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginWithAppleTapped(_ sender: Any) {
        actionType = .Apple
        appleAccount.delegate = self
        if #available(iOS 13.0, *) {
            appleAccount.loginFromApple()
        } else {
            Alert.showMsg(msg: "Apple login is only available from iOS 13.0")
        }
    }
    
    @IBAction func loginWithFacebookTapped(_ sender: Any) {
        actionType = .Facebook
        facebookAccount.delegate = self
        facebookAccount.loginFromFacebook(viewController: self)
    }
    
    @IBAction func loginWithGoogleTapped(_ sender: Any) {
        actionType = .Google
        googleAccount.delegate = self
        googleAccount.loginFromGoogle(vc: self)
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadLoginScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signupPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadRegisterScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - AppleSignupProtocol
extension PreLoginVC: AppleSignUpProtocol {
    func signInWithApple(appleToken: String, firstName: String, lastName: String, email: String, error: Error?) {
        if let error = error {
            Alert.showMsg(msg: error.localizedDescription)
        } else {
            networkHit(type: .Apple, token: appleToken, email: email, name: "\(firstName) \(lastName)")
        }
    }
}

// MARK: - GoogleSignInProtocol
extension PreLoginVC: GoogleSignInProtocol {
    func signInWithGoogle(firstName: String, lastName: String, email: String, googleID: String, error: Error?) {
        if let error = error {
            Alert.showMsg(msg: error.localizedDescription)
        } else {
            networkHit(type: .Google, token: googleID, email: email, name: "\(firstName) \(lastName)")
        }
    }
}

// MARK: - FacebookSignInProtocol
extension PreLoginVC: FacebookSignInProtocol {
    func signInWithFacebook(firstName: String, lastName: String, email: String, facebookID: String, error: Error?) {
        if let error = error {
            Alert.showMsg(msg: error.localizedDescription)
        } else {
            networkHit(type: .Facebook, token: facebookID, email: email, name: "\(firstName) \(lastName)")
        }
    }
}


extension PreLoginVC {
    
    func networkHit(type: LoginActionType, token: String, email: String, name: String) {
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        var parameters = ["provider": type.rawValue,
                          "access_token": token]
        if type == .Apple {
            if email != "" {
                parameters["email"] = email
            }
            
            if name != "" {
                parameters["name"] = name
            }
        }
        
        APIRequestUtil.SocialLogin(headers: [:], parameters: parameters, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        self.view.isUserInteractionEnabled = true
        
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error" {
                let error = json["error"].stringValue
                HUD.flash(.labeledError(title: "Error", subtitle: error), delay: 0.7)
                
            } else if firstResponseKey == "success" {
                let success = json["success"]
                let token = success["token"].stringValue
                
                UserDefaults.standard.set(true, forKey: "rememberMe")
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
//                UserDefaults.standard.set(txtEmail.text!, forKey: "userEmail")
//                userEmail = txtEmail.text!
                
                let vc = UIStoryboard().LoadLandingScreen()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
