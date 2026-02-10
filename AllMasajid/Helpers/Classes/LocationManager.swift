//
//  LocationManager.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 2/10/19.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import Foundation
import CoreLocation
import PKHUD

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var myLocation : CLLocation?
    let locationManager = CLLocationManager()
    
    weak var locFetchDelegate: LocationFetchDelegate?
    
    override init() {
        super.init()
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        if myLocation != nil {
            getCity()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .denied, .restricted:
            
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
                self.locFetchDelegate?.locationFetched(false)
            }
            
        case .authorizedWhenInUse:
            locationManager.requestLocation()
//            HUD.show(.labeledProgress(title: "Please wait", subtitle: "Getting Location Now"))
            
        case .authorizedAlways:
            locationManager.requestLocation()
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocation = manager.location else { return }
        myLocation = locValue
        
        let myLong = String(locValue.coordinate.longitude)
        let myLat = String(locValue.coordinate.latitude)
        
        UserDefaults.standard.set(myLong, forKey: "longGPS")
        UserDefaults.standard.set(myLat, forKey: "latGPS")
        
        getCity()
        locationManager.stopUpdatingLocation()
        NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "LocationFetched")))
        self.locFetchDelegate?.locationFetched(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locFetchDelegate?.locationFetched(false)
    }
    func getCity(){
        CLGeocoder().reverseGeocodeLocation(myLocation!, completionHandler: {(placemarks, error) in
            if (error != nil) {
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks![0] as CLPlacemark
                let place = "\(pm.locality ?? ""), \(pm.administrativeArea ?? ""), \(pm.country ?? "")"
                let savedLocation = SavedLocation(name: place, Id: "1", latitude: (self.myLocation?.coordinate.latitude)!, longitude: (self.myLocation?.coordinate.longitude)!)
                
                
                let userDefaults = UserDefaults.standard
                
                // [ADDED] 22 January, 2021
                do{
                    let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: savedLocation, requiringSecureCoding: false)
                    userDefaults.set(encodedData, forKey: "savedLocation")
                    
                }catch{
                    print(error)
                }
                

                // [REMOVED] 22 January, 2021
//                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: savedLocation)
//                userDefaults.set(encodedData, forKey: "savedLocation")
                
                self.locationManager.stopUpdatingLocation()
            }
        })
    }
}

