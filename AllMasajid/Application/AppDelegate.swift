//
//  AppDelegate.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 9/14/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import Firebase
import Messages
import UserNotifications
import CoreLocation
//import Adhan
import GooglePlaces
import IQKeyboardManagerSwift
import YandexMobileMetrica
import SwiftyJSON
import FBSDKLoginKit
import GoogleSignIn
//import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    var myFCMToken = ""
    let gcmMessageIDKey = "gcm.message_id"
    var notificationType = ""
    var notificiationID = ""
    
    var locationManager:CLLocationManager!
    private var currentCoordinate: CLLocationCoordinate2D?
    var currentLocation:CLLocation?
    var locationValue:CLLocationCoordinate2D?
    
    var city: String = ""
    
    var myLocation = CLLocation()
    var observation: NSKeyValueObservation?
    @objc var objectToObserve: LocationManager!
    
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        CurrentTimeZone = TimeZone.current.identifier
        
        if UserDefaults.standard.bool(forKey: "rememberMe") != true {
            print("NOT REMEMBER")
            UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
        }
//        StripeAPI.defaultPublishableKey = Secrets.stripePublishableKey
//        STPAPIClient.shared.publishableKey = Secrets.stripePublishableKey
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        IQKeyboardManager.shared.isEnabled = true
        
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: Secrets.yandexMetricaAPIKey)
        YMMYandexMetrica.activate(with: configuration!)
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {(permissionGranted, error) in
            print(error as Any)
        })
        
        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject]{
                if let notificationType = notification["notification_type"] {
                    self.notificationType = "\(notificationType)"
                }
                
                if let notificationid = notification["data"] {
                    self.notificiationID = "\(notificationid)"
                }
            }
            
            setupNotificationTap(type: self.notificationType, id: self.notificiationID)
        }
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = UIColor(hexString: "0E152D")
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }else{
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
                statusBar.backgroundColor = UIColor(hexString: "0E152D")
            }
        }
        
        checkSettings()
        GMSPlacesClient.provideAPIKey(Secrets.googlePlacesAPIKey)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = .white
        navigationBarAppearace.barTintColor = UIColor(red:0.03, green:0.27, blue:0.45, alpha:1.0)
        setupLocationManager()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        
        // For Facebook Signin
        
        Settings.shared.graphAPIVersion = "v19.0"
        
        ApplicationDelegate.shared.application(application,
                    didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler:
                     @escaping (UIBackgroundFetchResult) -> Void) {

        fetchData()
        completionHandler(.newData)
    }
    
    // For Facebook Signin
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application,
                                                      open: url,
                                                      sourceApplication: sourceApplication,
                                                      annotation: annotation)
    }

    // For Google Signin
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let handledFB = ApplicationDelegate.shared.application(app, open: url, options: options)
        let handledGoogle = GIDSignIn.sharedInstance.handle(url)
        
        return handledFB || handledGoogle
