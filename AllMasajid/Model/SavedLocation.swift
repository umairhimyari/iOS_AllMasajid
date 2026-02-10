//
//  SavedLocation.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 4/21/19.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import CoreLocation

import Foundation

class SavedLocation: NSObject, NSCoding {
    let name: String
    let Id : String
    let latitude : Double
    let longitude : Double
    
    init(name: String, Id: String, latitude : Double, longitude : Double) {
        self.name = name
        self.Id = Id
        self.latitude = latitude
        self.longitude = longitude
    }
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.Id = decoder.decodeObject(forKey: "Id") as? String ?? ""
        self.latitude = decoder.decodeDouble(forKey: "latitude")
        self.longitude = decoder.decodeDouble(forKey: "longitude")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(Id, forKey: "Id")
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
    }
}
