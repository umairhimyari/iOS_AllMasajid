//
//  DisplayIqamahModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 02/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DisplayIqamahModel {
    
    var date: String = ""
    var fajr: String = ""
    var duhr: String = ""
    var asr: String = ""
    var maghrib: String = ""
    var isha: String = ""
    var todayDay: Int = 0
    var todayStatus: Bool = false
}
