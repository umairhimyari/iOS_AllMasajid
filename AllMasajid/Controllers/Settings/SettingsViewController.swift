//
//  SettingsViewController.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 10/24/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
//import Adhan
import DropDown
import CoreLocation
import UserNotifications
import GooglePlaces
import PKHUD

class SettingsViewController: UIViewController, ThreeDotProtocol {

    let formatter = DateFormatter()
    let headerheight:CGFloat = 60.0
    
    var hidden : [Bool] = []

    var arrayOfKeys : [Prayer] =  []
    var nextPrayerKey : Prayer = Prayer.isha
    var prayerTimes : [Prayer:String] = [:]
    
    var alarmInfo : [String: Bool] = [:]
    
    let metrics : [String] = ["Miles","KM"]
    let timeFormatStrings : [String] = ["12 hours (Example: 01:00 pm)","24 hours (Example: 13:00)"]
 
    let menuData : [[String:[String]]] = [["Location":["GPS/Cell Towers","Manual Search","Saved Locations"]],["Prayers Calculation Method":["Select from predefined calculations","Customized degree calculation"]],["School/Juristic":["Hanafi","Shafi"]],["Nawafils/Non-Obligatory Prayers":["All","Ishraq","Chaasht","Awabeen","Tahajjud"]],["Hijri Date":["Local Moon Sighting","Device Date Adjustment"]],["Prayer Notifications":["Stop All", "Start All", "Fajr","Sunrise","Dhuhr","Asr","Magrib","Isha"]], ["Smart Notifications":[]], ["Additional Settings":["Time Format","Distance Range","Distance Unit"]]]
    
