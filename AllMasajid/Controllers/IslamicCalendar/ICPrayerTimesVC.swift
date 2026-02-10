//
//  ICPrayerTimesVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 18/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import SafariServices
import PKHUD
import CoreLocation
//import Adhan

class ICPrayerTimesVC: UIViewController {
    
    var selectedDateReceived = Date()
    var englishDateReceived = ""
    var islamicDateReceived = ""
    
    let formatter = DateFormatter()
    var prayersArray = [Prayer]()
    var prayerTimes : [Prayer: String] = [:]
    
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!
    
    @IBOutlet weak var englishDateLBL: UILabel!
    @IBOutlet weak var islamicDateLBL: UILabel!
    @IBOutlet weak var cityLBL: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item2"
        self.parent?.present(vc, animated: false, completion: nil)
    }
}

extension ICPrayerTimesVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "ic"
        vc.titleStr = "Islamic Calendar"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        print("Do nothing")
    }
    
    func shareBtnPressed() {
        sharePrayersData()
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func favouritesBtnPressed(){
        print("Do nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension ICPrayerTimesVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "ICPrayerTimesTVC", for: indexPath) as! ICPrayerTimesTVC
        let item = prayerTimes[prayersArray[indexPath.row]]
        let thisPrayer = prayersArray[indexPath.row]
        
        let prayerName = String(describing: prayersArray[indexPath.row]).uppercased()
        
        var displayPrayerName = prayerName.capitalized
        displayPrayerName = displayPrayerName == "Maghrib" ? "Magrib": displayPrayerName
        displayPrayerName = displayPrayerName == "Isha" ? "Isha'a": displayPrayerName
        displayPrayerName = displayPrayerName == "Ishraaq" ? "Ishraq": displayPrayerName
        cell.titleLBL.text = displayPrayerName
        
        cell.myIMG.image = UIImage(named: prayerName + "-icon")
        
        if thisPrayer == Prayer.awabeen || thisPrayer == Prayer.chaasht || thisPrayer == Prayer.ishraaq || thisPrayer == Prayer.tahajjud{
            cell.containerView.backgroundColor = UIColor(red:0.04, green:0.20, blue:0.38, alpha:1.0)
        }else{
            cell.containerView.backgroundColor = UIColor(red:0.051, green:0.455, blue:0.827, alpha:1.0)
        }
        
        let components = item?.components(separatedBy: " ")
        if (defaults.integer(forKey: "Time Format")) == 0 {
            cell.timeLBL.text = components![1] /*+ " " + components![2]*/
        }
        else{
            cell.timeLBL.text = components?[1]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


extension ICPrayerTimesVC {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "ICPrayerTimesTVC", bundle: nil), forCellReuseIdentifier: "ICPrayerTimesTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, yyyy"
        let currDate = formatter.string(from: selectedDateReceived)
        
        englishDateLBL.text = currDate
        islamicDateLBL.text = islamicDateReceived
        
        fetchData()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension ICPrayerTimesVC {
    
    func getNamazTimings() {
        
        self.prayersArray.removeAll()
        self.prayerTimes.removeAll()
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: selectedDateReceived)

        let coordinates = Coordinates(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)

        var params = calculationMethods[defaults.integer(forKey: "Method")].params

        if defaults.integer(forKey: "Prayers Calculation Method") == 1 {

        params = CalculationParameters(fajrAngle: Double(defaults.string(forKey: "FajrAngle")!)!, ishaAngle: Double(defaults.string(forKey: "IshaAngle")!)!)
        }

        params.madhab = madhabs[defaults.integer(forKey: "School/Juristic")]

        let selectedPrayers = defaults.array(forKey: "Nawafils") as! [Bool]

        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params){

            formatter.timeStyle = .medium
            if (defaults.integer(forKey: "Time Format")) == 0 {
               formatter.dateFormat = "yyyy-MM-dd hh:mm a"
            }else{
               formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }

            formatter.timeZone = TimeZone.current


            prayerTimes[Prayer.fajr] = formatter.string(from: prayers.fajr)
            prayersArray.append(Prayer.fajr)
                
            prayerTimes[Prayer.sunrise] = formatter.string(from: prayers.sunrise)
            prayersArray.append(Prayer.sunrise)

            if selectedPrayers[1] {
                prayerTimes[Prayer.ishraaq] = formatter.string(from: prayers.time(for: Prayer.ishraaq) ?? Date())
                prayersArray.append(Prayer.ishraaq)
            }

            if selectedPrayers[2]{
                prayerTimes[Prayer.chaasht] = formatter.string(from: prayers.time(for: Prayer.chaasht) ?? Date())
                prayersArray.append(Prayer.chaasht)
            }
            prayerTimes[Prayer.dhuhr] = formatter.string(from: prayers.dhuhr.addingTimeInterval(TimeInterval(6*60)))
            prayersArray.append(Prayer.dhuhr)
                
            prayerTimes[Prayer.asr] = formatter.string(from: prayers.asr)
            prayersArray.append(Prayer.asr)
                
            prayerTimes[Prayer.maghrib] = formatter.string(from: prayers.maghrib)
            prayersArray.append(Prayer.maghrib)

            if selectedPrayers[3]{
                prayerTimes[Prayer.awabeen] = formatter.string(from: prayers.time(for: Prayer.awabeen) ?? Date())
                prayersArray.append(Prayer.awabeen)
            }

            prayerTimes[Prayer.isha] = formatter.string(from: prayers.isha)
            prayersArray.append(Prayer.isha)

            if selectedPrayers[4]{
                prayerTimes[Prayer.tahajjud] = formatter.string(from: prayers.time(for: Prayer.tahajjud) ?? Date())
                prayersArray.append(Prayer.tahajjud)
            }

            myTableView.reloadData()
        }
    }
}

extension ICPrayerTimesVC {
    
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
            
        }else if defaults.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNamazTimings()
                    self.getCity()
                }
            } catch { print(error) }
            
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
    
    func sharePrayersData(){
        
        var text2Share = "****** allMasajid - PRAYER TIMES ******\n\n"
        
        for key in prayersArray {
            let item = prayerTimes[key]
            let prayerName = String(describing: key).uppercased()
            text2Share = text2Share + "- \(prayerName): \(item!)\n"
        }
        
        text2Share = text2Share + "\n\nAre you the one who is struggling to chase prayer timings? Don’t worry about it further. allMasajid app will always keep you updated about Salah’s schedule at one click./nFor Android: https://bit.ly/2zCeFwM/nFor IOS: https://apple.co/2zHQXzo/nDownload our app, so you never miss any prayers in the future."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activity.popoverPresentationController?.sourceView = self.englishDateLBL
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
        
    }
}

extension ICPrayerTimesVC{
    
    func observeLocation(object: LocationManager) {
        objectToObserve = object
        if (objectToObserve.myLocation == nil) {
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

    func getCity(){

        let latt : String = "\(myLocation.coordinate.latitude)"
        let lonn : String = "\(myLocation.coordinate.longitude)"
        GetCityFromCordinates.sharedGetCity.getAddressFromLatLon(pdblLatitude: latt, withLongitude: lonn, lbl: cityLBL)
    }

    func showLocationAlert(){
        let alertController = UIAlertController(title: "Location Services Off OR No Permission Granted Yet!", message: "Either location services are off OR you did not allow 'My Masajid App' to access your location. Please turn on location services from phone settings for this application or use manual location from application settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}

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
