//
//  DuaAppealsModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 04/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DuaAppealsModel {
    
    var id: Int = 0
    var user_id: Int = 0
    var is_secret: Int = 0
    var status: Int = 0
    var email: String = ""
    var title: String = ""
    var user_name: String = ""
    var contact_no: String = ""
    var appeal: String = ""
    var location: String = ""
    var remainingDaysText = ""
    var remainingDaysStatus = true
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        user_id = Json["user_id"].intValue
        is_secret = Json["is_secret"].intValue
        status = Json["status"].intValue
        email = Json["email"].stringValue
        title = Json["title"].stringValue
        user_name = Json["user_name"].stringValue
        contact_no = Json["contact_no"].stringValue
        appeal = Json["appeal"].stringValue
        location = Json["location"].stringValue
        remainingDaysText = Json["remaining_days"]["text"].stringValue
        remainingDaysStatus = Json["remaining_days"]["status"].boolValue
    }
}
