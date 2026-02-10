//
//  AppleAccount.swift
//  Boatek
//
//  Created by Mac on 14/02/2022.
//

import Foundation
import AuthenticationServices
import KeychainSwift

protocol AppleSignUpProtocol: AnyObject {
    func signInWithApple(appleToken: String, firstName: String, lastName: String, email: String, error: Error?)
}

class AppleAccount: UIViewController {
    
    var isSignUpUser = false
    weak var delegate: AppleSignUpProtocol?
    
    @available(iOS 13.0, *)
    func loginFromApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()

        // request full name and email from the user's Apple ID
        request.requestedScopes = [.fullName, .email]

        // pass the request to the initializer of the controller
        let authController = ASAuthorizationController(authorizationRequests: [request])

        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }
}

extension AppleAccount: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // return the current view window
        return self.view.window!
    }
}

extension AppleAccount: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled: // user press "cancel" during the login prompt
            print("Canceled")
            
        case .unknown: // user didn't login their Apple ID on the device
            print("Unknown")
            delegate?.signInWithApple(appleToken: "", firstName: "", lastName: "", email: "", error: error)
            
        case .invalidResponse: // invalid response received from the login
            print("Invalid Respone")
            delegate?.signInWithApple(appleToken: "", firstName: "", lastName: "", email: "", error: error)
            
        case .notHandled: // authorization request not handled, maybe internet failure during login
            print("Not handled")
            delegate?.signInWithApple(appleToken: "", firstName: "", lastName: "", email: "", error: error)
            
        case .failed: // authorization failed
            print("Failed")
            delegate?.signInWithApple(appleToken: "", firstName: "", lastName: "", email: "", error: error)
            
        case .notInteractive:
            print("Not Interactive")
            delegate?.signInWithApple(appleToken: "", firstName: "", lastName: "", email: "", error: error)
            
        @unknown default:
            print("Default")
            delegate?.signInWithApple(appleToken: "", firstName: "", lastName: "", email: "", error: error)
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userID = appleIDCredential.user
            var email: String = ""
            var firstName: String = ""
            var lastName: String = ""
            let keychain = KeychainSwift()
            
            if let data = keychain.getData(userID), let appleUser = try?
                NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? AppleUserInfo {
                
                email = appleUser.email ?? ""
                firstName = appleUser.firstName ?? ""
                lastName = appleUser.lastName ?? ""
                
            } else {
                
                email = appleIDCredential.email ?? ""
                firstName = appleIDCredential.fullName?.givenName ?? ""
                let isEmptyFamilyName = appleIDCredential.fullName?.familyName == nil
                lastName = isEmptyFamilyName ? appleIDCredential.fullName?.middleName ?? "" : appleIDCredential.fullName?.familyName ?? ""
                
                if email.isEmpty && firstName.isEmpty && lastName.isEmpty {
                    delegate?.signInWithApple(appleToken: userID, firstName: "", lastName: "", email: "", error: nil)
                    return
                }
                
                let appleUser = AppleUserInfo(firstName: firstName, lastName: lastName, email: email)
                if let data = try? NSKeyedArchiver.archivedData(withRootObject: appleUser, requiringSecureCoding: false) {
                    keychain.set(data, forKey: userID)
                }
            }
            delegate?.signInWithApple(appleToken: userID, firstName: firstName, lastName: lastName, email: email, error: nil)
        }
    }
}
