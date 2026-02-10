//
//  OrganizationsVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 11/03/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import CoreLocation

class OrganizationsVC: UIViewController {
    
    var isRefreshing = false
    var delegate: SelectOrganizationProtocol?
    
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!
    
    var nextPageTokenStr = ""
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    var organizationArray = [MasjidItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)

        myTableView.register(UINib(nibName: "OrganizationsTVC", bundle: nil), forCellReuseIdentifier: "OrganizationsTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        locationSettings()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension OrganizationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizationsTVC", for: indexPath) as! OrganizationsTVC
        cell.titleLBL.text = organizationArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectOrg(item: organizationArray[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

extension OrganizationsVC {
    
    func tryAgain() {
        organizationArray.removeAll()
        locationSettings()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                    
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isRefreshing) {
                        
            if nextPageTokenStr != "" {
                isRefreshing = true
                getNearbyOrganizations(loc: myLocation.coordinate)
            }
        }
    }
}

extension OrganizationsVC: TryAgainProtocol{
    
    func getNearbyOrganizations(loc : CLLocationCoordinate2D){
        
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
//        meters = 5
        
        let nextPageToken = nextPageTokenStr == "" ? "" : "&pagetoken=\(nextPageTokenStr)"
        APIRequestUtil.GetNearByOrganizations(latitude: "\(loc.latitude)", longitude: "\(loc.longitude)", radius: "\(meters)", units: "\(unit)", pageTokenParams: nextPageToken, completion: APIRequestNearbyCompleted)
    }
    
    fileprivate func APIRequestNearbyCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            
            let preJson = JSON(response)
            print(preJson)
            
            let json = preJson["data"].arrayValue
            nextPageTokenStr = preJson["next_page_token"].stringValue
            
            for index in 0..<json.count {
                
                let id = json[index]["place_id"].stringValue
                let masjidName = json[index]["name"].stringValue
                
                let geometry = json[index]["geometry"]
                let geoLocation = geometry["location"]
                let masjidLat = geoLocation["lat"].double ?? 0
                let masjidLong = geoLocation["lng"].double ?? 0
                let masjidLoc = CLLocation(latitude: masjidLat, longitude: masjidLong)
                
                let item = MasjidItem()
                item.name = masjidName
                item.id = id
                item.location = masjidLoc
                item.address = json[index]["vicinity"].stringValue
                
                self.organizationArray.append(item)
            }
            
            if json.count == 0 {
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            
            isRefreshing = false
            self.myTableView.reloadData()
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            
        }else{
            HUD.hide()
            isRefreshing = false
            self.view.isUserInteractionEnabled = true
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}

extension OrganizationsVC: CLLocationManagerDelegate{
    
    func locationSettings(){
            
        if UserDefaults.standard.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNearbyOrganizations(loc: myLocation.coordinate)
                }
            } catch { print(error) }
            
            
        }else if UserDefaults.standard.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNearbyOrganizations(loc: myLocation.coordinate)
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                getNearbyOrganizations(loc: myLocation.coordinate)
                
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
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
            self.getNearbyOrganizations(loc: self.myLocation.coordinate)
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
