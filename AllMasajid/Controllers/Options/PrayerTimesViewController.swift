//
//  ViewController.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 9/14/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import CoreLocation
import PKHUD
//import Adhan
import Alamofire
import SCLAlertView
import SafariServices
import SwiftyJSON

class PrayerTimesViewController: UIViewController { //, ReloadDelegate
    
    var todaysDate = ""
    
    var alarmInfo : [String: Bool] = [:]
    var arrayOfKeys : [Prayer] =  []
    var prayerTimes : [Prayer:String] = [:]
    
    let adjustments : [HighLatitudeRule?] = [nil,.middleOfTheNight,.seventhOfTheNight,.twilightAngle]

    let formatter = DateFormatter()
    
    var nextPrayerKey : Prayer = Prayer.isha
    var nextPrayer : Prayer? = nil
    var currentPrayer : Prayer? = nil
    
    var myLocation = CLLocation()
    var timer = Timer()
    
//    var observation: NSKeyValueObservation?
    @objc var objectToObserve: LocationManager!

    @IBOutlet var footerView: UIView!
    @IBOutlet weak var lblZawaalTime: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var prayerTimeTblView: UITableView!
    @IBOutlet weak var imgTimeRemaining: UIImageView!
    @IBOutlet weak var lblPrayerTimeRemaining: UILabel!
    @IBOutlet weak var lblNextPrayerName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    
    @IBOutlet weak var popUpBlackView: UIView!
    @IBOutlet weak var popUpMenuView: UIView!
    @IBOutlet weak var menuSettingBtn: UIButton!
    
