//
//  MyMasajidModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 10/05/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MyMasajidModel {
    
    var id: Int = 0
    var google_masajid_id: String = ""
    var name: String = ""
    var address: String = ""
    var lat: String = ""
    var long: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    
//    "pivot": {
//    "users_id": 2,
//    "masajids_id": 2
//  }
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        google_masajid_id = Json["google_masajid_id"].stringValue
        name = Json["name"].stringValue
        address = Json["address"].stringValue
        lat = Json["lat"].stringValue
        long = Json["long"].stringValue
        created_at = Json["created_at"].stringValue
        updated_at = Json["updated_at"].stringValue
    }
}
