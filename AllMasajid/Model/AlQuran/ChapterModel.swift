//
//  ChapterModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ChapterModel {
    
    var id: Int = 0
    var name: String = ""
    var nameArabic: String = ""
    var versesCount: Int = 0
    var englishName: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        id = Json["id"].intValue
        name = Json["name_simple"].stringValue
        nameArabic = Json["name_arabic"].stringValue
        versesCount = Json["verses_count"].intValue
        englishName = Json["translated_name"]["name"].stringValue
    }
}
