//
//  AnnounementsModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 03/06/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AnnounementsModel {
    
    var id: Int = 0
    var masajids_id: Int = 0
    var title: String = ""
    var description: String = ""
    var email: String = ""
    var contact: String = ""
    var status: Int = 0
    var image: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var deleted_at: String = ""
    var distance: String = ""
    var fav: Int = 0
    var unit: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        masajids_id = Json["masajids_id"].intValue
        title = Json["title"].stringValue
        description = Json["description"].stringValue
        email = Json["email"].stringValue
        contact = Json["contact"].stringValue
        status = Json["status"].intValue
        image = Json["image"].stringValue
        created_at = Json["created_at"].stringValue
        updated_at = Json["updated_at"].stringValue
        deleted_at = Json["deleted_at"].stringValue
        distance = Json["distance"].stringValue
        fav = Json["fav"].intValue
        unit = Json["unit"].stringValue
    }
}
