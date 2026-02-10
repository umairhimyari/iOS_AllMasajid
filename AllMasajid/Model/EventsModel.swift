//
//  EventsModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 07/06/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct EventsModel {
    
    var id: Int = 0
    var masajids_id: Int = 0
    var status: Int = 0
    var title: String = ""
    var description: String = ""
    var link: String = ""
    var email: String = ""
    var contact: String = ""
    var address: String = ""
    var message: String = ""
    var date: String = ""
    var time: String = ""
    var image: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var deleted_at: String = ""
    
    var distance: String = ""
    var fav: Int = 0
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        masajids_id = Json["masajids_id"].intValue
        status = Json["status"].intValue
        title = Json["title"].stringValue
        description = Json["description"].stringValue
        link = Json["link"].stringValue
        email = Json["email"].stringValue
        contact = Json["contact"].stringValue
        address = Json["address"].stringValue
        message = Json["message"].stringValue
        date = Json["date"].stringValue
        time = Json["time"].stringValue
        image = Json["image"].stringValue
        created_at = Json["created_at"].stringValue
        updated_at = Json["updated_at"].stringValue
        deleted_at = Json["deleted_at"].stringValue
        
        distance = Json["distance"].stringValue
        fav = Json["fav"].intValue
    }
}
