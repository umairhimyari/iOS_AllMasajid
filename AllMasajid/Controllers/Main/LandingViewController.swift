//
//  LandingViewController.swift
//  AllMasajid
//
//  Created by 12345 on 9/21/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import PKHUD
import SwiftyJSON

class LandingViewController: UIViewController {
            
    let storyboardObj = UIStoryboard(name: "Main", bundle: nil)
    
    var mainData: [(title:String,image:String)] = []
    
    var numberOfPages = 0
    
    var cellsSpacing = 10

    var cellsPerRow = DesignUtility.isIPad ? 4 : 3
    var cellsPerColumn = 3
    
    var wfdArray = [WhiteFastingDaysModel]()
    var currentWeekDay = ""
    
    var todaysDate = ""
    
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var lblWhiteFastingDays: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnLeftManu: UIButton!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var cityLBL: UILabel!
    @IBOutlet weak var bellBTN: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        setupGestures()
        checkLoggedInStatus()
        configureMainView()

        // Fix notification bell position - move it to header area
        repositionBellButton()

        getTodayDate()
        tryAgain()
    }

    private func repositionBellButton() {
        guard let bellButton = bellBTN else { return }

        // Remove from current superview
        bellButton.removeFromSuperview()

        // Add to main view
        view.addSubview(bellButton)

        // Reset constraints
        bellButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Position to the LEFT of the settings button (settings is 60x60 at trailing -15)
            // Bell position: trailing = -(15 margin + 60 settings width + 10 spacing) = -85
            bellButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            bellButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -85),
            bellButton.widthAnchor.constraint(equalToConstant: 30),
            bellButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Bring to front
        view.bringSubviewToFront(bellButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true{
            myToken = UserDefaults.standard.object(forKey: "token") as! String
            httpHeaders = ["Authorization": "Bearer \(myToken)", "devicetoken": myFirebaseToken, "platform": "ios"]
            if let email = UserDefaults.standard.object(forKey: "userEmail") as? String{
                userEmail = email
            }
            bellBTN.isHidden = false
            print("USER EMAIL: \(userEmail)")
        }else{
            bellBTN.isHidden = true
            httpHeaders = ["devicetoken": "", "platform": "ios"]
        }
        
        handleNotifications()
        collectionView.reloadData()
        configureLeftMenuButton()
        
        if !Reachability.isConnectedToNetwork() {
            let vc = UIStoryboard().LoadNoInternetScreen()
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
        
        if settingsVisit == true {
            settingsVisit = false
            tryAgain()
        }
    }
  
    override func viewDidLayoutSubviews() {
        pageControl.numberOfPages = Int(numberOfPages)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("allMEventsNotificationTap"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("allMAnnouncementsNotificatonTap"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("allMDuaAppealNotificatonTap"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
        
        TerminatedNotification = nil
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let vc = UIStoryboard().LoadSettingScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func bellIconPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadNotificationsListScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LandingViewController {
    
    func tryAgain() {
        configureWFD()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
        locationSettings()
    }
    
    func handleNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("allMEventsNotificationTap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("allMAnnouncementsNotificatonTap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("allMDuaAppealNotificatonTap"), object: nil)
        
        if TerminatedNotification == .event {
            gotoEvents()
        }else if TerminatedNotification == .announcemet {
            gotoAnnounements()
        }else if TerminatedNotification == .duaAppeal {
            gotoDuaAppeals()
        }
    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "allMEventsNotificationTap" {
            gotoEvents()
        }else if notification.name.rawValue == "allMAnnouncementsNotificatonTap" {
            gotoAnnounements()
        }else if notification.name.rawValue == "allMDuaAppealNotificatonTap" {
            gotoDuaAppeals()
        }else if notification.name.rawValue == "LocationFetched" {
            myLocation = LocationManager.shared.myLocation!
            getCity()
        }
    }
    
    func gotoEvents(){
        let vc = UIStoryboard().LoadEventDetailsScreen()
        vc.IdReceived = Int(NotificationID) ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoAnnounements(){
        let vc = UIStoryboard().LoadAnnouncementDetailScreen()
        vc.IdReceived = Int(NotificationID) ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoDuaAppeals(){
        let vc = UIStoryboard().LoadRequest4DuaDetailScreen()
        vc.idReceived = Int(NotificationID) ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LandingViewController:DynamicGridLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return mainData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell",
                                                      for: indexPath) as! MainCell
        
        cell.imgLogo.image = UIImage(named: mainData[indexPath.row].image)
        cell.lblTitle.text = "\(mainData[indexPath.row].title)"
        
//        if mainData[indexPath.row].title == "Iqamah"{
//            cell.imgLogo.alpha = 0.4
//        }else{
            cell.imgLogo.alpha = 1.0
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let title = mainData[indexPath.row].title
        
        if (title == "Prayer Times") {
            
            let vc = UIStoryboard().LoadPrayerTimesScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }
            
        else if (title == "Masajid Nearby") {
            
            let vc = UIStoryboard().LoadNearbyMasajidScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if (title == "My Masajid") {
            
            let vc = UIStoryboard().LoadMyMasajidScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if (title == "Qibla Direction") {
            
            let vc = UIStoryboard().LoadQiblaViewScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if (title == "Events") {
            
            let vc = UIStoryboard().LoadEventsNewScreen()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if (title == "Announcements") {
            
            let vc = UIStoryboard().LoadAnnouncementsNewScreen()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if(title == "Contribute"){
            
            let vc = UIStoryboard().LoadContributeScreen()
            self.navigationController?.pushViewController(vc, animated: true)
                        
        }else if(title == "Supplications"){
            let vc = UIStoryboard().LoadDailyDuasScreen()
            self.navigationController?.pushViewController(vc, animated: true)
                        
        }else if(title == "Iqamah"){
            /*
            let vc = UIStoryboard().LoadIqamahScreen()
            var friday = false
            if currentWeekDay == "Friday"{
                friday = true
            }
            vc.isJummah = friday
            self.navigationController?.pushViewController(vc, animated: true)
            */
            HUD.flash(.label("Coming Soon Insha Allah"))
                        
        }else if title == "Duaa Appeals" {
            let vc = UIStoryboard().LoadRequest4DuasScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if title == "Islamic Calendar" {
            let vc = UIStoryboard().LoadIslamicCalendarScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if title == "Feed A Need" {
            let vc = UIStoryboard().LoadFanSelectionScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if title == "Muslim Directory" {
            let vc = UIStoryboard().LoadMuslimDirectoryHomeScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if title == "Ramadan Special" {
            let vc = UIStoryboard().LoadRamadanSpecialScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if title == "Al Quran" {
            let vc = UIStoryboard().LoadChaptersListing()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        else{
            HUD.flash(.label("Coming Soon Insha Allah"))
        }
    }
}

extension LandingViewController {
    
    func setupGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.footerView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func goToLogin(_ sender: Any) {
        let vc = UIStoryboard().LoadPreLoginScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openMenu(_ sender: Any) {
        
        let vc = UIStoryboard().LoadSideMenuScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.menuProtocol = self
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func configureLeftMenuButton() {
      
        self.hideKeyboardWhenTappedAround()
        btnLeftManu.isUserInteractionEnabled = true
    }
      
    func configureMainView(){
      
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        let cellsPerSection = Int(cellsPerRow * cellsPerColumn)
        numberOfPages = itemsCount / cellsPerSection

        if itemsCount % cellsPerSection > 0 {
            numberOfPages += 1
        }else if itemsCount > 0 && itemsCount < cellsPerSection {
            numberOfPages += 1
        }

        if let layout = collectionView?.collectionViewLayout as? DynamicGridLayout {
            layout.delegate = self
        }else{
            fatalError("DynamicGridLayout is not choosen as a layout for collectionView!")
        }
    }
    
    func configureWFD(){
        
        var dateAdjustment = ""
        if UserDefaults.standard.bool(forKey: "dateAdjustmentStatus") == true {
            dateAdjustment = UserDefaults.standard.object(forKey: "dateAdjustment") as! String
        }else{
            dateAdjustment = "0"
        }

        networkHit(dateAdjustment: dateAdjustment)
    }
    
    func locationFetched(_ succes: Bool) {
        print("--------------------------- Location Fetched in Landing VC")
    }
    
    func getTodayDate(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "EEEE"
        
        let now = Date()
        todaysDate = formatter.string(from:now)
        currentWeekDay = formatter2.string(from:now)
        print(currentWeekDay)
    }
}

extension LandingViewController{
    
    func checkLoggedInStatus(){
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            
            btnLeftManu.addTarget(self, action: #selector(openMenu(_:)), for: UIControl.Event.touchUpInside)
            btnLeftManu.setImage(UIImage(named: "menu"), for: UIControl.State.normal)

            self.mainData = [("Prayer Times","prayer-time-icon"), ("My Masajid","my-masajid-main"), ("Masajid Nearby","masajid-nearby"), ("Islamic Calendar","islamic-calendar"), ("Supplications","dua-icon"), ("Contribute","contribute-main"), ("Feed A Need","FeedaNeedIcon"), ("Duaa Appeals","duaApealsMain"), ("Qibla Direction","qibla-direction"), ("Muslim Directory", "muslimDir01Icon"), ("Al Quran", "alQuran")] //("Events","events"), ("Announcements","announcement"), ("Iqamah","iqamah")
        }else{
           
            btnLeftManu.addTarget(self, action: #selector(goToLogin(_:)), for: UIControl.Event.touchUpInside)
            btnLeftManu.setImage(UIImage(named: "left-menu"), for: UIControl.State.normal)

            self.mainData = [("Prayer Times","prayer-time-icon"), ("Masajid Nearby","masajid-nearby"), ("Islamic Calendar","islamic-calendar"), ("Supplications","dua-icon"), ("Contribute","contribute-main"), ("Feed A Need","FeedaNeedIcon"), ("Duaa Appeals","duaApealsMain"), ("Qibla Direction","qibla-direction"), ("Muslim Directory", "muslimDir01Icon"), ("Al Quran", "alQuran")]//("Events","events"), ("Announcements","announcement"), ("Iqamah","iqamah")
        }
        
//        mainData.append(("Ramadan Special", "ramadan_special"))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = Float(UIScreen.main.bounds.width)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView.contentSize.width)
        
        var newPage = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if newPage > contentWidth / pageWidth {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        self.pageControl.currentPage = Int(newPage)
        let point = CGPoint(x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
}

extension LandingViewController: TryAgainProtocol {
    
    func networkHit(dateAdjustment: String){
        HUD.show(.progress)
        
//        let da = Int(dateAdjustment) ?? 0
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd"
//
//        let formatter2 = DateFormatter()
//        formatter2.dateFormat = "MM"
//
//        let now = Date()
//        let dm = "\(formatter.string(from:now))\(formatter2.string(from:now))"
//        print("DM is = \(dm)")
        
//        APIRequestUtil.GetWhiteFastingDays(dateAdjustment: da, dateMonth: dm, completion: APIRequestCompleted)
        APIRequestUtil.GetWhiteFastingDays(completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)

            let data = json["data"]
            
            let date1 = data["date1"].stringValue
            let date2 = data["date2"].stringValue
            let date3 = data["date3"].stringValue
            
            let date1Month = date1.getMonthName
            let date2Month = date2.getMonthName
            let date3Month = date3.getMonthName
            
            let currentIslamicDate = data["current_islamic_date"].stringValue
            let islDateArr = currentIslamicDate.components(separatedBy: "-")
            
            if islDateArr.count == 3 {
                let currentIslamicDay = Int(islDateArr[2]) ?? 1
                let currentIslamicMonth = Int(islDateArr[1]) ?? 1
                let currentIslamicYear = islDateArr[0]
                
                let currentDate = "\(todaysDate)/\(currentIslamicDay) \(IslamicMonths[currentIslamicMonth - 1]) \(currentIslamicYear)"
                lblDate.text = currentDate
                UserDefaults.standard.set(currentDate, forKey: "currentDate")
                
                if currentIslamicMonth == 9 || currentIslamicDay > 15 {
                    lblWhiteFastingDays.isHidden = true
                }else{
                    lblWhiteFastingDays.isHidden = false
                }
                
//                if currentIslamicMonth != 9 {
//                    for i in 0..<mainData.count {
//                        if mainData[i].title == "Ramadan Special" {
//                            mainData.remove(at: i)
//                        }
//                    }
//                }
                
                if date1Month == date2Month &&
                    date2Month == date3Month {
                    lblWhiteFastingDays.text = "\(date1Month) \(date1.getDateNo), \(date2.getDateNo) & \(date3.getDateNo) are the white fasting days."
                }else if date1Month != date2Month {
                    lblWhiteFastingDays.text = "\(date1Month) \(date1.getDateNo), \(date2Month) \(date2.getDateNo) & \(date3.getDateNo) are the white fasting days."
                }else if date2Month != date3Month {
                    lblWhiteFastingDays.text = "\(date1Month) \(date1.getDateNo), \(date2.getDateNo) & \(date3Month) \(date3.getDateNo) are the white fasting days."
                }
            }
            
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


extension LandingViewController {
    
    func locationSettings(){
        
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getCity()
                }
            } catch { print(error) }
            
        }else if defaults.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getCity()
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                getCity()
                
            }else{
                LocationManager.shared.requestLocation()
            }
        }
    }

    func getCity(){
        
        let latt : String = "\(myLocation.coordinate.latitude)"
        let lonn : String = "\(myLocation.coordinate.longitude)"
        GetCityFromCordinates.sharedGetCity.getAddressFromLatLon(pdblLatitude: latt, withLongitude: lonn, lbl: cityLBL)
    }
}

extension LandingViewController: SideMenuProtocol {
    
    func profilePressed() {
        let vc = UIStoryboard().LoadProfileScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func logoutPressed() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        userEmail = ""
        
        let vc = UIStoryboard().LoadLandingScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func how2UseAppPressed(){
        let vc = UIStoryboard().LoadHow2UseCategoryScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
