//
//  FaqsModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 12/05/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FaqsModel {
    
    var question: String = ""
    var answer: String = ""
    var id: Int = 0
    var updated_at: String = ""
    var created_at: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        question = Json["question"].stringValue
        answer = Json["answer"].stringValue
        id = Json["id"].intValue
        updated_at = Json["updated_at"].stringValue
        created_at = Json["created_at"].stringValue
    }
}
