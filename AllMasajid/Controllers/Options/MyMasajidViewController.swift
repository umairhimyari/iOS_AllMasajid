//
//  MyMasajidViewController.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 1/10/19.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SCLAlertView
import PKHUD
import SwiftyJSON
import SafariServices

class MyMasajidViewController: UIViewController, ReloadDelegate, ThreeDotProtocol {
    
    var myMasajidArr = [MyMasajidModel]()
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
        
    @objc var objectToObserve: LocationManager!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
        
        setupGesturesInitials()
        locationSettings()
        /*
        if UserDefaults.standard.bool(forKey: "introMyMasajid") != true {
            UserDefaults.standard.set(true, forKey: "introMyMasajid")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "My Masajid"
            vc.screenName = "my_masajid"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }
   
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item4"
        self.parent?.present(vc, animated: false, completion: nil)
    }
   
    func reloadScreenData(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)

        locationSettings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HUD.hide()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            myLocation = LocationManager.shared.myLocation!
            self.networkHit()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnOptionTapped(sender : UIButton){
        displayAlert(itemIndex: sender.tag)
    }
    
    func tryAgain() {
        refreshBtnPressed()
    }
}

extension MyMasajidViewController {
    func refreshBtnPressed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                   
            HUD.show(.labeledProgress(title: "Loading Data", subtitle: "Please Wait ..."))
        }
        
        let vc = UIStoryboard().LoadLoadingScreen()
        vc.reloadDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "my_masajid"
        vc.titleStr = "My Masajid"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shareBtnPressed() {
        shareData()
    }
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension MyMasajidViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myMasajidArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMasajidCell", for: indexPath) as! MyMasajidTableViewCell
    
        let item = myMasajidArr[indexPath.row]
        let masjidLoc = CLLocation(latitude: Double(item.lat)!, longitude: Double(item.long )!)
       
        let dist : CLLocationDistance = masjidLoc.distance(from: myLocation)
      
        var distance : Double = 0.0
        var distanceString : String = ""
    
        if defaults.integer(forKey: "Unit") == 0 {
            
            distance =  Double(dist/1000) * 0.6213
            distanceString = String(describing: distance).toLengthOf(length: 3) + " mi."
        }else{
            
            distance =  Double(dist/1000)
            distanceString = String(describing: distance).toLengthOf(length: 3) + " km."
        }
        
        cell.lblDistance.text = distanceString
        cell.lblMasjidName.text = item.name
        cell.btnOption.addTarget(self, action: #selector(btnOptionTapped(sender:)), for: .touchUpInside)
        cell.btnOption.tag = indexPath.row
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        displayAlert(itemIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MyMasajidViewController: TryAgainProtocol{
    
    func networkHit(){
        if self.myMasajidArr.isEmpty == false {
            self.myMasajidArr.removeAll()
        }
        
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.GetMasajid(headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    func networkHitRemoveMasjid(item : MyMasajidModel, tag : Int){

//        let headers = ["Authorization": "Bearer \(myToken)"]
        let id = item.id
        APIRequestUtil.RemoveMasjid(id: "\(id)", headers: httpHeaders, completion: APIRequestRemoveMasjidCompleted)
    }
        
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let masajid = json["masajid"].arrayValue
            if masajid.count > 0{
                self.myMasajidArr.removeAll()
                
                for index in 0..<masajid.count{
                    let model = MyMasajidModel(fromJson: masajid[index])
                    myMasajidArr.append(model)
                }
                
                //sorting...
                self.myMasajidArr = self.myMasajidArr.sorted(by: { (first, second) -> Bool in

                    let currLoc = CLLocation(latitude: self.myLocation.coordinate.latitude, longitude: self.myLocation.coordinate.longitude)

                    let masjid1Loc = CLLocation(latitude: first.lat.toDouble() ?? 0.0, longitude: first.long.toDouble() ?? 0.0)

                    let masjid2Loc = CLLocation(latitude: second.lat.toDouble() ?? 0.0, longitude: second.long.toDouble() ?? 0.0)

                    let dist1 : CLLocationDistance = masjid1Loc.distance(from: currLoc)

                    let dist2 : CLLocationDistance = masjid2Loc.distance(from: currLoc)

                    return dist1 < dist2
                })
                tblView.reloadData()
            } else {
                self.myMasajidArr.removeAll()
                tblView.reloadData()
                Alert.showMsg(title: "No masjid found.", msg: "Please add new masjid from nearby masajid.", btnActionTitle: "Ok")
            }
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.7)
        }
    }

    fileprivate func APIRequestRemoveMasjidCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            let masajid = json["masajid"].arrayValue
            if masajid.count > 0{
                self.myMasajidArr.removeAll()
                
                for index in 0..<masajid.count{
                    let model = MyMasajidModel(fromJson: masajid[index])
                    myMasajidArr.append(model)
                }
                
                //sorting...
                self.myMasajidArr = self.myMasajidArr.sorted(by: { (first, second) -> Bool in

                    let currLoc = CLLocation(latitude: self.myLocation.coordinate.latitude, longitude: self.myLocation.coordinate.longitude)

                    let masjid1Loc = CLLocation(latitude: first.lat.toDouble() ?? 0.0, longitude: first.long.toDouble() ?? 0.0)

                    let masjid2Loc = CLLocation(latitude: second.lat.toDouble() ?? 0.0, longitude: second.long.toDouble() ?? 0.0)

                    let dist1 : CLLocationDistance = masjid1Loc.distance(from: currLoc)

                    let dist2 : CLLocationDistance = masjid2Loc.distance(from: currLoc)

                    return dist1 < dist2
                })
                tblView.reloadData()
            } else {
                self.myMasajidArr.removeAll()
                tblView.reloadData()
                Alert.showMsg(title: "No masjid found.", msg: "Please add new masjid from nearby masajid.", btnActionTitle: "Ok")
            }
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.7)
        }
    }
}

extension MyMasajidViewController {
    
    func locationSettings(){
      
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.networkHit()
                }
            } catch { print(error) }
            
            
//            if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
//            let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
//                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
//                self.networkHit()
//            }
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                networkHit()
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
        }
    }
    
    func observeLocation(object: LocationManager) {
        objectToObserve = object
        if (objectToObserve.myLocation == nil)
        {
            showLocationAlert()
            
        }else{
            self.networkHit()
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

extension MyMasajidViewController {
    
    func displayAlert(itemIndex:Int) -> Void {

        let item = myMasajidArr[itemIndex]

        //let margin = SCLAlertView.SCLAppearance.Margin(buttonSpacing: 2, bottom: 10, horizontal: 10)

        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "Avenir-Heavy", size: 18)!,
            kTextFont: UIFont(name: "Avenir-Heavy", size: 16)!,
            kButtonFont: UIFont(name: "Avenir-Heavy", size: 16)!,
            showCloseButton: true,
            showCircularIcon: false,
            titleColor:#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            //margin: margin
        )

        let alert = SCLAlertView(appearance: appearance)

        _ = alert.addButton("Remove From My Masajid"){
            self.networkHitRemoveMasjid(item: item, tag: itemIndex)
        }

        _ = alert.addButton("Direction"){
            self.getDirectionsToMasjid(item: item)
        }

        _ = alert.addButton("Iqamah"){
            let vc = UIStoryboard().LoadDisplayIqamahScreen()
            vc.masjidIDReceived = item.google_masajid_id
            vc.masjidName = item.name
            vc.address = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }

        _ = alert.addButton("Events"){
            let vc = UIStoryboard().LoadEventScreen()
            vc.checkScreen = "myMasajid"
            vc.myLocation = self.myLocation
            vc.masjidReceived = item
            self.navigationController?.pushViewController(vc, animated: true)
        }

        _ = alert.addButton("Announcements"){
            let vc = UIStoryboard().LoadAnnouncementsScreen()
            vc.checkScreen = "myMasajid" // checkScreen = "other" for nearby & myMasajids screen | checkScreen = "landing" for landing screen
            vc.masjidReceived = item
            self.navigationController?.pushViewController(vc, animated: true)
        }

        let color = #colorLiteral(red: 0.05882352941, green: 0.4509803922, blue: 0.8274509804, alpha: 1)

        let masjidName = item.name
        _ = alert.showCustom("\(masjidName)", subTitle: "", color: color, icon: #imageLiteral(resourceName: "logo"))

    }
    
    func shareData(){
        
        var text2Share = "****** allMasajid - My Masajid ******\n\n"
        
        for key in 0..<myMasajidArr.count {
            let masjidName = myMasajidArr[key].name.uppercased()
            text2Share = text2Share + "- \(masjidName)\n"
        }
        
        text2Share = text2Share + "\n\nPromote your local Masajid among the folk. Through the allMasajid app, share your Masajid activities or contribute to Masajid cause for community and organization’s well-being.\nFor Android: https://bit.ly/2zCeFwM\nFor IOS: https://apple.co/2zHQXzo\nDownload our app to support your area’s Masajid."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activity.popoverPresentationController?.sourceView = self.footerView
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
    }
    
    func setupGesturesInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
    }
  
    
    func getDirectionsToMasjid(item: MyMasajidModel){
        
        if (UIApplication.shared.canOpenURL(URL(string:"https://www.google.com/maps/")!)) {

            let lat = Double(item.lat)
            let destLat = CLLocationDegrees(exactly: lat!)
            let lng = Double(item.long)
            let destLng = CLLocationDegrees(exactly: lng!)
            UIApplication.shared.open(URL(string:
            "https://www.google.com/maps?saddr=\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)&daddr=\(destLat!),\(destLng!)")!, options: [:], completionHandler: nil)
        } else {
            let directionsURL = "http://maps.apple.com/?daddr=\(String(describing: item.lat)),\(String(describing: item.long))&t=m&z=10"
            guard let url = URL(string: directionsURL) else {
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension MyMasajidViewController {
    
    func dataFetched(_ succes: Bool) {

        self.reloadScreenData()
    }
}
