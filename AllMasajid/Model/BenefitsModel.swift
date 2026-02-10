//
//  BenefitsModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/09/2022.
//  Copyright © 2022 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BenefitsModel {
    
    var title: String = ""
    var description: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        title = Json["title"].stringValue
        description = Json["description"].stringValue
    }
}
