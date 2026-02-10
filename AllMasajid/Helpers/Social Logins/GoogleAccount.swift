//
//  GoogleAccount.swift
//  Boatek
//
//  Created by Mac on 14/02/2022.
//


import Foundation
import GoogleSignIn
import UIKit

protocol GoogleSignInProtocol: AnyObject {
    func signInWithGoogle(firstName: String, lastName: String, email: String, googleID: String, error: Error?)
}

class GoogleAccount: NSObject {

    weak var delegate: GoogleSignInProtocol?

    func loginFromGoogle(vc: UIViewController) {
        let signInConfig = GIDConfiguration(clientID: GOOGLE_CONSOLE_CLIENT_ID)
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in
            guard let user = result?.user, error == nil else {
                if error?.localizedDescription == "The user canceled the sign-in flow." { return }
                self.delegate?.signInWithGoogle(firstName: "", lastName: "", email: "", googleID: "", error: error)
                return
            }
            
            guard let googleID = user.userID else {
                self.delegate?.signInWithGoogle(firstName: "", lastName: "", email: "", googleID: "", error: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"]))
                return
            }
            
            let name = (user.profile?.name ?? "").components(separatedBy: " ")
            let firstName = name.first ?? ""
            var lastName = ""
            for i in 0..<name.count {
                if i > 0 {
                    lastName = lastName + name[i]
                }
            }
            
            self.delegate?.signInWithGoogle(firstName: firstName,
                                            lastName: lastName,
                                            email: user.profile?.email ?? "",
                                            googleID: googleID,
                                            error: nil)
        }
    }
    
    func logoutFromGoogle() {
        GIDSignIn.sharedInstance.disconnect()
        GIDSignIn.sharedInstance.signOut()
    }
}
