//
//  NearbyMasajidViewController.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 10/6/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices
import Alamofire
import PKHUD
import SwiftyJSON
import SCLAlertView
import MapKit

class NearbyMasajidViewController: UIViewController, CLLocationManagerDelegate {
    
    var data : [MasjidItem] = []
    
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    
    @objc var objectToObserve: LocationManager!

    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblSetDistance: UILabel!
    @IBOutlet weak var lblState: UILabel!

    private var lblNoData: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNoDataLabel()

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)

        if defaults.integer(forKey: "Unit") == 0 {
            lblSetDistance.text = "\(nearbyRange[defaults.integer(forKey: "Distance")])MI"
        }else{
            lblSetDistance.text = "\(nearbyRange[defaults.integer(forKey: "Distance")])KM"
        }

        lblNoData.isHidden = true
        locationSettings()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        /*
        if UserDefaults.standard.bool(forKey: "introNearByMasajid") != true {
            UserDefaults.standard.set(true, forKey: "introNearByMasajid")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Nearby Masajid"
            vc.screenName = "nearby_masajid"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }

    private func setupNoDataLabel() {
        lblNoData = UILabel()
        lblNoData.text = "No masajid found nearby. Try increasing the search distance in settings."
        lblNoData.textColor = .darkGray
        lblNoData.font = UIFont(name: "PTSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        lblNoData.textAlignment = .center
        lblNoData.numberOfLines = 0
        lblNoData.translatesAutoresizingMaskIntoConstraints = false
        lblNoData.isHidden = true
        view.addSubview(lblNoData)

        NSLayoutConstraint.activate([
            lblNoData.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lblNoData.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lblNoData.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblNoData.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item4"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func shareData(){
        
        var text2Share = "****** allMasajid - Masajid NearBy ******\n\n"
        
        for key in 0..<data.count {
            let masjidName = data[key].name.uppercased()
            text2Share = text2Share + "- \(masjidName)\n"
        }
        
        text2Share = text2Share + "\n\nLooking for the nearest Masajid at a remote or exotic location? We may find you the one. allMasajid can locate you to the nearby area Masajid to the shortest possible distance at any moment.\nFor Android: https://bit.ly/2zCeFwM\nFor IOS: https://apple.co/2zHQXzo\nEffortlessly locate Masajids. Download our app now."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activity.popoverPresentationController?.sourceView = self.lblCity
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            guard let location = LocationManager.shared.myLocation else { return }
            myLocation = location
            getCity()
            getNearbyMasjids(loc: myLocation.coordinate)
        }
    }
    
    @objc func btnOptionTapped(sender : UIButton){
        displayAlert(index: sender.tag)
    }
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NearbyMasajidViewController: ThreeDotProtocol {
    
    func refreshBtnPressed() {
        
        data.removeAll()
        lblNoData.isHidden = true
        tblView.isHidden = false
        locationSettings()
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "nearby_masajid"
        vc.titleStr = "Nearby Masajid"
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
        shareData()
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

extension NearbyMasajidViewController {
    
    
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

extension NearbyMasajidViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasajidCell", for: indexPath) as! NearbyMasajidTableViewCell
        let item = data[indexPath.row]
        let dist = String(item.distance)
        
        if defaults.integer(forKey: "Unit") == 0 {
            cell.lblDistance.text = dist.toLengthOf(length: 3) + " mi."
        }
        else {
            cell.lblDistance.text = dist.toLengthOf(length: 3) + " km"
        }
        
        cell.lblMasjidName.text = item.name
        cell.btnOption.addTarget(self, action: #selector(btnOptionTapped(sender:)), for: .touchUpInside)
        
        cell.btnOption.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        displayAlert(index: indexPath.row)
    }
}

extension NearbyMasajidViewController {
    
    func addToMyMasjaid(item : MasjidItem){
        HUD.show(.progress)
        var locationToSend = ""
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: item.location.coordinate.latitude, longitude:item.location.coordinate.longitude)) { (places, error) in
            if error == nil{
                if let place = places{
                    let myPlace = "\(place)"
                    if myPlace.contains("@"){
                        let newStr = myPlace.components(separatedBy: "@")
                        locationToSend = newStr[0]
                        if locationToSend.first == "["{
                            locationToSend = String(locationToSend.dropFirst())
                        }
                        self.networkHit(location: locationToSend, item: item)
                    }
                }
            }else {
                print(error as Any)
                self.networkHit(location: "", item: item)
            }
        }
    }
    
    func displayAlert(index:Int){
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "Avenir-Heavy", size: 18)!,
            kTextFont: UIFont(name: "Avenir-Heavy", size: 16)!,
            kButtonFont: UIFont(name: "Avenir-Heavy", size: 16)!,
            showCloseButton: true,
            showCircularIcon: false,
            titleColor:#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        )
        
        let item = data[index]
        
        let alert = SCLAlertView(appearance: appearance)
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            
            _ = alert.addButton("Add To My Masajid"){
                
                self.addToMyMasjaid(item: item)
            }
        }
        _ = alert.addButton("Direction"){
            self.getDirectionsToMasjid(item: item)
        }
        
        _ = alert.addButton("Iqamah"){
            
            let vc = UIStoryboard().LoadDisplayIqamahScreen()
            vc.masjidIDReceived = item.id
            vc.masjidName = item.name
            vc.address = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        _ = alert.addButton("Events"){
                                    
            let vc = UIStoryboard().LoadEventScreen()
            vc.checkScreen = "nearby"
            vc.myLocation = self.myLocation
            vc.selectedMasjid = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        _ = alert.addButton("Announcements"){
            let vc = UIStoryboard().LoadAnnouncementsScreen()
            vc.checkScreen = "nearby"
            vc.selectedMasjid = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let color = #colorLiteral(red: 0.05882352941, green: 0.4509803922, blue: 0.8274509804, alpha: 1)
        alert.showCustom("\(item.name)", subTitle: "", color: color, icon: #imageLiteral(resourceName: "logo"))
    }
    
    func getDirectionsToMasjid(item: MasjidItem){
        
        if (UIApplication.shared.canOpenURL(URL(string:"https://www.google.com/maps/")!)) {
            
            UIApplication.shared.open(URL(string:
                "https://www.google.com/maps?saddr=\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)&daddr=\(item.location.coordinate.latitude),\(item.location.coordinate.longitude)")!, options: [:], completionHandler: nil)
        } else {
            let directionsURL = "http://maps.apple.com/?daddr=\(item.location.coordinate.latitude),\(item.location.coordinate.longitude)&t=m&z=10"
            guard let url = URL(string: directionsURL) else {
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func getCity(){

        CLGeocoder().reverseGeocodeLocation(myLocation, completionHandler: {(placemarks, error) in
            if (error != nil) {
                //print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }

            if let placemarks = placemarks, let pm = placemarks.first {
                self.lblCity.text = "\(pm.locality ?? "")"
                self.lblState.text = "\(pm.administrativeArea ?? ""), \(pm.country ?? "")"
            }
        })
    }
    
    func tryAgain() {
        refreshBtnPressed()
    }
}

extension NearbyMasajidViewController {
    
    func networkHit(location: String, item: MasjidItem){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false

//        let headers = ["Authorization": "Bearer \(myToken)"]
        let parameters = ["google_masajid_id": "\(item.id)",
                            "name": "\(item.name)",
                            "lat": "\(item.location.coordinate.latitude)",
                            "long": "\(item.location.coordinate.longitude)",
                            "address": "\(location)"
        ]
        APIRequestUtil.AddMasjid(parameters: parameters,headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "message"{
                HUD.flash(.labeledSuccess(title: "Message", subtitle: "Masjid Added successfully"), delay: 0.7)
            }
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}


extension NearbyMasajidViewController: TryAgainProtocol{

    func getNearbyMasjids(loc : CLLocationCoordinate2D){

        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false

        var unit = ""
        var radius = 0.0
        let distanceIndex = defaults.integer(forKey: "Distance")
        let distanceValue = Double(nearbyRange[distanceIndex]) ?? 5.0

        if defaults.integer(forKey: "Unit") == 0 {
            // Miles - pass the distance value directly with unit M
            radius = distanceValue
            unit = "M"
        } else {
            // Kilometers - pass the distance value directly with unit K
            radius = distanceValue
            unit = "K"
        }

        print("Fetching nearby masajid: lat=\(loc.latitude), long=\(loc.longitude), radius=\(radius), unit=\(unit)")
        APIRequestUtil.GetNearByMasajid(latitude: "\(loc.latitude)", longitude: "\(loc.longitude)", radius: "\(radius)", units: "\(unit)", completion: APIRequestNearbyCompleted)
    }

    fileprivate func APIRequestNearbyCompleted(response: Any?, error: Error?) {

        HUD.hide()
        self.view.isUserInteractionEnabled = true

        if let response = response{

            let json = JSON(response)
            print("Nearby Masajid Response: \(json)")

            data.removeAll()

            self.data = CommonApiResponse.shared.nearByMasajid(json: json)
            self.data = self.data.sorted(by: { (first, second) -> Bool in
                first.distance < second.distance
            })

            self.tblView.reloadData()

            if self.data.isEmpty {
                // Show no data label when no masajid found
                let distanceIndex = defaults.integer(forKey: "Distance")
                let distanceValue = nearbyRange[distanceIndex]
                let unitStr = defaults.integer(forKey: "Unit") == 0 ? "miles" : "kilometers"
                self.lblNoData.text = "No masajid found within \(distanceValue) \(unitStr). Try increasing the search distance in settings."
                self.lblNoData.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.lblNoData.isHidden = true
                self.tblView.isHidden = false
            }

        } else {
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}

extension String {
    
    func toLengthOf(length:Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return String(self.prefix(upTo: to))
            
        } else {
            return ""
        }
    }
}
