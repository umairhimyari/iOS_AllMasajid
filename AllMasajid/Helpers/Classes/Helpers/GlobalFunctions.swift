//
//  GlobalFunctions.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GetCityFromCordinates {
    
    static let sharedGetCity: GetCityFromCordinates = {
       let getCity = GetCityFromCordinates()
        return getCity
    }()
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String, lbl: UILabel){
        
        let lat: Double = Double("\(pdblLatitude)")!

        let lon: Double = Double("\(pdblLongitude)")!
        
        var addressString : String = ""
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

        ceo.reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
                 
            if (error != nil) {
                return
            }
            
            if placemarks != nil {
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    if let subLocality = pm.subLocality {
                        addressString = addressString + subLocality + ", "
                    }
                    if let locality = pm.locality {
                        addressString = addressString + locality + ", "
                    }
                    if let adminArea = pm.administrativeArea {
                        addressString = addressString + adminArea + ", "
                    }
                    if let country = pm.country {
                        addressString = addressString + country
                    }
                }
            }
            lbl.text = addressString
        })
    }
}

