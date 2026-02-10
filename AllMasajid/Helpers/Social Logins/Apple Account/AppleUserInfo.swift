//
//  AppleUserInfo.swift
// Boatek
//
//  Created by ILSA on 30/03/2021.
//  Copyright © 2021 ILSA Interactive. All rights reserved.
//

import UIKit

class AppleUserInfo: NSObject, NSCoding {
    
    var firstName: String?
    var lastName: String?
    var email: String?
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.firstName = decoder.decodeObject(forKey: "firstName") as? String
        self.lastName = decoder.decodeObject(forKey: "lastName") as? String
        self.email = decoder.decodeObject(forKey: "email") as? String
    }
    
    convenience init(firstName: String?, lastName: String?, email: String?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    func encode(with coder: NSCoder) {
        if let firstName = firstName { coder.encode(firstName, forKey: "firstName") }
        if let lastName = lastName { coder.encode(lastName, forKey: "lastName") }
        if let email = email { coder.encode(email, forKey: "email") }
        
    }
}
