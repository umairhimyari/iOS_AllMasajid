//
//  CommonApiResponse.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class CommonApiResponse {
    static var shared = CommonApiResponse()
    
    func nearByMasajid(json: JSON) -> [MasjidItem] {
        var data = [MasjidItem]()

        // Handle both array and dictionary formats
        if json.type == .array {
            // Array format: [{...}, {...}]
            for index in 0..<json.count {
                if let item = parseMasjidItem(from: json[index]) {
                    data.append(item)
                }
            }
        } else if json.type == .dictionary {
            // Dictionary format: {"0": {...}, "10": {...}}
            for (_, subJson) in json {
                if let item = parseMasjidItem(from: subJson) {
                    data.append(item)
                }
            }
        }

        data = data.sorted(by: { (first, second) -> Bool in
            first.distance < second.distance
        })

        return data
    }

    private func parseMasjidItem(from json: JSON) -> MasjidItem? {
        let item = MasjidItem()

        // Try google_masajid_id first, fallback to place_id
        item.id = json["google_masajid_id"].stringValue
        if item.id.isEmpty {
            item.id = json["place_id"].stringValue
        }

        item.name = json["name"].stringValue
        item.distance = json["distance"].doubleValue

        // Handle address
        item.address = json["address"].stringValue

        // Handle feed_need
        item.feed_need = json["feed_need"].intValue

        // Try direct lat/long first (new API format) - use doubleValue to handle string to double conversion
        var masjidLat: Double = 0
        var masjidLong: Double = 0

        if json["lat"].exists() && json["long"].exists() {
            masjidLat = json["lat"].doubleValue
            masjidLong = json["long"].doubleValue
        } else {
            // Fallback to geometry.location (old Google Places format)
            let geometry = json["geometry"]
            let geoLocation = geometry["location"]
            if geoLocation["lat"].exists() && geoLocation["lng"].exists() {
                masjidLat = geoLocation["lat"].doubleValue
                masjidLong = geoLocation["lng"].doubleValue
            }
        }

        // Only create location if we have valid coordinates
        if masjidLat != 0 && masjidLong != 0 {
            item.location = CLLocation(latitude: masjidLat, longitude: masjidLong)
            return item
        }

        return nil
    }
}