//        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func checkSettings(){
        
        if let info = defaults.dictionary(forKey: "alarmInfo") {
            print(info)
        }else{
            
            defaults.set(0, forKey: "Location")
            defaults.set(0, forKey: "Prayers Calculation Method")
            defaults.set(0, forKey: "Method")
            defaults.set(0, forKey: "School/Juristic")
            //defaults.set(2, forKey: "Date Adjustment")
            defaults.set(0, forKey: "Time Format")
            defaults.set(0, forKey: "Distance")
            defaults.set(0, forKey: "Unit")
            defaults.set(0, forKey: "White")
            defaults.set([false,false,false,false,false,false], forKey: "Nawafils")
            defaults.set(0, forKey: "Hijri Date")
            defaults.set("", forKey: "FajrAngle")
            defaults.set("", forKey: "IshaAngle")
            defaults.set("", forKey: "currentDate")
            let alarmInfo : [String : Bool] = ["Stop":true,"FAJR":false,"SUNRISE":false,"DHUHR":false,"ASR":false,"MAGHRIB":false,"ISHA":false,"Silent":false]
            defaults.set(alarmInfo, forKey: "alarmInfo")
            // defaults.set([0,0,0], forKey: "Additional Settings")
        }
    }
    
    //############################################################################################
    //################################################################ LOCAL NOTIFICATIONS (NAMAZ)
    //############################################################################################
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        print(userInfo)
        completionHandler([.alert, .sound, .badge]) //required to show notification when in foreground
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let notificationType = userInfo["notification_type"] {
            manageNotificationData(notification: notificationType as! String)
            guard let notifID = userInfo["data"]  as? String else {return}
            
            self.notificationType = "\(notificationType)"
            self.notificiationID = "\(notifID)"
            setupNotificationTap(type: "\(notificationType)", id: notifID)
        }

        fetchData()
        completionHandler()
    }
    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startUpdatingLocation()
    }

    // Below method will provide you current location.
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if currentLocation == nil {
            currentLocation = locations.last
            locationManager?.stopMonitoringSignificantLocationChanges()
            locationValue = manager.location!.coordinate

            print("locations = \(locationValue?.longitude ?? 0)")
            let myLong = String(locationValue?.longitude ?? 0)
            let myLat = String(locationValue?.latitude ?? 0)
            
            UserDefaults.standard.set(myLong, forKey: "longGPS")
            UserDefaults.standard.set(myLat, forKey: "latGPS")
            
            locationManager?.stopUpdatingLocation()
            fetchData()
        }
    }

    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
        //fetchData()
    }

    func getNamazTimings(long: Double, lat: Double){
        
        var alarmInfo : [String: Bool] = [:]
        var arrayOfKeys : [Prayer] =  []
        var prayerTimes : [Prayer:String] = [:]
        
        
        let formatter = DateFormatter()
        
        var nextPrayer : Prayer? = nil
        var currentPrayer : Prayer? = nil
        
        if (prayerTimes.isEmpty == false) {
            prayerTimes.removeAll()
        }
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        
        //let coordinates = Coordinates(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
        let coordinates = Coordinates(latitude: lat, longitude: long)
        
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
                }
                else{
                    dateFormatter.dateFormat = "HH:mm"
                }
                dateFormatter.timeZone = TimeZone.current
                
            }
            
            if nextPrayer == Prayer.none || nextPrayer == nil{
                nextPrayer = Prayer.fajr
            }
                        
            if currentPrayer == Prayer.none || currentPrayer == nil {
                currentPrayer = Prayer.fajr
            }
        }
        removeAllNotifications()
        
        for i in 0..<arrayOfKeys.count{
            
            let identifier = String(describing: arrayOfKeys[i]).uppercased()
            if let info = defaults.dictionary(forKey: "alarmInfo") {
                alarmInfo = info as! [String : Bool]
            }
            
            if !alarmInfo.keys.contains(identifier){
                alarmInfo["\(identifier)"] = false
            }

            alarmInfo["Stop"] = false
            defaults.set(alarmInfo, forKey: "alarmInfo")
            let time = prayerTimes[arrayOfKeys[i]]
                        
            if alarmInfo[identifier] == true {
                setNotification(identifier: identifier, time: time!)
            }
        }
    }
    
    func removeAllNotifications(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func fetchData(){
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    
                    getAddressFromLatLon(pdblLatitude: "\(myLocation.coordinate.latitude)", withLongitude: "\(myLocation.coordinate.longitude)")
                }
            } catch { print(error) }
        }else if defaults.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    getAddressFromLatLon(pdblLatitude: "\(myLocation.coordinate.latitude)", withLongitude: "\(myLocation.coordinate.longitude)")
                }
            } catch { print(error) }
        }else{
            
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                getAddressFromLatLon(pdblLatitude: "\(myLocation.coordinate.latitude)", withLongitude: "\(myLocation.coordinate.longitude)")
            }else{
                
                let myLong = UserDefaults.standard.object(forKey: "longGPS") as! String
                let myLat = UserDefaults.standard.object(forKey: "latGPS") as! String
                
                getAddressFromLatLon(pdblLatitude: myLat, withLongitude: myLong)
                LocationManager.shared.requestLocation()
            }
        }
    }
    
     func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
         
        var addressString : String = ""
         var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
         let lat: Double = Double("\(pdblLatitude)")!
         
         let lon: Double = Double("\(pdblLongitude)")!
         
         let ceo: CLGeocoder = CLGeocoder()
         
         center.latitude = lat
         center.longitude = lon
         
         let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
         
         ceo.reverseGeocodeLocation(loc, completionHandler:
             {(placemarks, error) in
                 if (error != nil)
                 {
                     print("reverse geodcode fail: \(error!.localizedDescription)")
                 }
                 //print(placemarks)
                 if placemarks != nil {
                 
                 let pm = placemarks! as [CLPlacemark]
                    print(pm)
                 if pm.count > 0 {
                     let pm = placemarks![0]
                     
                     if pm.subLocality != nil {
                         addressString = addressString + pm.subLocality! + ", "
                     }
                     if pm.locality != nil {
                         addressString = addressString + pm.locality!
                     }
                    print(addressString)
                 }
                    
         }
                self.city = addressString
                self.getNamazTimings(long: lon, lat: lat)
         })
     }
    
    func setNotification(identifier : String, time : String){
        let center = UNUserNotificationCenter.current()
       
        let dateFormatter : DateFormatter = DateFormatter()
        let comp = time.components(separatedBy: " ")
        
        let content = UNMutableNotificationContent()
      
        if (defaults.integer(forKey: "Time Format")) == 0 {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            content.title = "\(comp[1]) \(comp[2]) \(identifier)"
        }
        else{
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            content.title = "\(comp[1]) \(identifier)"
        }
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.defaultCritical
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.default
        }
        let date = Date()
        let result = dateFormatter.string(from: date)
        
        let currentDate = dateFormatter.date(from: result)
        var namazDate = dateFormatter.date(from: time)
        var interval = namazDate?.timeIntervalSince(currentDate!)
        if interval! < 0.0 {
            namazDate = NSCalendar.current.date(byAdding: .day, value: 1, to: namazDate!)
            interval = namazDate?.timeIntervalSince(currentDate!)
        }
        
        var namazTitle = identifier
        if namazTitle == "MAGHRIB"{
            namazTitle = "MAGRIB"
        }else if namazTitle == "ISHRAAQ"{
            namazTitle = "ISHRAQ"
        }else if identifier == "ISHA" {
            namazTitle = "ISHA'A"
        }
        
        content.body = "It is time for \(namazTitle) prayers in \(city)."
        content.sound = UNNotificationSound.default
        let components = NSCalendar.current.dateComponents([.hour,.minute], from: namazDate!)
        let alarmTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: alarmTrigger)
         
        center.add(request, withCompletionHandler: {(error) in
            
            print(error as Any)
        })
    }
    
    //############################################################################################
    //################################################################ FIREBASE PUSH NOTIFICATIONS
    //############################################################################################
    
    func setupNotificationTap(type: String, id: String){
        NotificationID = id
        if type == "event"{ // Open events
            TerminatedNotification = .event
            NotificationCenter.default.post(name: NSNotification.Name("allMEventsNotificationTap"), object: nil)
        }else if type == "announcement"{ // Open Announcements
            TerminatedNotification = .announcemet
            NotificationCenter.default.post(name: NSNotification.Name("allMAnnouncementsNotificatonTap"), object: nil)
        }else if type == "dua_appeal"{ // Open Dua Appeals
            TerminatedNotification = .duaAppeal
            NotificationCenter.default.post(name: NSNotification.Name("allMDuaAppealNotificatonTap"), object: nil)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let notificationType = userInfo["notification_type"] {
            manageNotificationData(notification: notificationType as! String)
            if application.applicationState == UIApplication.State.inactive || application.applicationState == UIApplication.State.background || application.applicationState == UIApplication.State.active {
                
                guard let notifID = userInfo["data"] as? String else {return}
                self.notificationType = "\(notificationType)"
                self.notificiationID = "\(notifID)"
                setupNotificationTap(type: "\(notificationType)", id: "\(notifID)")
            }
        }
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func manageNotificationData(notification: String){
        
        print("\\\\\(notification)")
    }
}

extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "nil")")
        
        guard let token = fcmToken else {
            print("FCM token is nil")
            return
        }
        
        myFCMToken = token
        myFirebaseToken = myFCMToken
        
        let dataDict:[String: String] = ["token": token]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

extension UIApplication {
    var statusBarUIView: UIView? {
        
        if #available(iOS 13.0, *) {
            let tag = 3848245
            
            let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999
                
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
            
        } else {
            
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}
