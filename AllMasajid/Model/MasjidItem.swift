//
//  MasjidItem.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 10/6/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import Foundation
import CoreLocation

public class MasjidItem {
    var id : String = ""
    var name : String = ""
    var distance : Double = 0.0
    var address: String = ""
    var feed_need: Int = 0
    var location = CLLocation()
}

