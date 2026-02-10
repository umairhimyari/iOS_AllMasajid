//
//  Juzs.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Juzs {
    
    var id: Int = 0
    var juzNumber: Int = 0
    var versesCount: Int = 0
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        juzNumber = Json["juz_number"].intValue
        versesCount = Json["verses_count"].intValue
    }
}