    @IBOutlet weak var menuLocationLBL: UILabel!
    @IBOutlet weak var menuLocationTypeLBL: UILabel!
    @IBOutlet weak var menuPrayerMethodLBL: UILabel!
    @IBOutlet weak var menuSchoolLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTodayDate()
        /*
        if UserDefaults.standard.bool(forKey: "introPrayerTimes") != true {
            UserDefaults.standard.set(true, forKey: "introPrayerTimes")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Prayer Times"
            vc.screenName = "prayer_timing"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alarmInfo = [:]
        arrayOfKeys.removeAll()
        if changedSetting == true{
            configureWFD()
        }
        setupInitials()
        fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func handlePopUpBlackViewTap(_ sender: UITapGestureRecognizer? = nil) {
        popUpBlackView.isHidden = true
        popUpMenuView.isHidden = true
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotBtnPressed(_ sender: UIButton) {
        
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item4"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func menuSettingsBtnPressed(_ sender: UIButton) {
        popUpMenuView.isHidden = true
        popUpBlackView.isHidden = true
        let vc = UIStoryboard().LoadSettingScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func popUpBtnPressed(_ sender: UIButton) {
        popUpMenuView.isHidden = false
        popUpBlackView.isHidden = false
    }
    
}

extension PrayerTimesViewController: ThreeDotProtocol {
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "prayer_timing"
        vc.titleStr = "Prayer Times"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
//        refreshDataFunc()
        
//        if changedSetting == true{
//            configureWFD()
//        }
        configureWFD()
        setupInitials()
        fetchData()
        
    }
    
    func shareBtnPressed() {
        sharePrayersData()
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

extension PrayerTimesViewController{
    
    func setupInitials(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)

        //setting date
        let str = UserDefaults.standard.object(forKey: "currentDate")
        self.lblDate.text = "\(str ?? "")"

        //setting day of week
        let calender = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.calendar = calender
        formatter.dateFormat = "EEEE"
        lblDay.text = formatter.string(from: Date())

        if let info = defaults.dictionary(forKey: "alarmInfo") {
            alarmInfo = info as! [String : Bool]
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        
        let popUpBlackViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePopUpBlackViewTap(_:)))
        popUpBlackView.addGestureRecognizer(popUpBlackViewTap)
        
        popUpBlackView.isHidden = true
        popUpMenuView.isHidden = true
        
        let school = defaults.integer(forKey: "School/Juristic")
        
        if school == 0{
            menuSchoolLBL.text = "Hanafi"
        }else if school == 1{
            menuSchoolLBL.text = "Shafi"
        }
        
        do {
            if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                  let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                menuLocationLBL.text = SelectedPlace.name
            }
        } catch { print(error) }
        
//        if let data2 = UserDefaults.standard.data(forKey: "savedLocation"),
//              let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data2) as? SavedLocation {
//            menuLocationLBL.text = SelectedPlace.name
//        }
        
        let location = defaults.integer(forKey: "Location")
        if location == 0{
            menuLocationTypeLBL.text = "GPS"
        }else if location == 1{
            menuLocationTypeLBL.text = "Manual Search"
        }else if location == 2{
            menuLocationTypeLBL.text = "Saved Location"
        }
        
        let prayerCalc = defaults.integer(forKey: "Prayers Calculation Method")
        
        if prayerCalc == 0{
            let methodIndex = defaults.integer(forKey: "Method")
            for i in 0..<calculationStrings.count{
                if i == methodIndex{
                    menuPrayerMethodLBL.text = calculationStrings[i]
                    break
                }
            }
        }else if prayerCalc == 1{
            let fajrAngle = defaults.string(forKey: "FajrAngle")!
            let ishaAngle = defaults.string(forKey: "IshaAngle")!
            menuPrayerMethodLBL.text = "Fajr Angle: \(fajrAngle), Isha Angle: \(ishaAngle)"
        }
        
        popUpMenuView.cornerRadius = 20
        menuSettingBtn.cornerRadius = 20
    }
    
    
    func configureWFD(){
        var dateAdjustment = ""
        if UserDefaults.standard.bool(forKey: "dateAdjustmentStatus") == true{
            dateAdjustment = UserDefaults.standard.object(forKey: "dateAdjustment") as! String
        }else{
            dateAdjustment = "0"
        }
        
        networkHit(dateAdjustment: dateAdjustment)
    }
    
    func getTodayDate(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        let now = Date()
        todaysDate = formatter.string(from:now)
    }
    
//    func refreshDataFunc(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            HUD.show(.labeledProgress(title: "Loading Data", subtitle: "Please Wait ..."))
//        }
//
//        let vc = UIStoryboard().LoadLoadingScreen()
//        vc.reloadDelegate = self
//        vc.modalPresentationStyle = .overFullScreen
//        self.parent?.present(vc, animated: false, completion: nil)
//    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            
            myLocation = LocationManager.shared.myLocation!
            getNamazTimings()
            getCity()
        }
    }
    
    func sharePrayersData(){
        
        var text2Share = "****** allMasajid - PRAYER TIMES ******\n\n"
        
        for key in arrayOfKeys {
            let item = prayerTimes[key]
            let prayerName = String(describing: key).uppercased()
            text2Share = text2Share + "- \(prayerName): \(item!)\n"
        }
        
        text2Share = text2Share + "\n\nAre you the one who is struggling to chase prayer timings? Don’t worry about it further. allMasajid app will always keep you updated about Salah’s schedule at one click./nFor Android: https://bit.ly/2zCeFwM/nFor IOS: https://apple.co/2zHQXzo/nDownload our app, so you never miss any prayers in the future."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activity.popoverPresentationController?.sourceView = self.lblDay//self.view
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
        
    }
}

extension PrayerTimesViewController {
        
    /*
    func dataFetched(_ succes: Bool) {
        
        self.reloadScreenData()
    }
    
    func reloadScreenData(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
        
        let str = UserDefaults.standard.object(forKey: "currentDate")
        self.lblDate.text = "\(str ?? "")"//DateManager.shared.getEnglishDate() + "/" + DateManager.shared.getIslamicDate()
        
        self.fetchData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            HUD.hide()
        }
    }
    */
        
    func fetchData(){
        
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNamazTimings()
                    self.getCity()
                }
            } catch { print(error) }
            
            
//            if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
//                let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
//                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
//                self.getNamazTimings()
//                self.getCity()
//            }
        }else if defaults.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNamazTimings()
                    self.getCity()
                }
            } catch { print(error) }
            
//            if let data = UserDefaults.standard.data(forKey: "savedLocation"),
//                let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
//                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
//                self.getNamazTimings()
//                self.getCity()
//            }
        }else{
            
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                self.getNamazTimings()
                self.getCity()
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
        }
    }
}

extension PrayerTimesViewController{
    
