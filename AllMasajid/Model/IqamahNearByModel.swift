//
//  IqamahNearByModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/11/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import CoreLocation

struct IqamahNearByModel {
    
    var googleMasjidID: String?
    var masjidName: String?
    var distance: Double = 0.0
    var distanceStr: String?
    var diff_time_number: String?
    var isReachable: Bool?
    var end_date: String?
    var diff_time: String?
    var to_date: String?
    var time: String?
    var status: Int?
    var units: String?
    var timeRequiredSeconds: Int?
    
    var location = CLLocation()
    var jumah = [IqamahJummahModel]()
    
}

struct IqamahJummahModel {
    var type: String?
    var time: String?
    var diff_time: String?
    var diff_time_number: Int?
}
