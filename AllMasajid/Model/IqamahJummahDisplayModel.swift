//
//  IqamahJummahModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 02/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct IqamahJummahDisplayModel {
    
    var time: String = ""
    var type: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        time = Json["time"].stringValue
        type = Json["type"].stringValue
    }
}
