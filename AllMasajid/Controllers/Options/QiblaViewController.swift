//
//  QiblaViewController.swift
//  MuslimGuide
//
//  Created by Shahriyar Memon on 13/04/2018.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices
//import Adhan
import Alamofire
import PKHUD

class QiblaViewController: UIViewController,CLLocationManagerDelegate, ReloadDelegate, ThreeDotProtocol, LocationFetchDelegate {
    
    var observation: NSKeyValueObservation?
    var locationManager:CLLocationManager!
    var cityText : String = "-"
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat = 0//
    var bearingOfKabah = Double()
    
    let latOfKabah = 21.422487 //21.4225
    let lngOfKabah = 39.826206 //39.8262
    
    var reloadDelegate: ReloadDelegate?
    
    @objc var objectToObserve: LocationManager!

    @IBOutlet weak var compass: UIImageView!
    @IBOutlet weak var qibla_point: UIImageView!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var qView: UIView!

    @IBOutlet weak var lblCurrentDirection: UILabel!
    @IBOutlet weak var lblQiblaDirection: UILabel!
    @IBOutlet weak var lblAreaLocation: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager  = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        /*
        if UserDefaults.standard.bool(forKey: "introQibla") != true {
            UserDefaults.standard.set(true, forKey: "introQibla")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Qibla Direction"
            vc.screenName = "qibla"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }
    
    func locationFetched(_ succes: Bool) {
        self.reloadDelegate?.dataFetched(true)
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "qibla"
        vc.titleStr = "Qibla Direction"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpBtnPressed(){
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func refreshBtnPressed() {
        refreshData()
    }
    
    func shareBtnPressed() {
        print("Do nothing")
    }
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item5"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func refreshData(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                   
            HUD.show(.labeledProgress(title: "Loading Data", subtitle: "Please Wait ..."))
        }
        
        let vc = UIStoryboard().LoadLoadingScreen()
        vc.reloadDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func dataFetched(_ succes: Bool) {
        
        self.reloadScreenData()
    }
    
    func reloadScreenData(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
                
        locationManager  = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        locationSettings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HUD.hide()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
        
    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            latestLocation = LocationManager.shared.myLocation!
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationSettings() {
            
        if let location = LocationManager.shared.myLocation {
            
            if CLLocationManager.locationServicesEnabled() {
                latestLocation = location
                
                bearingOfKabah = getBearingBetweenTwoPoints1(latestLocation!, latitudeOfOrigin: latOfKabah, longitudeOfOrigin: lngOfKabah)
                
                self.yourLocationBearing = CGFloat(bearingOfKabah)
                
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                self.getCity()
            }else{
                showLocationAlert()
            }
        }else{
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    showLocationAlert()
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.startUpdatingLocation()
                    LocationManager.shared.requestLocation()

                @unknown default:
                    print("nothing")
                }
            } else {
                showLocationAlert()
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func showLocationAlert(){
        
        let alertController = UIAlertController(title: "Location Services Off OR No Permission Granted Yet!", message: "Either location services are off OR you did not allow 'My Masajid App' to access your location. Please turn on location services from phone settings for this application or use manual location from application settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                self.navigationController?.popViewController(animated: true)
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingHeading()
        case .authorizedAlways:
            locationManager.startUpdatingHeading()
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            latestLocation  = location
            
            bearingOfKabah = getBearingBetweenTwoPoints1(latestLocation!, latitudeOfOrigin: latOfKabah, longitudeOfOrigin: lngOfKabah)
            self.yourLocationBearing = CGFloat(bearingOfKabah)
            
            getCity()
            locationManager.stopUpdatingLocation()
            
        }
    }
    private func getBearingBetweenTwoPoints1(_ point1 : CLLocation, latitudeOfOrigin : Double , longitudeOfOrigin :Double) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(latitudeOfOrigin);
        let lon2 = degreesToRadians(longitudeOfOrigin);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        var radiansBearing = atan2(y, x);
        if(radiansBearing < 0.0){
            
            radiansBearing += 2 * Double.pi;
            
        }
        
        return radiansToDegrees(radiansBearing)
    }
    
    private func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    private  func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        let north =  -1 * newHeading.magneticHeading * Double.pi/180
        
        let directionOfKabah = bearingOfKabah * Double.pi/180 + north
        
        var direction = CGFloat(directionOfKabah).radiansToDegrees
        
        direction = self.yourLocationBearing.rounded() - direction
        
        //lblAreaLocation.text = "\(self.cityText)"
        
        lblQiblaDirection.text = "\(String(describing: Int(self.yourLocationBearing.rounded())))\u{00B0}"
        
        lblCurrentDirection.text = "\(String(describing: Int(direction)))\u{00B0}"
        
        UIView.animate(withDuration: 0.5) {
            
            self.qView.transform = CGAffineTransform(rotationAngle: CGFloat(directionOfKabah))
            
            self.compass.transform = CGAffineTransform(rotationAngle: CGFloat(north))
            
        }
        
        if(Int(direction) == Int(self.yourLocationBearing.rounded())){
            self.qibla_point.image = UIImage(named: "qibla-point-match")
        }else{
            self.qibla_point.image = UIImage(named: "qibla-point")
        }
        
    }
    
    func getCity(){
        
        let latt : String = "\(latestLocation?.coordinate.latitude ?? 0)"
        let lonn : String = "\(latestLocation?.coordinate.longitude ?? 0)"
        GetCityFromCordinates.sharedGetCity.getAddressFromLatLon(pdblLatitude: latt, withLongitude: lonn, lbl: lblAreaLocation)
    }
    
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                return 90
            case .landscapeRight:
                return -90
            case .portrait, .unknown:
                return 0
            case .portraitUpsideDown:
                return isFaceDown ? 180 : -180
            @unknown default:
                return 0
            }
        }()
        return adjAngle
    }
    
    func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
        let heading: CGFloat = {
            let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
            switch UIDevice.current.orientation {
            case .faceDown: return -originalHeading
            default: return originalHeading
            }
        }()
        
        return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
