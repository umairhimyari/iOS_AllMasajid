//
//  Verse.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Verse {
    
    var id: Int = 0
    var verseKey: String = ""
    var name: String = ""
    
    init(fromJson Json: JSON) {
        id = Json["id"].intValue
        verseKey = Json["verse_key"].stringValue
        name = Json["text_uthmani"].stringValue
    }
}
