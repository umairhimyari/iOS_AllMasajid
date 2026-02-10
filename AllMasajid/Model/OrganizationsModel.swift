//
//  OrganizationsModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 14/03/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct OrganizationsModel {
    
    var id: Int = 0
    var status: Int = 0
    var city_id: String = ""
    var city_name: String = ""
    var city_latitude: String = ""
    var city_longitude: String = ""
    var place_id: String = ""
    var place_name: String = ""
    var place_latitude: String = ""
    var place_longitude: String = ""
    var place_address: String = ""
    var title: String = ""
    var description: String = ""
    var link: String = ""
    var email: String = ""
    var address: String = ""
    var contact: String = ""
    var message: String = ""
    var image: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    
    var date: String = ""
    var time: String = ""
    
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        status = Json["status"].intValue
        city_id = Json["city_id"].stringValue
        city_name = Json["city_name"].stringValue
        city_latitude = Json["city_latitude"].stringValue
        city_longitude = Json["city_longitude"].stringValue
        place_id = Json["place_id"].stringValue
        place_name = Json["place_name"].stringValue
        place_latitude = Json["place_latitude"].stringValue
        place_longitude = Json["place_longitude"].stringValue
        place_address = Json["place_address"].stringValue
        title = Json["title"].stringValue
        description = Json["description"].stringValue
        link = Json["link"].stringValue
        email = Json["email"].stringValue
        address = Json["address"].stringValue
        contact = Json["contact"].stringValue
        message = Json["message"].stringValue
        image = Json["image"].stringValue
        created_at = Json["created_at"].stringValue
        updated_at = Json["updated_at"].stringValue
        
        date = Json["date"].stringValue
        time = Json["time"].stringValue
    }
}
