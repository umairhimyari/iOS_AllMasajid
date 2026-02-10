//
//  IqamahVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import CoreLocation
//import Adhan
import SCLAlertView
import MessageUI
import SafariServices

class IqamahVC: UIViewController {
    
    var isJummah = false
    
    var currentPrayer: Prayer?
    var fajrCurr: Date?
    var duhrCurr: Date?
    var asrCurr: Date?
    var maghribCurr: Date?
    var ishaCurr: Date?
    var sunriseCurr: Date?
    var chashtCurr: Date?
    var awabeenCurr: Date?
    var ishraqCurr: Date?
    var tahajjudCurr: Date?
    
    var masajidList = [IqamahNearByModel]()
    
    var finalLat: Double = 0
    var finalLong: Double = 0
    
    var currentTime = ""
    var currentNamaz = ""
    var selectedNamaz = ""
        
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()

    @objc var objectToObserve: LocationManager!

    @IBOutlet weak var namazTitleLBL: UILabel!
    @IBOutlet weak var footrView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var namazNameLBL: UILabel!
    
    @IBOutlet weak var filterIqamahLBL: UILabel!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var filterFajrBTN: UIButton!
    @IBOutlet weak var filterDuhrBTN: UIButton!
    @IBOutlet weak var filterAsrBTN: UIButton!
    @IBOutlet weak var filterMagribBTN: UIButton!
    @IBOutlet weak var filterIshaBTN: UIButton!
    @IBOutlet weak var filterJummahBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if UserDefaults.standard.bool(forKey: "introIqamah") != true {
            UserDefaults.standard.set(true, forKey: "introIqamah")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Iqamah"
            vc.screenName = "iqamah"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item5"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func applyFilterBtnPressed(_ sender: UIButton) {
        blackView.isHidden = false
        menuView.isHidden = false
    }
    
    @IBAction func filterBtnPressed(_ sender: UIButton) {
        neutralNamazBtn()
        sender.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        if sender.tag == 1 {
            selectedNamaz = "fajr"
        }else if sender.tag == 2 {
            selectedNamaz = "duhr"
        }else if sender.tag == 3 {
            selectedNamaz = "asr"
        }else if sender.tag == 4 {
            selectedNamaz = "maghrib"
        }else if sender.tag == 5 {
            selectedNamaz = "isha"
        }else if sender.tag == 6 {
            selectedNamaz = "jummah"
        }
    }
    
    @IBAction func saveFilterPressed(_ sender: UIButton) {
        blackView.isHidden = true
        menuView.isHidden = true
        setupSelectedNamaz(namaz: selectedNamaz)
        networkHit(loc: myLocation.coordinate)
    }
    
    @IBAction func emailBtnPressed(_ sender: UIButton) {
        sendMail()
    }
}