    let imageIconNames : [String] = ["locations","prayers-calculation","schools","nawafils","hijri-date","notifications","notifications","additional-setting"]
    
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var versionLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var versionNumber = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber = "\(version)"
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionNumber = "\(versionNumber) (\(build))"
        }
        
        if APIRequestUtil.BASE_URL.contains("org"){
            versionNumber = "\(versionNumber) - org"
        }else if APIRequestUtil.BASE_URL.contains("laval"){
            versionNumber = "\(versionNumber) - laval"
        }else if APIRequestUtil.BASE_URL.contains(".co/"){
            versionNumber = "\(versionNumber) - .co"
        }else{
            versionNumber = "\(versionNumber)"
        }
        versionLBL.text = versionNumber

        if let info = defaults.dictionary(forKey: "alarmInfo") {
            alarmInfo = info as! [String : Bool]
            
        }
        
        if let myLocation = LocationManager.shared.myLocation {
            getNamazTimings(myLocation: myLocation)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("ReloadTable"), object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ReloadTable"), object: nil)
    }
    
    @objc func didReceiveNotification(){
        tblView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBack(_ sender: Any) {
        settingsVisit = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item7"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "settings"
        vc.titleStr = "Settings"
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
        print("Do nothing")
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
        let vc = UIStoryboard().LoadWebViewScreen()
        vc.screenReceived = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func uncheck(section : Int, row: Int){
       
        if let cell = tblView.cellForRow(at: IndexPath(row: row, section: section)) as? SettingsChildTableViewCell {
            cell.btnCheckbox.isSelected = false
        }
    }
    
    func uncheckAllNamaz(section : Int) {
        let key = menuData[section].keys.first
        let rows = menuData[section][key!]
        var i = 0
        for _ in rows! {
            if ![0,7].contains(i) {
                if let cell = tblView.cellForRow(at: IndexPath(row: i, section: section)) as? SettingsChildTableViewCell {
                    cell.btnCheckbox.isSelected = false
                    i+=1
                }
            }
            else {
                i+=1
            }
        }
    }
    
    func uncheckRows(section : Int){
        
        let key = menuData[section].keys.first
        let rows = menuData[section][key!]
        var i = 0
        for _ in rows! {
            
            if let cell = tblView.cellForRow(at: IndexPath(row: i, section: section)) as? SettingsChildTableViewCell {
                cell.btnCheckbox.isSelected = false
                i+=1
            }
        }
    }
  
    
    func didSelectDropDownItem(sectionIndex: Int, rowIndex: Int, index: Int) {
        
        if sectionIndex == 0 && rowIndex == 2 {
            defaults.set(2, forKey: "Location")
            defaults.set(index, forKey: "SelectedSavedLocation")
        }
        if sectionIndex == 1 && rowIndex == 0 {
            defaults.set(index, forKey: "Method")
          
        }
        if sectionIndex == 4 && rowIndex == 1 {

            UserDefaults.standard.set("\(dateAdjustments[index])", forKey: "dateAdjustment")
            changedSetting = true
            
            if index == 2{
                defaults.set(false, forKey: "dateAdjustmentStatus")
            }else{
                defaults.set(true, forKey: "dateAdjustmentStatus")
            }
        }
        
        
        if sectionIndex == 7 { // 6
            switch rowIndex {
                
            case 0:
                  defaults.set(index, forKey: "Time Format")
          
            case 1:
                  defaults.set(index, forKey: "Distance")
            
            case 2:
                  defaults.set(index, forKey: "Unit")
               
            default:
                break
            }
        }
        tblView.reloadData()
    }
   
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        
        let section = sender.view!.tag
        
        if section == 6 {
            if UserDefaults.standard.bool(forKey: "isLoggedIn") == false {
                HUD.flash(.label("Please login to set smart notifications"))
                return
            }
            let vc = UIStoryboard().LoadSmartNotificationsScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let key = menuData[section].keys.first
            let sub = menuData[section][key!]
            
            let indexPaths = (0..<(sub?.count ?? 0)).map { i in return IndexPath(item: i, section: section)  }
            
            hidden[section] = !hidden[section]
            let headerView = sender.view!.subviews.first as! SettingsTableViewCell
            
            tblView?.beginUpdates()
            
            if hidden[section] {
                headerView.btnArrow.isSelected = false
                
                tblView?.deleteRows(at: indexPaths, with: .fade)
            } else {
              headerView.btnArrow.isSelected = true
                
                tblView?.insertRows(at: indexPaths, with: .fade)
                
            }
            tblView.reloadData()
            tblView?.endUpdates()
            
            if !hidden[section]{
                tblView.scrollToRow(at: indexPaths.last!, at: .none, animated: true)
            }
        }
    }
    
    func getNamazTimings(myLocation : CLLocation){
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
       
        let coordinates = Coordinates(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
        
        var params = calculationMethods[defaults.integer(forKey: "Method")].params
        params.madhab = madhabs[defaults.integer(forKey: "School/Juristic")]
        
        
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            
            formatter.timeStyle = .medium
            if (defaults.integer(forKey: "Time Format")) == 0 {
                formatter.dateFormat = "yyyy-MM-dd hh:mm a"
            }else{
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            
            formatter.timeZone = TimeZone.current
            
            prayerTimes[Prayer.fajr] = formatter.string(from: prayers.fajr)
            prayerTimes[Prayer.sunrise] = formatter.string(from: prayers.sunrise)
            prayerTimes[Prayer.dhuhr] = formatter.string(from: prayers.dhuhr.addingTimeInterval(TimeInterval(6*60)))
            prayerTimes[Prayer.asr] = formatter.string(from: prayers.asr)
            prayerTimes[Prayer.maghrib] = formatter.string(from: prayers.maghrib)
            prayerTimes[Prayer.isha] = formatter.string(from: prayers.isha)
         
            arrayOfKeys = [Prayer.fajr,Prayer.sunrise,Prayer.dhuhr,Prayer.asr,Prayer.maghrib,Prayer.isha]
        }
    }
    
    @objc func selectPrayer(sender : UIButton){
        sender.isSelected = !sender.isSelected
        
        let identifier = String(describing: arrayOfKeys[sender.tag]).uppercased()
        
        if sender.isSelected {
            alarmInfo[identifier] = true
            defaults.set(alarmInfo, forKey: "alarmInfo")
            let time = prayerTimes[arrayOfKeys[sender.tag]]
            setNotification(identifier: identifier, time: time!)
        }else{
            
            alarmInfo[identifier] = false
            defaults.set(alarmInfo, forKey: "alarmInfo")
            removeNotification(identifier: identifier)
        }
    }
    
    func autocompleteClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:  UInt64(UInt(GMSPlaceField.all.rawValue)))
        autocompleteController.placeFields = fields
        
        
        autocompleteController.tableCellBackgroundColor = UIColor(red:0.03, green:0.27, blue:0.45, alpha:1.0)
        autocompleteController.navigationController?.navigationBar.barTintColor =  UIColor(red:0.03, green:0.27, blue:0.45, alpha:1.0)
    
        autocompleteController.primaryTextColor = .lightText
        autocompleteController.secondaryTextColor = .lightText
        autocompleteController.primaryTextHighlightColor = .white
        
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource, SettingsTableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        if hidden[section]{
            return 0
        }else{
            let key = menuData[section].keys.first
            return menuData[section][key!]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        let key = menuData[section].keys.first
        cell.lblTitle.text = key
        cell.imgIcon.image =  UIImage(named: imageIconNames[section])
        cell.btnArrow.setImage(UIImage(named: "down-arrow"), for: .normal)
        cell.btnArrow.setImage(UIImage(named: "up-arrow"), for: .selected)
     
        if !hidden[section]{
            cell.btnArrow.isSelected = true
        }
        
        cell.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: headerheight)
        let view = UIView()
        view.addSubview(cell)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        view.tag = section
        
        switch section {
            
        case 0,2,4:
            
            let selectedIndex = defaults.integer(forKey: key!)
            let title = menuData[section][key!]![selectedIndex]
            
            if section == 0 && selectedIndex == 1 {
                
                // [ADDED] 22 January, 2021
                do {
                    if let data2 = defaults.data(forKey: "SelectedPlace"),
                          let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data2) as? SavedLocation {
                        cell.lblItem.text = title + " - " + SelectedPlace.name
                    }
                } catch { print(error) }
                
                /* [REMOVED] 22 January, 2021
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                    let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
                    cell.lblItem.text = title + " - " + SelectedPlace.name
                }
                */
                
            }else if section == 4 && selectedIndex == 1{
                if UserDefaults.standard.bool(forKey: "dateAdjustmentStatus") == true {
                    let dateSrt = UserDefaults.standard.object(forKey: "dateAdjustment") as! String
                    cell.lblItem.text = title + " (\(dateSrt)) "
                }else{
                    cell.lblItem.text = title
                }
            }else{
                 cell.lblItem.text = title
            }
            
        case 1:
            let selectedIndex = defaults.integer(forKey: key!)
            if selectedIndex == 0 {
                let methodIndex = defaults.integer(forKey: "Method")
              
                cell.lblItem.text = calculationStrings[methodIndex]
            }
            else{
                let fajrAngle = defaults.string(forKey: "FajrAngle")!
                let ishaAngle = defaults.string(forKey: "IshaAngle")!
                cell.lblItem.text = "Custom - Fajr Angle: " + fajrAngle + ", Isha'a Angle: " + ishaAngle
            }
         
        case 3:
            let selected = defaults.array(forKey: "Nawafils") as! [Bool]
            
            if selected.count == 0 {
                cell.lblItem.text = "None"
            }
            else{
                var count = 0
                for item in selected[1...4] {
                    if item {
                        count+=1
                    }
                }
                cell.lblItem.text = "\(count) Selected"
            }
            
        case 5:
            if let info = defaults.dictionary(forKey: "alarmInfo") as? [String : Bool]{
                let  alarmInfo = info
                if alarmInfo["Stop"]! {
                    cell.lblItem.text = "Stop All"
                }
                else{
                    cell.lblItem.text = "Custom"
                }
            }
        case 6:
            cell.lblItem.text = "You can manage all your notifications here"
            
        case 7: //6
            let timeFormatIndex = defaults.integer(forKey: "Time Format")
            let distanceIndex = defaults.integer(forKey: "Distance")
            let unitIndex = defaults.integer(forKey: "Unit")
          
            cell.lblItem.text = "\(timeFormatStrings[timeFormatIndex]), \(nearbyRange[distanceIndex]), \(metrics[unitIndex])"
        default:
            break
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsChildTableViewCell", for: indexPath) as! SettingsChildTableViewCell
        let key = menuData[indexPath.section].keys.first
        let displayTitle = menuData[indexPath.section][key!]?[indexPath.row]
        
        let title = displayTitle=="Isha" ? "Isha'a" : displayTitle
        
        cell.delegate = self

        if indexPath.section >= 0 && indexPath.section <= 2 || indexPath.section == 4 {
            cell.btnCheckbox.setImage(UIImage(named: "radioChecked"), for: .selected)
            cell.btnCheckbox.setImage(UIImage(named: "radioUnchecked"), for: .normal)
        }else{
            cell.btnCheckbox.setImage(UIImage(named: "checked"), for: .selected)
            cell.btnCheckbox.setImage(UIImage(named: "unchecked"), for: .normal)
        }
        
        if indexPath.section == 7 { //6
            
            cell.btnCheckbox.isHidden = true
        }else{
            cell.btnCheckbox.isHidden = false
        }
        cell.btnCheckbox.isUserInteractionEnabled = false
        
        switch indexPath.section {
      
        case 0,1,2,4:
            let selectedIndex = defaults.integer(forKey: key!)
          
                if indexPath.row == selectedIndex {
                    cell.btnCheckbox.isSelected = true
                }
                else{
                    cell.btnCheckbox.isSelected = false
                }
           
            if indexPath.section == 1 && indexPath.row == 0 {
                let methodIndex = defaults.integer(forKey: "Method")
                cell.configDropDown(items: calculationStrings, sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: methodIndex)
            }
            
            
            if indexPath.section == 4 && indexPath.row == 1 {
                var adjustmentIndex = 2//defaults.integer(forKey: "Date Adjustment")
                var dateAdjustment = "0"
                if UserDefaults.standard.bool(forKey: "dateAdjustmentStatus") != true{
                    dateAdjustment = "0"
                }else{
                    dateAdjustment = UserDefaults.standard.object(forKey: "dateAdjustment") as! String
                }
                
                for i in 0..<dateAdjustments.count{
                    if dateAdjustment == dateAdjustments[i]{
                        adjustmentIndex = Int(i)
                        break
                    }
                }
                cell.configDropDown(items: dateAdjustments, sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: adjustmentIndex)
            }
            
            if indexPath.section == 0 && indexPath.row == 2 {
                
                //[ADDED] 22 January, 2021
                do {
                    if let data2 = defaults.data(forKey: "savedLocation"),
                          let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data2) as? SavedLocation {
                        print(SelectedPlace.name)
                        cell.configDropDown(items: [SelectedPlace.name], sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: 0)
                    }
                } catch { print(error) }
                
                /* [REMOVED] 22 January, 2021
                if let decoded  = defaults.data(forKey: "savedLocation") {
                    let decodedLocation = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! SavedLocation
                    
                    cell.configDropDown(items: [decodedLocation.name], sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: 0)
                }
                */
            }
     
        case 3:
            let selected = defaults.array(forKey: "Nawafils") as! [Bool]
            
             if selected[indexPath.row]{
                cell.btnCheckbox.isSelected = true
             }
             else{
                cell.btnCheckbox.isSelected = false
            }
            
        case 5:
            if let info = defaults.dictionary(forKey: "alarmInfo") as? [String : Bool]{
                let  alarmInfo = info
                if indexPath.row == 0 {
                    if alarmInfo["Stop"]! {
                        cell.btnCheckbox.isSelected = true
                    }
                    else{
                        cell.btnCheckbox.isSelected = false
                    }
                }else if indexPath.row == 1 {
                    if UserDefaults.standard.bool(forKey: "StartAllNotifications") == true{
                        cell.btnCheckbox.isSelected = true
                    }else{
                        cell.btnCheckbox.isSelected = false
                    }
                }
                else {
            
                    var rowItem = menuData[indexPath.section][key!]?[indexPath.row].uppercased() ?? ""
                    print(alarmInfo)
                    if (rowItem == "MAGRIB"){
                       rowItem = "MAGHRIB"
                    }
                    print(rowItem)
                    if alarmInfo[rowItem]!{
                        cell.btnCheckbox.isSelected = true
                    }else{
                        cell.btnCheckbox.isSelected = false
                    }
                }
            }
            
//        case 6:
            
            
        case 7: //6
            
            switch indexPath.row {
            case 0:
                let timeFormatIndex = defaults.integer(forKey: "Time Format")
                cell.configDropDown(items: timeFormatStrings, sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: timeFormatIndex)
            case 1:
                let distanceIndex = defaults.integer(forKey: "Distance")
                cell.configDropDown(items: nearbyRange, sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: distanceIndex)
            case 2:
                let unitIndex = defaults.integer(forKey: "Unit")
                cell.configDropDown(items: metrics, sectionIndex: indexPath.section, rowIndex: indexPath.row,selectedIndex: unitIndex)
            default:
                break
            }
            
        default:
            break
        }
        
        cell.lblTitle.text = title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerheight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hidden.count != menuData.count {
            for _ in menuData{
                hidden.append(true)
            }
        }
        
        return menuData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let currentCell = tableView.cellForRow(at: indexPath) as? SettingsChildTableViewCell {
            
            let key = menuData[indexPath.section].keys.first
        
            switch indexPath.section {
                
            case 0,1,2,4:
                
               if (indexPath.section == 0 && indexPath.row == 0){
                    /// GPS Location
                    LocationManager.shared.requestLocation()
                    defaults.set(0, forKey: key!)
                }else if (indexPath.section == 0 && indexPath.row == 1) {
                    /// Manual Location Search
                    autocompleteClicked()
                }else if (indexPath.section == 1 && indexPath.row == 1) {
                    let vc = UIStoryboard().LoadDegreeAlertScreen()
                    self.present(vc, animated: true, completion: nil)
                
                }else if !(indexPath.section == 0 && indexPath.row == 2){
                    defaults.set(indexPath.row, forKey: key!)
                }
                if indexPath.section == 4 && indexPath.row == 0 {
                    defaults.set(false, forKey: "dateAdjustmentStatus")
                }
            
                if (indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 0 && indexPath.row == 2)  || (indexPath.section == 4 && indexPath.row == 1) {
                    if currentCell.dropdown.isHidden {
                        currentCell.dropdown.show()
                    }else{
                        currentCell.dropdown.hide()
                    }
                }
                
            case 3:
                
                var selected = defaults.array(forKey: "Nawafils") as! [Bool]
                if indexPath.row == 0 {
                    selected[1] = !selected[indexPath.row]
                    selected[2] = !selected[indexPath.row]
                    selected[3] = !selected[indexPath.row]
                    selected[4] = !selected[indexPath.row]
                }
                selected[indexPath.row] = !selected[indexPath.row]
                
                var identifier = [String]()
                if selected[1]{
                    identifier.append("ISHRAAQ")
                }
                if selected[2]{
                    //chaast
                    identifier.append("CHAASHT")
                }
                if selected[3]{
                    //awabeen
                    identifier.append("AWABEEN")
                }
                if selected[4]{
                    //tahajud
                    identifier.append("TAHAJJUD")
                }
                
                var alarmInfo2: [String:Bool] = [:]
                if let info = defaults.dictionary(forKey: "alarmInfo") {
                    alarmInfo2 = info as! [String : Bool]
                }
                
                for i in 0..<identifier.count{
                    if !alarmInfo2.keys.contains(identifier[i]){
                        alarmInfo2["\(identifier[i])"] = false
                    }
                }
                
                defaults.set(alarmInfo2, forKey: "alarmInfo")
                defaults.set(selected, forKey: "Nawafils")
                
                
            case 5:
            
                if indexPath.row == 0 {
                    for (key,_) in alarmInfo {
                        alarmInfo[key] = false
                    }
                    UserDefaults.standard.set(false, forKey: "StartAllNotifications")
                    uncheckAllNamaz(section: indexPath.section)
                    uncheck(section: indexPath.section, row: 1)
                    alarmInfo["Stop"] = true
                    
                    let center = UNUserNotificationCenter.current()
                    center.removeAllPendingNotificationRequests()
                }else if indexPath.row == 1 {
                    UserDefaults.standard.set(true, forKey: "StartAllNotifications")
                    uncheckAllNamaz(section: indexPath.section)
                    uncheck(section: indexPath.section, row: 0)
                    alarmInfo["Stop"] = false
                    
                    let namazArray = ["FAJR", "SUNRISE", "DHUHR", "ASR", "MAGHRIB", "ISHA"]
                    let timeArray = [Prayer.fajr,Prayer.sunrise,Prayer.dhuhr,Prayer.asr,Prayer.maghrib,Prayer.isha]
                    for i in 0..<namazArray.count {
                        if alarmInfo[namazArray[i]]!{
                            removeNotification(identifier: namazArray[i])
                        }else {
                            alarmInfo[namazArray[i]] = true
                            let time = prayerTimes[timeArray[i]]
                            setNotification(identifier: namazArray[i], time: time!)
                        }
                    }
                    
                }else {
                    var rowItem = menuData[indexPath.section][key!]?[indexPath.row].uppercased() ?? ""
                    
                    if (rowItem == "MAGRIB"){
                        rowItem = "MAGHRIB"
                    }
                    
                    uncheck(section: indexPath.section, row: 0)
                    uncheck(section: indexPath.section, row: 1)
                    
                    alarmInfo["Stop"] = false
                    UserDefaults.standard.set(false, forKey: "StartAllNotifications")
                    
                    if alarmInfo[rowItem]!{
                        removeNotification(identifier: rowItem)
                    }else {
                        alarmInfo[rowItem] = true
                        let time = prayerTimes[arrayOfKeys[indexPath.row-2]]
                        setNotification(identifier: rowItem, time: time!)
                    }
                }
                defaults.set(alarmInfo, forKey: "alarmInfo")
                
            case 7: //6
                
                if currentCell.dropdown.isHidden {
                    currentCell.dropdown.show()
                }else{
                    currentCell.dropdown.hide()
                }
           
            default:
                break
                
            }
            
            if  !(indexPath.section == 7) && !(indexPath.section == 0 && indexPath.row == 1){ //6
             //   currentCell.btnCheckbox.isSelected = !currentCell.btnCheckbox.isSelected
                tblView.reloadData()
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        if let headerView = view.subviews.first as? SettingsTableViewCell {
            headerView.frame.size.width = view.frame.size.width
            headerView.frame.size.height = view.frame.size.height
            
            let trailingConstraint = NSLayoutConstraint(item:  headerView, attribute: .trailing, relatedBy: .equal, toItem: headerView.btnArrow, attribute: .trailing, multiplier: 1, constant: 20)
            headerView.addConstraint(trailingConstraint)
            
        }
        
        let sectionBorder = CALayer()
        sectionBorder.borderColor = UIColor(red:0.11, green:0.51, blue:0.75, alpha:1.0).cgColor
        sectionBorder.frame = CGRect(x: 0, y: view.frame.size.height-1, width: view.frame.size.width, height: 1)
        sectionBorder.borderWidth = 1
        view.layer.addSublayer(sectionBorder)

        view.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
 
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension SettingsViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        let selectedPlace = SavedLocation(name: place.name ?? "", Id: place.placeID ?? "", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        // [ADDED] 22 January, 2021
        do{
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: selectedPlace, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "SelectedPlace")
            UserDefaults.standard.set(encodedData, forKey: "savedLocation")

        }catch{
            print(error)
        }
        
        // [REMOVED] 22 January, 2021
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: selectedPlace)
//        UserDefaults.standard.set(encodedData, forKey: "SelectedPlace")
//        UserDefaults.standard.set(encodedData, forKey: "savedLocation")
        
        defaults.set(1, forKey: "Location")
    
        let myLong = String(place.coordinate.longitude)
        let myLat = String(place.coordinate.latitude)
        
        UserDefaults.standard.set(myLong, forKey: "longGPS")
        UserDefaults.standard.set(myLat, forKey: "latGPS")
        
        dismiss(animated: true, completion: nil)
        tblView.reloadData()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        //print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
