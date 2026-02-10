//
//  DuasModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct DuasModel {
    
    var fav: Int = 0
    var updated_at: String = ""
    var translation: String = ""
    var second_translation: String = ""
    var transliteration: String = ""
    var name: String = ""
    var created_at: String = ""
    var id: Int = 0
    var dua: String = ""
    var reference: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        fav = Json["fav"].intValue
        updated_at = Json["updated_at"].stringValue
        translation = Json["translation"].stringValue
        second_translation = Json["second_translation"].stringValue
        transliteration = Json["transliteration"].stringValue
        name = Json["name"].stringValue
        created_at = Json["created_at"].stringValue
        id = Json["id"].intValue
        dua = Json["dua"].stringValue
        reference = Json["reference"].stringValue
    }
}
