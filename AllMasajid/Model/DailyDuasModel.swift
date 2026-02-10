//
//  DailyDuasModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct DailyDuasModel {
    
    var id: String = ""
    var image: String = ""
    var name: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].stringValue
        image = Json["image"].stringValue
        name = Json["name"].stringValue
    }
}
