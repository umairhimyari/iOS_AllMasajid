//
//  InterestModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct InterestModel {
    
    var id: Int = 0
    var status: Int = 0
    var type: Int = 0
    var name: String = ""
    var display_name: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        status = Json["status"].intValue
        type = Json["type"].intValue
        name = Json["name"].stringValue
        display_name = Json[display_name].stringValue
    }
}