     func observeLocation(object: LocationManager) {
         objectToObserve = object
         if (objectToObserve.myLocation == nil){
             showLocationAlert()
         }else{
            
            let myLong = String(self.myLocation.coordinate.longitude)
            let myLat = String(self.myLocation.coordinate.latitude)
            UserDefaults.standard.set(myLong, forKey: "longGPS")
            UserDefaults.standard.set(myLat, forKey: "latGPS")
            
            self.getNamazTimings()
            self.getCity()
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
        GetCityFromCordinates.sharedGetCity.getAddressFromLatLon(pdblLatitude: latt, withLongitude: lonn, lbl: lblCity)
     }
     
     func getNamazTimings(){

        self.prayerTimes.removeAll()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())

        let coordinates = Coordinates(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)

        var params = calculationMethods[defaults.integer(forKey: "Method")].params

        if defaults.integer(forKey: "Prayers Calculation Method") == 1 {
         
            params = CalculationParameters(fajrAngle: Double(defaults.string(forKey: "FajrAngle")!)!, ishaAngle: Double(defaults.string(forKey: "IshaAngle")!)!)
        }

        params.madhab = madhabs[defaults.integer(forKey: "School/Juristic")]

        let selectedPrayers = defaults.array(forKey: "Nawafils") as! [Bool]

        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {

            formatter.timeStyle = .medium
            if (defaults.integer(forKey: "Time Format")) == 0 {
                formatter.dateFormat = "yyyy-MM-dd hh:mm a"
            }else{
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }

            formatter.timeZone = TimeZone.current


            prayerTimes[Prayer.fajr] = formatter.string(from: prayers.fajr)
            arrayOfKeys.append(Prayer.fajr)
            prayerTimes[Prayer.sunrise] = formatter.string(from: prayers.sunrise)
            arrayOfKeys.append(Prayer.sunrise)

            if selectedPrayers[1]{
                prayerTimes[Prayer.ishraaq] = formatter.string(from: prayers.time(for: Prayer.ishraaq) ?? Date())
                arrayOfKeys.append(Prayer.ishraaq)
            }

            if selectedPrayers[2]{
                prayerTimes[Prayer.chaasht] = formatter.string(from: prayers.time(for: Prayer.chaasht) ?? Date())
                arrayOfKeys.append(Prayer.chaasht)
            }
            prayerTimes[Prayer.dhuhr] = formatter.string(from: prayers.dhuhr.addingTimeInterval(TimeInterval(6*60)))
            arrayOfKeys.append(Prayer.dhuhr)
            prayerTimes[Prayer.asr] = formatter.string(from: prayers.asr)
            arrayOfKeys.append(Prayer.asr)
            prayerTimes[Prayer.maghrib] = formatter.string(from: prayers.maghrib)
            arrayOfKeys.append(Prayer.maghrib)

            if selectedPrayers[3]{
                prayerTimes[Prayer.awabeen] = formatter.string(from: prayers.time(for: Prayer.awabeen) ?? Date())
                arrayOfKeys.append(Prayer.awabeen)
            }

            prayerTimes[Prayer.isha] = formatter.string(from: prayers.isha)
            arrayOfKeys.append(Prayer.isha)
            
            if selectedPrayers[4]{
                prayerTimes[Prayer.tahajjud] = formatter.string(from: prayers.time(for: Prayer.tahajjud) ?? Date())
                arrayOfKeys.append(Prayer.tahajjud)
            }

            nextPrayer = prayers.nextPrayer()
            currentPrayer = prayers.currentPrayer()

            if nextPrayer == Prayer.dhuhr {
                let dateFormatter = DateFormatter()

                if (defaults.integer(forKey: "Time Format")) == 0 {
                    dateFormatter.dateFormat = "hh:mm a"
                } else{
                    dateFormatter.dateFormat = "HH:mm"
                }
                dateFormatter.timeZone = TimeZone.current

                if prayers.dhuhr > Date() {
                    lblZawaalTime.text = "ZAWAAL TIME/SOLAR NOON: " + dateFormatter.string(from: prayers.dhuhr)
                    lblZawaalTime.isHidden = false
                }else {
                    lblZawaalTime.isHidden = true
                }
            }

            prayerTimeTblView.reloadData()

            if nextPrayer == Prayer.none || nextPrayer == nil{
                nextPrayer = Prayer.fajr
            }

            lblNextPrayerName.text = String(describing: nextPrayer!).uppercased()

            if currentPrayer == Prayer.none || currentPrayer == nil {
                currentPrayer = Prayer.fajr
            }
            changeText()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(changeText)), userInfo: nil, repeats: true)
         }
     }
}

