//
//  EventsNewVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 26/09/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import SafariServices
import PKHUD
import SwiftyJSON
import MessageUI
import CoreLocation

class EventsNewVC: UIViewController, TryAgainProtocol {

    var myLocation = CLLocation()
    var observation: NSKeyValueObservation?
    @objc var objectToObserve: LocationManager!
    
    var selectedSegment = 1
    var eventsArr = [EventsModel]()
    
    var nonMasajidArr = [OrganizationsModel]()
    
    @IBOutlet weak var mySegCtrl: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if UserDefaults.standard.bool(forKey: "introEvents") != true {
            UserDefaults.standard.set(true, forKey: "introEvents")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Events"
            vc.screenName = "events"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
        locationSettings()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item1"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func segmentCtrlPressed(_ sender: UISegmentedControl) {
        
        switch mySegCtrl.selectedSegmentIndex{
        case 0:
            selectedSegment = 1
            eventsArr.removeAll()
            networkHitNearByEvents(loc: self.myLocation.coordinate)
            myTableView.reloadData()
            break
            
        case 1:
            selectedSegment = 2
            eventsArr.removeAll()
            networkHitFavoriteEvents()
            myTableView.reloadData()
            break
            
        case 2:
            selectedSegment = 3
            eventsArr.removeAll()
            networkHitPersonalEvents()
            myTableView.reloadData()
            break
            
        case 3:
            selectedSegment = 4
            nonMasajidArr.removeAll()
            networkHitNonMasajidEvents(loc: self.myLocation.coordinate)
            myTableView.reloadData()
            break
            
        default:
            break
        }
    }
    
    @IBAction func emailBtnPressed(_ sender: UIButton) {
        sendMail()
    }
    
    func tryAgain() {
        refreshBtnPressed()
    }
}

