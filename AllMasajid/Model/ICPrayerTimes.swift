//
//  ICPrayerTimes.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 18/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ICPrayerTimes {
    
    var Fajr: String = ""
    var Sunrise: String = ""
    var Dhuhr: String = ""
    var Asr: String = ""
    var Sunset: String = ""
    var Maghrib: String = ""
    var Isha: String = ""
    var Imsak: String = ""
    var Midnight: String = ""
    
    init(fromJson Json: JSON!) {
        
        if Json.isEmpty {
            return
        }
        
        Fajr = Json["Fajr"].stringValue
        Sunrise = Json["Sunrise"].stringValue
        Dhuhr = Json["Dhuhr"].stringValue
        Asr = Json["Asr"].stringValue
        Sunset = Json["Sunset"].stringValue
        Maghrib = Json["Maghrib"].stringValue
        Isha = Json["Isha"].stringValue
        Imsak = Json["Imsak"].stringValue
        Midnight = Json["Midnight"].stringValue
    }
}