extension PrayerTimesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayerTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrayerCell", for: indexPath) as! PrayerTimesTableViewCell
        
        let item = prayerTimes[arrayOfKeys[indexPath.row]]
        let thisPrayer = arrayOfKeys[indexPath.row]
        
        let prayerName = String(describing: arrayOfKeys[indexPath.row]).uppercased()
        
        var displayPrayerName = prayerName.capitalized
        displayPrayerName = displayPrayerName == "Maghrib" ? "Magrib": displayPrayerName
        displayPrayerName = displayPrayerName == "Isha" ? "Isha'a": displayPrayerName
        displayPrayerName = displayPrayerName == "Ishraaq" ? "Ishraq": displayPrayerName
        cell.lblPrayerName.text = displayPrayerName
        
        if thisPrayer == Prayer.awabeen || thisPrayer == Prayer.chaasht || thisPrayer == Prayer.ishraaq || thisPrayer == Prayer.tahajjud{
            cell.containerView.backgroundColor = UIColor(red:0.04, green:0.20, blue:0.38, alpha:1.0)
            cell.imgPrayerIcon.image = UIImage(named: prayerName + "-icon")
        }
        else {
            if(thisPrayer == currentPrayer){
                cell.containerView.backgroundColor = #colorLiteral(red: 0.3821990609, green: 0.6493599518, blue: 0.9635548858, alpha: 1)
                cell.imgPrayerIcon.image = UIImage(named: prayerName + "-icon-selected")
                cell.lblPrayerTime.textColor = UIColor.black
                cell.lblPrayerName.textColor = UIColor.black
                
            }else{
                cell.imgPrayerIcon.image = UIImage(named: prayerName + "-icon")
                cell.containerView.backgroundColor = UIColor(red:0.051, green:0.455, blue:0.827, alpha:1.0)
                cell.lblPrayerTime.textColor = UIColor.white
                cell.lblPrayerName.textColor = UIColor.white
            }
        }
        
        let values = item
        if let components = values?.components(separatedBy: " "), components.count > 1 {
            if defaults.integer(forKey: "Time Format") == 0 {
                cell.lblPrayerTime.text = components[1] // safe
            }
        }
        
        let key  = String(describing: arrayOfKeys[indexPath.row]).uppercased()
        
        if alarmInfo.keys.contains(key){
            if alarmInfo[key] == true {
                cell.btnSwitchAlarm.setImage(UIImage(named: "alarm-icon"), for: .normal)
            }else{
                cell.btnSwitchAlarm.setImage(UIImage(named: "alarm-not-icon"), for: .normal)
            }
        }else{
            cell.btnSwitchAlarm.setImage(UIImage(named: "alarm-not-icon"), for: .normal)
        }
        
        cell.btnSwitchAlarm.tag = indexPath.row
        cell.btnSwitchAlarm.addTarget(self, action: #selector(selectPrayer(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func selectPrayer(sender: UIButton) {
        let index = sender.tag
        
        // Make sure index is valid
        guard index < arrayOfKeys.count else { return }
        
        let key = String(describing: arrayOfKeys[index]).uppercased()
        
        let currentAlarmState = alarmInfo[key] ?? false
        alarmInfo[key] = !currentAlarmState
        if currentAlarmState {
            removeNotification(identifier: key)
        } else {
            alarmInfo["Stop"] = false
            if let time = prayerTimes[arrayOfKeys[index]] {
                setNotification(identifier: key, time: time)
            }
        }
        
        defaults.set(alarmInfo, forKey: "alarmInfo")
        prayerTimeTblView.reloadData()
    }

    @objc func changeText() {
        guard let nextPrayer = nextPrayer,
              let currentPrayer = currentPrayer,
              let nextTimeString = prayerTimes[nextPrayer],
              let currentTimeString = prayerTimes[currentPrayer] else { return }
        
        guard let namazDate = formatter.date(from: nextTimeString),
              let currentNamazDate = formatter.date(from: currentTimeString) else { return }
        
        var interval = namazDate.timeIntervalSince(Date())
        var totalInterval = namazDate.timeIntervalSince(currentNamazDate)
        
        var adjustedNamazDate = namazDate
        if interval < 0.0 {
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: namazDate) {
                adjustedNamazDate = nextDay
                interval = adjustedNamazDate.timeIntervalSince(Date())
                totalInterval = adjustedNamazDate.timeIntervalSince(currentNamazDate)
            }
        }
        
        if totalInterval == 0 {
            if let ishaDate = formatter.date(from: prayerTimes[.isha] ?? "") {
                totalInterval = adjustedNamazDate.timeIntervalSince(ishaDate)
            } else {
                totalInterval = 1 // fallback to prevent division by zero
            }
        }
        
        let dec = (interval / totalInterval) * 10
        switch dec {
        case 0..<1.5: imgTimeRemaining.image = UIImage(named: "time-remain10")
        case 1.5..<2.5: imgTimeRemaining.image = UIImage(named: "time-remain9")
        case 2.5..<3.5: imgTimeRemaining.image = UIImage(named: "time-remain8")
        case 3.5..<4.5: imgTimeRemaining.image = UIImage(named: "time-remain7")
        case 4.5..<5.5: imgTimeRemaining.image = UIImage(named: "time-remain6")
        case 5.5..<6.5: imgTimeRemaining.image = UIImage(named: "time-remain5")
        case 6.5..<7.5: imgTimeRemaining.image = UIImage(named: "time-remain4")
        case 7.5..<8.5: imgTimeRemaining.image = UIImage(named: "time-remain3")
        case 8.5..<9.5: imgTimeRemaining.image = UIImage(named: "time-remain2")
        case 9.5..<10.5: imgTimeRemaining.image = UIImage(named: "time-remain1")
        default: imgTimeRemaining.image = UIImage(named: "time-remain0")
        }
        
        lblPrayerTimeRemaining.attributedText = NSAttributedString(
            string: stringFromTimeInterval(interval: interval),
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]
        )
        
        if interval <= 0 {
            imgTimeRemaining.image = UIImage(named: "time-remain0")
            timer.invalidate()
            getNamazTimings()
        }
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let totalSeconds = max(Int(interval), 0)
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