extension IqamahVC: ThreeDotProtocol {
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "iqamah"
        vc.titleStr = "Iqamah"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        masajidList.removeAll()
        locationSettings()
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
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

extension IqamahVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masajidList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "IqamahTVC", for: indexPath) as! IqamahTVC
        cell.masjidLBL.text = masajidList[indexPath.row].masjidName
        cell.distanceLBL.text = "\(masajidList[indexPath.row].distanceStr ?? "-")"
        
        if selectedNamaz == "jummah"{//isJummah == true  && currentNamaz == "duhr"{
            
            if masajidList[indexPath.row].jumah.count == 1 {
                cell.timeLBL.text = "\(masajidList[indexPath.row].jumah[0].time ?? "-")"
            }else if masajidList[indexPath.row].jumah.count > 1 {
                                
                let result = masajidList[indexPath.row].jumah.min { (first, second) -> Bool in
                    first.diff_time_number ?? 100000 < second.diff_time_number ?? 100000
                }

                cell.timeLBL.text = "\(result?.time ?? "-")"
                
            }else{
                cell.timeLBL.text = "-"
            }
            
            cell.nextTimeLBL.isHidden = true
            cell.viewAllBtn.isHidden = false
            cell.viewAllBtn.addTarget(self, action: #selector(jummahViewAllPressed), for: .touchUpInside)
            cell.viewAllBtn.tag = indexPath.row
            
        }else{
            cell.nextTimeLBL.isHidden = false
            cell.viewAllBtn.isHidden = true
            cell.nextTimeLBL.text = "Valid From: \(masajidList[indexPath.row].to_date ?? "-") To: \(masajidList[indexPath.row].end_date ?? "-")"
            cell.timeLBL.text = "\(masajidList[indexPath.row].time ?? "-")"
            
            let timeRemaining = "\(masajidList[indexPath.row].diff_time_number ?? "-")"
            cell.timeRemainingLBL.text =  timeRemaining == "-" ? "-" : "\(timeRemaining)m"
            let diffTime = masajidList[indexPath.row].time
            
            if diffTime == "-" {
                cell.isReachableVie.backgroundColor = .lightGray
            }else if masajidList[indexPath.row].isReachable == true {
                cell.isReachableVie.backgroundColor = #colorLiteral(red: 0.3490196078, green: 1, blue: 0, alpha: 1)
            }else if masajidList[indexPath.row].isReachable == false {
                cell.isReachableVie.backgroundColor = .red
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayAlert(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension IqamahVC{
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footrView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "IqamahTVC", bundle: nil), forCellReuseIdentifier: "IqamahTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
        getTodayDate()
        menuView.isHidden = true
        blackView.isHidden = true
        locationSettings()
        
    }
    
    @objc func jummahViewAllPressed(sender: UIButton) {
        let vc = UIStoryboard().LoadJummahIqamahScreen()
        vc.model = masajidList[sender.tag]
        vc.address = addressLBL.text ?? "N/A"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func getTodayDate(){

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"

        let now = Date()
        currentTime = formatter.string(from:now)
    }
    
    
}

extension IqamahVC: MFMailComposeViewControllerDelegate {
    
    func sendMail(){
        let myTodayDate = getCurrentDate()
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(emailIqamah)"])
            mail.setSubject("Add Iqamah Request")
            mail.setMessageBody("<p><br><br><br> Date & Time = \(myTodayDate)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            openGmail()
        }
    }
    
    func openGmail(){
        
        let myTodayDate = getCurrentDate()
        let address = emailIqamah
        let subject = "Add Iqamah Request"
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
    
    func getCurrentDate() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h:mm a"

        let now = Date()
        return "\(formatter2.string(from:now)), \(formatter.string(from:now))"
    }
}


extension IqamahVC: CLLocationManagerDelegate, TryAgainProtocol{
    
    func tryAgain() {
        refreshBtnPressed()
    }
    
    func networkHit(loc : CLLocationCoordinate2D) {
        HUD.show(.progress)
        
        var unit = ""
        var meters = 0.0
        if defaults.integer(forKey: "Unit") == 0 {
            meters = (Double(nearbyRange[defaults.integer(forKey: "Distance")])!/0.6213) * 1000
            unit = "M"
        }else{
            meters = Double(nearbyRange[defaults.integer(forKey: "Distance")])! * 1000
            unit = "K"
        }
        finalLat = loc.latitude
        finalLong = loc.longitude
        
        let maghribFormatter = DateFormatter()
        maghribFormatter.dateFormat = "h:mm"
        let maghribTime = maghribFormatter.string(from: maghribCurr!)
        
        APIRequestUtil.GetIqamahNearBy(long: "\(finalLong)", lat: "\(finalLat)", radius: "\(meters)", unit: unit, prayer: selectedNamaz, currTime: currentTime, maghrib: "\(maghribTime)", headers: [:], completion: APIRequestCompleted) //changed cuurentnamaz to selectednamaz
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            masajidList.removeAll()
            
            for index in 0..<json.count{
                
                let id = json[index]["place_id"].stringValue
                let masjidName = json[index]["name"].stringValue
                
                let geometry = json[index]["geometry"]
                let geoLocation = geometry["location"]
                let masjidLat = geoLocation["lat"].double ?? 0
                let masjidLong = geoLocation["lng"].double ?? 0
                let masjidLoc = CLLocation(latitude: masjidLat, longitude: masjidLong)
                
                var finalDist: Double = 0.0
                var finalDistStr = ""
                
                let unit = json[index]["unit"].stringValue
                var distance = json[index]["distance"].stringValue
                distance = distance == "" ? "0" : distance
                            
                finalDist = Double(distance) ?? 0.0
                finalDistStr = String(distance).toLengthOf(length: 3) + "\(unit)"
                
                let requestedPrayer = json[index]["\(selectedNamaz)"] // Currentnamaz to sleected namaz
                var end_date = requestedPrayer["end_date"].stringValue
                var diff_time = requestedPrayer["diff_time"].stringValue
                let diff_time_number = requestedPrayer["diff_time_number"].intValue
                var to_date = requestedPrayer["to_date"].stringValue
                var time = requestedPrayer["time"].stringValue
                let status = requestedPrayer["status"].intValue
                
                end_date = end_date == "" ? "-" : end_date
                diff_time = diff_time == "" ? "-" : diff_time
                to_date = to_date == "" ? "-" : to_date
                time = time == "" ? "-" : time
                
                let timeDuration = json[index]["timeDuration"]
                let timeRequiredSec = timeDuration["value"].intValue
                
                var isReachable = false
                
                if diff_time_number > (timeRequiredSec/60) {
                    isReachable = true
                }
                
                var diffMinutes = "-"
                if diff_time_number != 0 {
                    diffMinutes = "\(diff_time_number)"
                }
                
                
                var jummahArr = [IqamahJummahModel]()
                let jumah = json[index]["jumah"].arrayValue
                for i in 0..<jumah.count{
                    let model = IqamahJummahModel(type: "\(jumah[i]["type"].stringValue)", time: "\(jumah[i]["time"].stringValue)", diff_time: "\(jumah[i]["diff_time"].stringValue)", diff_time_number: jumah[i]["diff_time_number"].intValue)
                    jummahArr.append(model)
                }
                
                let model = IqamahNearByModel(googleMasjidID: id, masjidName: masjidName, distance: finalDist, distanceStr: finalDistStr, diff_time_number: diffMinutes, isReachable: isReachable, end_date: end_date, diff_time: diff_time, to_date: to_date, time: time, status: status, units: unit, timeRequiredSeconds: timeRequiredSec, location: masjidLoc, jumah: jummahArr)
                
                
                masajidList.append(model)
            }
            
            self.masajidList = self.masajidList.sorted(by: { (first, second) -> Bool in
                first.distance < second.distance
            })
            
            myTableView.reloadData()
            HUD.hide()
        }else{
            HUD.hide()
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}

extension IqamahVC {
    
    func locationSettings(){
        
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNamazTimings(loc: myLocation.coordinate)
//                    self.networkHit(loc: myLocation.coordinate)
                    self.getCity()
                }
            } catch { print(error) }
            
        }else if defaults.integer(forKey: "Location") == 2{
            
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNamazTimings(loc: myLocation.coordinate)
//                    self.networkHit(loc: myLocation.coordinate)
                    self.getCity()
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                self.getNamazTimings(loc: myLocation.coordinate)
                getCity()
//                networkHit(loc: myLocation.coordinate)
                
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            
            myLocation = LocationManager.shared.myLocation!
            self.getNamazTimings(loc: myLocation.coordinate)
            getCity()
//            networkHit(loc: myLocation.coordinate)
        }
    }
    
    func observeLocation(object: LocationManager) {
        objectToObserve = object
        if (objectToObserve.myLocation == nil){
            showLocationAlert()
        }else{
            self.getNamazTimings(loc: self.myLocation.coordinate)
            self.getCity()
//            self.networkHit(loc: self.myLocation.coordinate)
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
    
    func getCity(){
        
        let latt : String = "\(myLocation.coordinate.latitude)"
        let lonn : String = "\(myLocation.coordinate.longitude)"
        GetCityFromCordinates.sharedGetCity.getAddressFromLatLon(pdblLatitude: latt, withLongitude: lonn, lbl: addressLBL)
    }
}


extension IqamahVC {

    func getNamazTimings(loc : CLLocationCoordinate2D){
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        
        let myLat = loc.latitude
        let myLong = loc.longitude
        
        let coordinates = Coordinates(latitude: myLat, longitude: myLong)
        var params = calculationMethods[UserDefaults.standard.integer(forKey: "Method")].params
        
        if UserDefaults.standard.integer(forKey: "Prayers Calculation Method") == 1 {
            
            params = CalculationParameters(fajrAngle: Double(UserDefaults.standard.string(forKey: "FajrAngle")!)!, ishaAngle: Double(UserDefaults.standard.string(forKey: "IshaAngle")!)!)
        }
        
        params.madhab = madhabs[UserDefaults.standard.integer(forKey: "School/Juristic")]
        
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            
            currentPrayer = prayers.currentPrayer()
            var nextPrayer: Prayer?
            nextPrayer = prayers.nextPrayer()
            
            fajrCurr = prayers.fajr
            sunriseCurr = prayers.sunrise
            ishraqCurr = prayers.time(for: Prayer.ishraaq)
            chashtCurr = prayers.time(for: Prayer.chaasht)
            duhrCurr = prayers.dhuhr.addingTimeInterval(TimeInterval(6*60))
            asrCurr = prayers.asr
            maghribCurr = prayers.maghrib
            awabeenCurr = prayers.time(for: Prayer.awabeen)
            tahajjudCurr = prayers.time(for: Prayer.tahajjud)
            ishaCurr = prayers.isha
            
            if nextPrayer == Prayer.none || nextPrayer == nil{
                nextPrayer = Prayer.fajr
            }
            
            if currentPrayer == Prayer.none || currentPrayer == nil {
                currentPrayer = Prayer.fajr
            }
            
            if currentPrayer == Prayer.fajr {
                currentNamaz = "fajr"
            }else if currentPrayer == Prayer.sunrise || currentPrayer == Prayer.dhuhr || currentPrayer == Prayer.ishraaq || currentPrayer == Prayer.chaasht{
                currentNamaz = "duhr"
            }else if currentPrayer == Prayer.asr {
                currentNamaz = "asr"
            }else if currentPrayer == Prayer.maghrib {
                currentNamaz = "maghrib"
            }else if currentPrayer == Prayer.awabeen || currentPrayer == Prayer.isha {
                currentNamaz = "isha"
            }
            
//            if isJummah == true && currentNamaz == "duhr" {
//
//            }else{
//                if currentNamaz == "duhr" {
//
//                }else if currentNamaz == "isha"{
//
//                }else if currentNamaz == "maghrib"{
//
//                }else{
//                    namazNameLBL.text = currentNamaz.capitalized
//                }
//            }
            
            setupSelectedNamaz(namaz: currentNamaz)
            selectedNamaz = currentNamaz
            networkHit(loc: loc)
        }
    }
    
    func setupSelectedNamaz(namaz: String){
        neutralNamazBtn()
        
        if namaz == "fajr" {
            namazNameLBL.text = "Fajr"
            filterFajrBTN.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        }else if namaz == "duhr" {
            namazNameLBL.text = "Dhuhr"
            filterDuhrBTN.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        }else if namaz == "asr" {
            namazNameLBL.text = "Asr"
            filterAsrBTN.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        }else if namaz == "maghrib" {
            namazNameLBL.text = "Magrib"
            filterMagribBTN.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        }else if namaz == "isha" {
            namazNameLBL.text = "Isha'a"
            filterIshaBTN.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        }else if namaz == "jummah" || isJummah == true && namaz == "duhr"{
            namazNameLBL.text = "Jummah"
            filterJummahBTN.setImage(#imageLiteral(resourceName: "radioChecked"), for: .normal)
        }
        
        selectedNamaz = namaz
        namazTitleLBL.text = namazNameLBL.text ?? ""
        filterIqamahLBL.text = "Showing iqamah for \(namazNameLBL.text ?? "")"
        
        myTableView.reloadData()
    }
    
    func neutralNamazBtn(){
        filterFajrBTN.setImage(#imageLiteral(resourceName: "radioUnchecked"), for: .normal)
        filterDuhrBTN.setImage(#imageLiteral(resourceName: "radioUnchecked"), for: .normal)
        filterAsrBTN.setImage(#imageLiteral(resourceName: "radioUnchecked"), for: .normal)
        filterMagribBTN.setImage(#imageLiteral(resourceName: "radioUnchecked"), for: .normal)
        filterIshaBTN.setImage(#imageLiteral(resourceName: "radioUnchecked"), for: .normal)
        filterJummahBTN.setImage(#imageLiteral(resourceName: "radioUnchecked"), for: .normal)
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
        
        let item = MasjidItem()
        item.id = self.masajidList[index].googleMasjidID ?? ""
        item.name = self.masajidList[index].masjidName ?? ""
        item.location = self.masajidList[index].location
        item.distance = self.masajidList[index].distance
        
        let alert = SCLAlertView(appearance: appearance)
        
        _ = alert.addButton("Directions"){
            self.getDirectionsToMasjid(item: item)
        }
        /*
        _ = alert.addButton("Configure Iqamah"){
            let vc = UIStoryboard().LoadIqamahConfigureScreen()
            vc.masjidIDReceived = self.masajidList[index].googleMasjidID ?? ""
            vc.masjidName = self.masajidList[index].masjidName ?? ""
            vc.address = self.addressLBL.text ?? "-"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        */
        _ = alert.addButton("Display Iqamah"){
            let vc = UIStoryboard().LoadDisplayIqamahScreen()
            vc.masjidIDReceived = self.masajidList[index].googleMasjidID ?? ""
            vc.masjidName = self.masajidList[index].masjidName ?? ""
            vc.address = self.addressLBL.text ?? "-"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let color = #colorLiteral(red: 0.05882352941, green: 0.4509803922, blue: 0.8274509804, alpha: 1)        
        alert.showCustom("\(item.name)", subTitle: "", color: color, icon: #imageLiteral(resourceName: "logo"))

    }
}

extension IqamahVC{
    
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
                        self.networkHitAddMasjid(location: locationToSend, item: item)
                    }
                }
            }else {
                print(error as Any)
                self.networkHitAddMasjid(location: "", item: item)
            }
        }
    }
    
    
    func networkHitAddMasjid(location: String, item: MasjidItem){
        
        self.view.isUserInteractionEnabled = false

//        let headers = ["Authorization": "Bearer \(myToken)"]
        let parameters = ["google_masajid_id": "\(item.id)",
                            "name": "\(item.name)",
                            "lat": "\(item.location.coordinate.latitude)",
                            "long": "\(item.location.coordinate.longitude)",
                            "address": "\(location)"
        ]
        APIRequestUtil.AddMasjid(parameters: parameters,headers: httpHeaders, completion: APIRequestAddMasjidCompleted)
    }
    
    fileprivate func APIRequestAddMasjidCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "message"{
                let message = json["message"].stringValue
                HUD.flash(.labeledSuccess(title: "Message", subtitle: message))
            }
            HUD.hide()
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
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
}
