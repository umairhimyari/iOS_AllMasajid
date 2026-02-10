//
//  FanMasajidVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 12/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices
import Alamofire
import PKHUD
import SwiftyJSON

class FanMasajidVC: UIViewController, CLLocationManagerDelegate {

    var data : [MasjidItem] = []
    
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    
    @objc var objectToObserve: LocationManager!
    
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item5"
        self.parent?.present(vc, animated: false, completion: nil)
    }
}


extension FanMasajidVC: ThreeDotProtocol {
    
    func refreshBtnPressed() {
        data.removeAll()
        locationSettings()
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "feedaneed"
        vc.titleStr = "Feed A Need"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension FanMasajidVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasajidTVC", for: indexPath) as! MasajidTVC
        let item = data[indexPath.row]
        let dist = String(item.distance)
        
        if defaults.integer(forKey: "Unit") == 0 {
            cell.distanceLBL.text = dist.toLengthOf(length: 3) + " mi."
        }else {
            cell.distanceLBL.text = dist.toLengthOf(length: 3) + " km"
        }
        
        cell.masjidNameLBL.text = item.name
                
        cell.registerBTN.isHidden = item.feed_need == 0 ? false : true
        cell.registerBTN.addTarget(self, action: #selector(registerBtnPressed), for: .touchUpInside)
        cell.registerBTN.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadFanInformationScreen()
        vc.recName = data[indexPath.row].name
        vc.recPhone = ""
        vc.recEmail = ""
        vc.recMasjidID = data[indexPath.row].id
        vc.recAddress = data[indexPath.row].address
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FanMasajidVC {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func registerBtnPressed(_ sender: UIButton){
        let item = data[sender.tag]
        
        let vc = UIStoryboard().LoadFanRegisterMasjidScreen()
        vc.recName = item.name
        vc.recPhone = ""
        vc.recEmail = ""
        vc.recMasjidID = item.id
        vc.recAddress = item.address
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tryAgain() {
        refreshBtnPressed()
    }
    
    func getCity(){
        
        let latt : String = "\(myLocation.coordinate.latitude)"
        let lonn : String = "\(myLocation.coordinate.longitude)"
        GetCityFromCordinates.sharedGetCity.getAddressFromLatLon(pdblLatitude: latt, withLongitude: lonn, lbl: addressLBL)
    }
    
    func setupInitials(){
        
        locationSettings()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "MasajidTVC", bundle: nil), forCellReuseIdentifier: "MasajidTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
    }
}


extension FanMasajidVC {
    
    func locationSettings(){

        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    
                    self.getNearbyMasjids(loc: myLocation.coordinate)
                    self.getCity()
                }
            } catch { print(error) }
            
        }else if defaults.integer(forKey: "Location") == 2{
            
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNearbyMasjids(loc: myLocation.coordinate)
                    self.getCity()
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                getCity()
                getNearbyMasjids(loc: myLocation.coordinate)
                
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
        }
    }
    
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            myLocation = LocationManager.shared.myLocation!
            getCity()
            self.getNearbyMasjids(loc: self.myLocation.coordinate)
        }
    }
    
    func observeLocation(object: LocationManager) {
        objectToObserve = object
        if (objectToObserve.myLocation == nil){
            showLocationAlert()
        }else{
            if let location = LocationManager.shared.myLocation{
                self.myLocation = location
            }
            self.getCity()
            self.getNearbyMasjids(loc: self.myLocation.coordinate)
            
        }
    }
    
    func showLocationAlert()
    {
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
}


extension FanMasajidVC: TryAgainProtocol{
    
    func getNearbyMasjids(loc : CLLocationCoordinate2D){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        var unit = ""
        var meters = 0.0
        if defaults.integer(forKey: "Unit") == 0 {
            meters = (Double(nearbyRange[defaults.integer(forKey: "Distance")])!/0.6213) * 1000
            unit = "M"
        }else{
            meters = Double(nearbyRange[defaults.integer(forKey: "Distance")])! * 1000
            unit = "K"
        }
        
        APIRequestUtil.GetNearByMasajid(latitude: "\(loc.latitude)", longitude: "\(loc.longitude)", radius: "\(meters)", units: "\(unit)", completion: APIRequestNearbyCompleted)
    }
    
    fileprivate func APIRequestNearbyCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            
            let json = JSON(response)
            print(json)
            
            data.removeAll()
            
            if json.count == 0 {
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            self.data = CommonApiResponse.shared.nearByMasajid(json: json)
            
            self.myTableView.reloadData()
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}