extension EventsNewVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        let vc = UIStoryboard().LoadAddOptionScreen()
        vc.screen = "Event"
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "events"
        vc.titleStr = "Events"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        eventsArr.removeAll()
        selectedSegment = 1
        mySegCtrl.selectedSegmentIndex = 0
        locationSettings()
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension EventsNewVC: PerformActionProtocol {
    
    func addMasajidPressed() {
        let vc = UIStoryboard().LoadAddEventScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addNonMasajidPressed() {
        let vc = UIStoryboard().LoadAddNonMasjidEventScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventsNewVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSegment == 4 ? nonMasajidArr.count : eventsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var myCell: UITableViewCell?
        
        if selectedSegment == 1 || selectedSegment == 2 { // NearBy Events
            let cell = myTableView.dequeueReusableCell(withIdentifier: "EventTVC", for: indexPath) as! EventTVC
            myCell = cell
            cell.eventTitle?.text = eventsArr[indexPath.row].title
            cell.eventDescriptionLabel?.text = eventsArr[indexPath.row].date == "" ? "-" : eventsArr[indexPath.row].date
            cell.dateLBL.text = "\(eventsArr[indexPath.row].time), \(eventsArr[indexPath.row].date)"
            
            if eventsArr[indexPath.row].status == 1{
                cell.verifyImageView.image = #imageLiteral(resourceName: "verifiedIcon")
            }else if eventsArr[indexPath.row].status == 0{
                cell.verifyImageView.image = #imageLiteral(resourceName: "unverifiedIcon")
            }
            
            if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
                cell.favoriteBTN.addTarget(self, action: #selector(loginAlert), for: .touchUpInside)
            }else{
                let fav = eventsArr[indexPath.row].fav
                if fav == 0 {
                    cell.favoriteBTN.setImage(#imageLiteral(resourceName: "heart-grey"), for: .normal)
                    cell.favoriteBTN.addTarget(self, action: #selector(favouriteBtnPressed), for: .touchUpInside)
                }else if fav == 1{
                    cell.favoriteBTN.setImage(#imageLiteral(resourceName: "heart-green"), for: .normal)
                    cell.favoriteBTN.addTarget(self, action: #selector(removeFavourite), for: .touchUpInside)
                }
            }
            cell.favoriteBTN.tag = eventsArr[indexPath.row].id
            
            let image = eventsArr[indexPath.row].image
            
            if image != ""{
                GetImage.getImage(url: URL(string: image)!, image: cell.eventImageView)
            }
        }else if selectedSegment == 3 { // Mine Events
            let cell = myTableView.dequeueReusableCell(withIdentifier: "MyEventsTVC", for: indexPath) as! MyEventsTVC
            myCell = cell
            cell.eventTitle?.text = eventsArr[indexPath.row].title
            cell.eventDescriptionLabel?.text = eventsArr[indexPath.row].date == "" ? "-" : eventsArr[indexPath.row].date
            cell.dateLBL.text = "\(eventsArr[indexPath.row].time), \(eventsArr[indexPath.row].date)"
            
            if eventsArr[indexPath.row].status == 1{
                cell.verifyImageView.image = #imageLiteral(resourceName: "verifiedIcon")
            }else if eventsArr[indexPath.row].status == 0{
                cell.verifyImageView.image = #imageLiteral(resourceName: "unverifiedIcon")
            }
            
            cell.removeBTN.addTarget(self, action: #selector(removePersonalEventPressed), for: .touchUpInside)
            cell.reScheduleBTN.addTarget(self, action: #selector(reschedulePersonalEventPressed), for: .touchUpInside)
            cell.removeBTN.tag = eventsArr[indexPath.row].id
            cell.reScheduleBTN.tag = eventsArr[indexPath.row].id
            
            let image = eventsArr[indexPath.row].image
            
            if image != ""{
                GetImage.getImage(url: URL(string: image)!, image: cell.eventImageView)
            }
        }else if selectedSegment == 4 {
            let cell = myTableView.dequeueReusableCell(withIdentifier: "EventTVC", for: indexPath) as! EventTVC
            myCell = cell
            cell.eventTitle?.text = nonMasajidArr[indexPath.row].title
            cell.eventDescriptionLabel?.text = nonMasajidArr[indexPath.row].date == "" ? "-" : nonMasajidArr[indexPath.row].date
            cell.dateLBL.text = "\(nonMasajidArr[indexPath.row].time), \(nonMasajidArr[indexPath.row].date)"
            
            if nonMasajidArr[indexPath.row].status == 1{
                cell.verifyImageView.image = #imageLiteral(resourceName: "verifiedIcon")
            }else if nonMasajidArr[indexPath.row].status == 0{
                cell.verifyImageView.image = #imageLiteral(resourceName: "unverifiedIcon")
            }
            
            cell.favoriteBTN.isHidden = true
            
            let image = nonMasajidArr[indexPath.row].image
            
            if image != ""{
                GetImage.getImage(url: URL(string: image)!, image: cell.eventImageView)
            }
        }
        
        return myCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedSegment == 4 {
            
        }else{
            let vc = UIStoryboard().LoadEventDetailsScreen()
            vc.IdReceived = eventsArr[indexPath.row].id
            vc.myLocation = self.myLocation
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedSegment == 3 ? 95 : 85
    }
    
    @objc func favouriteBtnPressed(sender: UIButton){
        networkHitMakeFavourite(id: sender.tag)
    }
    
    @objc func removeFavourite(sender: UIButton){
        networkHitUnFavourite(id: sender.tag)
    }
    
    @objc func loginAlert(sender: UIButton){
        HUD.flash(.label("Please login to enjoy this feature"), delay: 0.7)
    }
    
    @objc func reschedulePersonalEventPressed(sender: UIButton){
        HUD.flash(.label("Soon inShah ALLAH"), delay: 0.8)
        //networkHitRescheduleEvent(id: sender.tag)
    }
    
    @objc func removePersonalEventPressed(sender: UIButton){
        networkHitRemoveEvent(id: sender.tag)
    }
}

extension EventsNewVC: CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "EventTVC", bundle: nil), forCellReuseIdentifier: "EventTVC")
        myTableView.register(UINib(nibName: "MyEventsTVC", bundle: nil), forCellReuseIdentifier: "MyEventsTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        selectedSegment = 1
        eventsArr.removeAll()
        mySegCtrl.selectedSegmentIndex = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" //"yyyy-MM-dd HH:mm:ss Z"
        let now = Date()
        let dateString = formatter.string(from:now)
        dateLabel.text = dateString
                
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    func sendMail(){
        let myTodayDate = getTodayDate()
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(emailEvents)"])
            mail.setSubject("Add Event Request")
            mail.setMessageBody("<p><br><br><br> Date & Time = \(myTodayDate)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            openGmail()
        }
    }
    
    func openGmail(){
        
        let myTodayDate = getTodayDate()
        let address = emailEvents
        let subject = "Add Event Request"
        let buildInfo = "Date & Time = \(myTodayDate)"
        let googleUrlString = "googlegmail:///co?to=\(address.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&subject=\(subject.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&body=\(buildInfo.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"

        if let googleUrl = URL(string: googleUrlString) {
            UIApplication.shared.open(googleUrl, options: [:]) {
                success in
                if !success {
                    HUD.flash(.labeledError(title: "Unable to send email", subtitle: "Make sure you have mail app setup"), delay: 0.8)
                }
            }
        }
        else {
            HUD.flash(.labeledError(title: "Unable to send email", subtitle: "Make sure you have mail app setup"), delay: 0.8)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func getTodayDate() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h:mm a"

        let now = Date()
        return "\(formatter2.string(from:now)), \(formatter.string(from:now))"
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func locationSettings(){
        
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.networkHitNearByEvents(loc: self.myLocation.coordinate)
                }
            } catch { print(error) }
            
        }else if defaults.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.networkHitNearByEvents(loc: self.myLocation.coordinate)
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                networkHitNearByEvents(loc: self.myLocation.coordinate)
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

extension EventsNewVC {
    func networkHitNearByEvents(loc : CLLocationCoordinate2D){
        
        var unit = ""
        let distance = "\((nearbyRange[defaults.integer(forKey: "Distance")]))"
        
        if defaults.integer(forKey: "Unit") == 0 {
            unit = "M"
        }else{
            unit = "K"
        }
        
        let parameters = ["lat": "\(loc.latitude)", "long": "\(loc.longitude)", "unit": unit, "distance": distance]
        HUD.show(.progress)
        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
            APIRequestUtil.GetNearByEvents(parameters: parameters, headers: [:], completion: APIRequestNearByMasjidCompleted)
        }else{
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.GetNearByEvents(parameters: parameters, headers: httpHeaders, completion: APIRequestNearByMasjidCompleted)
        }
        
    }
    
    fileprivate func APIRequestNearByMasjidCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            eventsArr.removeAll()
                      
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error"{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }else{
                for index in 0..<json.count{
                    let model = EventsModel(fromJson: json[index])
                    eventsArr.append(model)
                }
                
                if eventsArr.count == 0{
                    HUD.flash(.label("No Data Found"), delay: 0.7)
                }
            }
            HUD.hide()
            myTableView.reloadData()
            
        }else{
            HUD.hide()
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EventsNewVC {
    func networkHitFavoriteEvents(){
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
            eventsArr.removeAll()
            myTableView.reloadData()
            HUD.flash(.label("Please login to enjoy this feature"), delay: 0.7)
            
        }else{
            HUD.show(.progress)
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.GetFavoriteEvents(headers: httpHeaders, completion: APIRequestFavoriteCompleted)
        }
    }
    
    fileprivate func APIRequestFavoriteCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            eventsArr.removeAll()
                        
            let favourite_events = json["favourite_events"].arrayValue
            for index in 0..<favourite_events.count{
                let model = EventsModel(fromJson: favourite_events[index])
                eventsArr.append(model)
            }
            myTableView.reloadData()
            
            if eventsArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            HUD.hide()
        }else{
            HUD.hide()
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EventsNewVC{
    
    func networkHitMakeFavourite(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.MakeFavoriteEvent(id: "\(id)", headers: httpHeaders, completion: APIRequestMakeFavouriteCompleted)
    }
    
    fileprivate func APIRequestMakeFavouriteCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            HUD.hide()
            networkHitNearByEvents(loc: self.myLocation.coordinate)
            
        }else{
            HUD.hide()
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EventsNewVC{
    
    func networkHitUnFavourite(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.RemoveFavoriteEvent(id: "\(id)", headers: httpHeaders, completion: APIRequestUnFavouriteCompleted)
    }
    
    fileprivate func APIRequestUnFavouriteCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            if selectedSegment == 1{
                networkHitNearByEvents(loc: self.myLocation.coordinate)
            }else if selectedSegment == 2{
                networkHitFavoriteEvents()
            }

        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EventsNewVC{
    
    func networkHitRescheduleEvent(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.RescheduleEvent(id: "\(id)", headers: httpHeaders, completion: APIRequestRescheduleEventCompleted)
    }
    
    fileprivate func APIRequestRescheduleEventCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            networkHitPersonalEvents()
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EventsNewVC{
    
    func networkHitRemoveEvent(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.RemovePersonalEvent(id: "\(id)", headers: httpHeaders, completion: APIRequestRemoveEventCompleted)
    }
    
    fileprivate func APIRequestRemoveEventCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            networkHitPersonalEvents()
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EventsNewVC{
    
    func networkHitPersonalEvents(){
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
            eventsArr.removeAll()
            myTableView.reloadData()
            HUD.flash(.label("Please login to enjoy this feature"), delay: 0.7)
            
        }else{
            HUD.show(.progress)
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.GetPersonalEvents(headers: httpHeaders, completion: APIRequestPersonalEventsCompleted)
        }
    }
    
    fileprivate func APIRequestPersonalEventsCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            eventsArr.removeAll()
                        
            let event = json["event"].arrayValue
            for index in 0..<event.count{
                let model = EventsModel(fromJson: event[index])
                eventsArr.append(model)
            }
            HUD.hide()
            myTableView.reloadData()
            
            if eventsArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            
        }else{
            HUD.hide()
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}


extension EventsNewVC {
    
    func networkHitNonMasajidEvents(loc : CLLocationCoordinate2D) {
        
        HUD.show(.progress)
        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true {
            APIRequestUtil.GetNonMasajidEvents(lat: "\(loc.latitude)", long: "\(loc.longitude)", headers: [:], completion: APIRequestNonMasjidEventsCompleted)
        }else{
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.GetNonMasajidEvents(lat: "\(loc.latitude)", long: "\(loc.longitude)", headers: httpHeaders, completion: APIRequestNonMasjidEventsCompleted)
        }
    }
    
    fileprivate func APIRequestNonMasjidEventsCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            nonMasajidArr.removeAll()
                        
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error"{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }else{
                
                for index in 0..<json.count{
                    let model = OrganizationsModel(fromJson: json[index])
                    nonMasajidArr.append(model)
                }
                
                if nonMasajidArr.count == 0{
                    HUD.flash(.label("No Data Found"), delay: 0.7)
                }
            }
            myTableView.reloadData()
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
