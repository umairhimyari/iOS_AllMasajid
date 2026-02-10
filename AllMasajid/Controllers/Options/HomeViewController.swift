//
//  HomeViewController.swift
//  AllMasajid
//
//  Created by 12345 on 9/18/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit
import SideMenu
import PKHUD
import CoreLocation
import Alamofire

class HomeViewController: UIViewController {

    let dateAdjustments : [String] = ["-2","-1","0","1","2"]
    let defaults = UserDefaults.standard
    let storyboardObj = UIStoryboard(name: "Main", bundle: nil)
    var myLocation = CLLocation()
    var viewItems : [UIView] = []
    let mainData: [(title:String,image:String)] = [("Prayer Time","prayer-time-icon"), ("Masajid Nearby","masajid-nearby"), ("Iqamah","iqama-icon"), ("Events","events"), ("Announcements","announcement"), ("Islamic Calendar","events"), ("Daily Duas","daily-duas-main"), ("Contribute","contribute-main"), ("Qibla Direction","qibla-direction")]
    
    var numberOfItems = 9
    var numberOfPages = 0
    var cellsSpacing = 10
    var cellsPerRow = 3
    var cellsPerColumn = 3
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var lblWhiteFastingDays: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewContribute: UIView!
    @IBOutlet weak var viewDuas: UIView!
    @IBOutlet weak var viewQibla: UIView!
    @IBOutlet weak var viewEvents: UIView!
    @IBOutlet weak var viewMasajidNearby: UIView!
    @IBOutlet weak var viewMyMasjid: UIView!
    @IBOutlet weak var viewPrayerTimes: UIView!
    @IBOutlet var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("I am in HomeViewController")
        //configureMainView()
        
        setGestures()
        self.hideKeyboardWhenTappedAround()
        let menuLeftNavigationController = storyboardObj.instantiateViewController(withIdentifier: "SideMenuController") as!  SideMenuNavigationController
        SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
        
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (self.navigationController?.view)!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: NSNotification.Name("LocationFetched"), object: nil)
        
        
        
        if defaults.integer(forKey: "Location") == 1{
            if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                //  self.setDate()
                
            }
//            else {
//                print("There is an issue")
//            }
        }
        else if defaults.integer(forKey: "Location") == 2{
            if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                //self.setDate()
            }
