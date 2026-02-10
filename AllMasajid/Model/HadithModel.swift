//
//  HadithModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/09/2022.
//  Copyright © 2022 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct HadithModel {
    
    var title: String = ""
    var translationEn: String = ""
    var hadithAr: String = ""
    var reference: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        title = Json["title"].stringValue
        translationEn = Json["translation_en"].stringValue
        hadithAr = Json["hadith_ar"].stringValue
        reference = Json["reference"].stringValue
    }
}
