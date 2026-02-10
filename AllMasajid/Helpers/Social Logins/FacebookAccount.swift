//
//  FacebookAccount.swift
//  Circl
//
//  Created by Waqar Zahour on 24/01/2020.
//  Copyright © 2020 ILSA Interactive. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

protocol FacebookSignInProtocol: AnyObject {
    func signInWithFacebook(firstName: String, lastName: String, email: String, facebookID: String, error: Error?)
}

class FacebookAccount: NSObject {
    
    weak var delegate: FacebookSignInProtocol?
    let loginManager = LoginManager()
    
    func loginFromFacebook(viewController: UIViewController) {
        loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { (result, error) in
            
            guard let result = result else {
                print("No result found")
                self.delegate?.signInWithFacebook(firstName: "", lastName: "", email: "", facebookID: "", error: error)
                return
            }
            let fbUserID = result.token?.userID ?? ""
            if result.isCancelled {
                print("Cancelled \(error?.localizedDescription ?? "")")
            } else if let error = error {
                print("Process error \(error.localizedDescription)")
                self.delegate?.signInWithFacebook(firstName: "", lastName: "", email: "", facebookID: "", error: error)
            } else {
                print("Logged in")
                let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, first_name, last_name"])
                graphRequest.start { [weak self] (_, result, error) -> Void in
                    guard let weakSelf = self else { return }
                    if error != nil {
                        print("error occured")
                        weakSelf.delegate?.signInWithFacebook(firstName: "", lastName: "", email: "", facebookID: "", error: error)
                    } else {
                        if let result = result as? [String: AnyObject] {
                            let email = result["email"] as? String ?? ""
                            let name = result["name"] as? String ?? ""
                            let firstName = result["first_name"] as? String ?? ""
                            let lastName = result["last_name"] as? String ?? ""
                            print("email: \(email)")
                            print("name: \(name)")
                            weakSelf.delegate?.signInWithFacebook(firstName: firstName, lastName: lastName, email: email, facebookID: fbUserID, error: nil)
                        }
                    }
                }
            }
        }
    }
}