//            else {
//                print("There is an issue")
//            }
        }
        else{
            
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                //self.setDate()
            }
            else{
                
                LocationManager.shared.requestLocation()
                
            }
        }
   
        // Do any additional setup after loading the view.      
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        //     locationManager.delegate = self
        //   locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /*
    func configureMainView(){
        
        //numberOfItems = mainData.count
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        let cellsPerSection = Int(cellsPerRow * cellsPerColumn)
        numberOfPages = itemsCount / cellsPerSection
        
        if itemsCount % cellsPerSection > 0 {
            numberOfPages += 1
        } else if itemsCount > 0 && itemsCount < cellsPerSection {
            numberOfPages += 1
        }
        if let layout = collectionView?.collectionViewLayout as? DynamicGridLayout {
            layout.delegate = self
        } else {
            fatalError("DynamicGridLayout is not choosen as a layout for collectionView!")
        }
    }
    
    override func viewDidLayoutSubviews() {
        pageControl.numberOfPages = Int(numberOfPages)
    }
    */
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        guard let url = URL(string: "https://www.allmasajid.com") else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setDate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    @objc func didReceiveNotification(){
        myLocation = LocationManager.shared.myLocation!
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGestures(){
        
        viewItems = [viewPrayerTimes,viewEvents,viewMasajidNearby,viewQibla,viewContribute,viewMyMasjid,viewDuas]
        
        for item in viewItems {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGesture:)))
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(tapGesture)
        }
    }
    
    func setDate(){
        let todaysDate = Date()
        
        
        let calender = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.calendar = calender
        
        
        
        let englishDateString = formatter.string(from: todaysDate)
        
//        let islamicCalender = Calendar(identifier: Calendar.Identifier.islamicCivil)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.dateFormat = "dd MMMM yyyy"
//        dateFormatter.timeStyle = .none
//        dateFormatter.calendar = islamicCalender

        //NEW
        let dateFormatter = DateFormatter()
        let islamicCalender = Calendar.init(identifier: Calendar.Identifier.islamicCivil)
        dateFormatter.locale = Locale.init(identifier: "en")
        dateFormatter.calendar = islamicCalender
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var islamicdateString = dateFormatter.string(from: todaysDate)
        var islamicDate = dateFormatter.date(from: islamicdateString)!
        let adjustment = Int(dateAdjustments[defaults.integer(forKey: "Date Adjustment") ])! * 86400
        islamicDate.addTimeInterval(TimeInterval(adjustment))
        
        
        if defaults.integer(forKey: "Hijri Date") == 0 {
            
            if APIManager.shared.getHijriDate() == "" {
                APIManager.shared.api(AFParam(endpoint: "wp-json/islamicdate/all", params: [:], headers: [:], method: .get, parameterEncoding: JSONEncoding.default, images: [])) {
                    if APIManager.shared.isSuccess {
                        islamicdateString = APIManager.shared.getHijriDate()
                        self.lblDate.text = englishDateString + "/" + islamicdateString
                        islamicDate = dateFormatter.date(from: islamicdateString) ?? Date()
                        let components = islamicCalender.dateComponents([.year,.month,.day], from: islamicDate)
                        
                        self.checkWhiteFasting(components: components,islamicDate: islamicDate)
                    }
                    else
                    {
                        islamicdateString = dateFormatter.string(from: islamicDate)
                        
                        self.lblDate.text = englishDateString + "/" + islamicdateString
                        let components = islamicCalender.dateComponents([.year,.month,.day], from: islamicDate)
                        
                        self.checkWhiteFasting(components: components,islamicDate: islamicDate)
                    }
                }
            }
            else {
                
                islamicdateString = APIManager.shared.getHijriDate()
                self.lblDate.text = englishDateString + "/" + islamicdateString
                islamicDate = dateFormatter.date(from: islamicdateString) ?? Date()
                let components = islamicCalender.dateComponents([.year,.month,.day], from: islamicDate)
                
                self.checkWhiteFasting(components: components,islamicDate: islamicDate)
                //  checkWhiteFasting(day: day,islamicDate: islamicDate)
                
            }
        }else{
            
            
            islamicdateString = dateFormatter.string(from: islamicDate)
            
            lblDate.text = englishDateString + "/" + islamicdateString
            let components = islamicCalender.dateComponents([.year,.month,.day], from: islamicDate)
            
            checkWhiteFasting(components: components,islamicDate: islamicDate)
            
        }
        
    }
    
    func checkWhiteFasting(components : DateComponents, islamicDate : Date){
        if components.day ?? 0 <= 15 {
            
            let islamicCalender = Calendar(identifier: Calendar.Identifier.islamicCivil)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateFormatter.timeStyle = .none
            dateFormatter.calendar = islamicCalender
            
            
            let calender = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.calendar = calender
            
            var englishDays : [Int] = []
            let islamicDays : [Int] = [13, 14, 15]
            for day in islamicDays {
                let newComponents = DateComponents(calendar: islamicCalender, timeZone: TimeZone.current, year: components.year, month: components.month, day: day)
                
                let date = islamicCalender.date(from: newComponents)
                
                
                let components = calender.dateComponents([.day], from: date!)
                englishDays.append(components.day ?? 0)
            }
            
            lblWhiteFastingDays.text = "\(englishDays[0]), \(englishDays[1]) and \(englishDays[2]) are the white fasting days."
            lblWhiteFastingDays.isHidden = false
        }
        else{
            lblWhiteFastingDays.isHidden = true
        }
        
    }
    
    @IBAction func openMenu(_ sender: Any) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func goToSettings(_ sender: Any) {

        let vc = UIStoryboard().LoadSettingScreen()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func viewTapped(tapGesture : UITapGestureRecognizer){
        
        let tag = tapGesture.view?.tag ?? 0
       
        switch tag {
        case 1:
            
            let vc = UIStoryboard().LoadPrayerTimesScreen()
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            let vc = UIStoryboard().LoadMyMasajidScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            
            let vc = UIStoryboard().LoadNearbyMasajidScreen()
            self.navigationController?.pushViewController(vc, animated: true)
       case 4:
                  HUD.flash(.label("Coming Soon"))
           // let controller = storyboardObj.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
           //  self.navigationController?.pushViewController(controller, animated: true)
        case 5:

            let vc = UIStoryboard().LoadQiblaViewScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            HUD.flash(.label("Coming Soon"))
            break
        }
    }
}

/*
extension LandingViewController:DynamicGridLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell",
                                                      for: indexPath) as! MainCell
        cell.imgLogo.image = UIImage(named: mainData[indexPath.row].image)
        cell.lblTitle.text = "\(mainData[indexPath.row].title)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let controller = storyboardObj.instantiateViewController(withIdentifier: "PrayerTimesViewController") as! PrayerTimesViewController
            self.navigationController?.pushViewController(controller, animated: true)
        case 1:
            let controller = storyboardObj.instantiateViewController(withIdentifier: "NearbyMasajidViewController") as! NearbyMasajidViewController
            self.navigationController?.pushViewController(controller, animated: true)
        case 2:
            HUD.flash(.label("Coming Soon"))
            //  let controller = storyboardObj.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
        //  self.navigationController?.pushViewController(controller, animated: true)
        case 3:
            HUD.flash(.label("Coming Soon"))
        case 4:
            HUD.flash(.label("Coming Soon"))
        case 5:
            HUD.flash(.label("Coming Soon"))
        case 6:
            HUD.flash(.label("Coming Soon"))
        case 7:
            HUD.flash(.label("Coming Soon"))
        case 8:
            let controller = storyboardObj.instantiateViewController(withIdentifier: "QiblaViewController") as! QiblaViewController
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            break
            
        }
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
}*/
