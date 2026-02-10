//
//  How2UseCategoriesDataBank.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct How2UseAppCategories {
    
    var id: Int = 0
    var order: Int = 0
    var display_name: String = ""
    var name: String = ""
    var image: String = ""
    
    var description = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        order = Json["order"].intValue
        display_name = Json["display_name"].stringValue
        name = Json["name"].stringValue
        image = Json[image].stringValue
        
        description = Json["description"].stringValue
    }
}