extension PrayerTimesViewController: TryAgainProtocol {
    
    func tryAgain() {
        refreshBtnPressed()
    }
    
    func networkHit(dateAdjustment: String){
        DispatchQueue.main.async{
            HUD.flash(.progress)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MM"
        
        let now = Date()
        let dm = "\(formatter.string(from:now))\(formatter2.string(from:now))"
        let da = Int(dateAdjustment) ?? 0
        APIRequestUtil.GetWhiteFastingDays(dateAdjustment: da, dateMonth: dm, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
//
//            let today = json["today"]
//            let hijri = today["hijri"]
//
//            let islamicDate = hijri["date"].stringValue
//            let dataIslamic = islamicDate.components(separatedBy: "-")
//
//            let islamicMonthName = hijri["month_name"].stringValue
//            let islamicYear = hijri["year"].stringValue
//
//            let currentDate = "\(todaysDate)/\(dataIslamic[0]) \(islamicMonthName) \(islamicYear)"
//
//            lblDate.text = currentDate
//
//            UserDefaults.standard.set(currentDate, forKey: "currentDate")
//            
            
            let data = json["data"]
            
            let currentIslamicDate = data["current_islamic_date"].stringValue
            let islDateArr = currentIslamicDate.components(separatedBy: "-")
            
            if islDateArr.count == 3 {
                let currentIslamicDay = Int(islDateArr[2]) ?? 0
                let currentIslamicMonth = Int(islDateArr[1]) ?? 0
                let currentIslamicYear = islDateArr[0]
                
                let currentDate = "\(todaysDate)/\(currentIslamicDay) \(IslamicMonths[currentIslamicMonth - 1]) \(currentIslamicYear)"
                lblDate.text = currentDate
                UserDefaults.standard.set(currentDate, forKey: "currentDate")
            }
            
            HUD.hide()
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
